%% Run and save diffusion spectra
% assuming every case has a full set of anatomic ROIs, 

% averaged over LP, MP, and UP now


%% note to self: if there is an error with all the left or all the right kidneys, check if reason is labelling. 
% in excel, can make new correctly labeled ROIs with new column from names see example below
% sort alphabetically (data, sort, column a, alphabetically)
% %= LEFT(cell,5) & "RK_" & RIGHT(left,LEN(cell)-5) #this would be to add RK to each of the ROIs

%% also note: change read in runNNLS_ML to 3mo to have it read and save in correct folder. 

%this is now combining slices and poles BEFORE signal input is fit!
function RA_DiffusionSpec_Voxelwise_ADC(varargin)
    %PatientNum = varargin{1};
    %PatientNum = ['RA_01_'  varargin{1}];
    PatientNum = ['RA_02_'  varargin{1}];
    if contains(PatientNum, 'V') %then is volunteer, with two kidneys
        %first run for right kidney
        RoiTypes = {'RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};
        cortreg = regexp(RoiTypes, '^.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); 
        ab = 12;
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab);
        RunAndSave_voxelwise_fourpeaks([PatientNum '_RK'],'C',SignalInput)

        % now run for Left Kidney
        RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M'};
        cortreg = regexp(RoiTypes, '^.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); 
        ab = 12;
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab);
        RunAndSave_voxelwise_fourpeaks([PatientNum '_LK'],'C',SignalInput)

    else %is allograft study, so only one allograft
        if nargin == 1 || nargin == 2 && varargin{2} > 10
           
            RoiTypes = {'LP_C','LP_M','MP_C','MP_M','UP_C','UP_M'};
            medulreg = regexp(RoiTypes, '^.*.M$','match'); medulreg = medulreg(~cellfun('isempty',medulreg));
            cortreg = regexp(RoiTypes, '^.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); 
    
            if nargin == 2
                ab = varargin{2};
            else
                ab = 12; %expect only 1,2
            end
    
            % not doing cortical for RA IFTA 
            % get average medullar ROI
            %{
            SignalInput = ReadPatientDWIData_voxelwise(PatientNum, medulreg, ab); 
            %fit that and save it
            RunAndSave_voxelwise_fourpeaks(PatientNum,'M',SignalInput)
            %}
            % get average cortical ROI
            SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab); 
            %fit that and save it
            RunAndSave_voxelwise_fourpeaks(PatientNum,'C',SignalInput)
        else
            error('incorrect input, please check.')
        end
    end  
       
end

%% gave up because matlab is being dumb and randomly reading in some columns as cells. 

% this is to do ivim without  needing xml. just reading from excel 
%based off of wha was done for R2*

% mira sept 2023

% also done for arthi interobserver analysis
function AllVoxelsDecay_total = ReadPatientDWIData_voxelwise(varargin)

    if nargin == 2
        PatientNum = varargin{1} ;
        ROItypes = varargin{2};
        a = 1; b = 4; %if there are 1 - 4 ROI (so C1 - C4 for example)
    elseif nargin ==3
        PatientNum = varargin{1} ;
        ROItypes = varargin{2};
        if varargin{3} == 12
            a = 1; b = 2; %if only 1-2 ROIs per type (so C1-C2 for example)
        elseif varargin{3} == 34
            a = 3; b = 4; %if only 3-4 ROIs per type (so C3 - C4)
        elseif varargin{3} == 14
            a = 1; b = 4;
        end
    end

%% for RENAL ALLOGRAFT, sara rois

    pathtodata = '/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/';
    pathtoCSV = [pathtodata '/' PatientNum '_IVIM.csv'];
%}



%% for Swathi ICC ROIs
%{
    pathtodata = '/Users/miraliu/Desktop/Data/RA/Swathi_ROIs/';
    pathtoCSV = [pathtodata '/' PatientNum '_Swathi.csv'];
%}  
        %% for each type, this is Poles
    count = 0;
    for type = 1:size(ROItypes,2)
        ROItype = string(PatientNum) + '_' + string(ROItypes{1,type});
        %read data
        DataFrame = readtable(pathtoCSV,'PreserveVariableNames', true, 'Range','A:end','Delimiter', ',');    
        ROITypeTable = DataFrame(startsWith(DataFrame.RoiName, ROItype),:);
        %size(ROITypeTable)
        %% for ecah of the slices of these poles
        %average all four ROIs for analysis (CHECK IF I SHOULD DO THIS)
        for k = a:b %for each of the 4 ROIs of every type (%%CHECK!!!!!!)
            ROITypeTablesub = ROITypeTable(strcmp(ROITypeTable.RoiName, ROItype + string(k)),:); %so for example you want LK_LP_C, will check LK_LP_C1, LK_LP_C2 etc.
            ROITypeTablesub = sortrows(ROITypeTablesub,'Dynamic'); %order them according to dynamic, and get the mean from that
            %SignalInput =  SignalInput + ROITypeTablesub.RoiMean;
            %AllVoxelsDecay = table2cell(ROITypeTablesub(1:end,13:end));
            AllVoxelsDecay = ROITypeTablesub(1:end,13:end);
            AllVoxelsDecay = rmmissing(AllVoxelsDecay,2);

            % really shit because matlab does not read this correctly. will
            % slow down a lot just because matlab performs poorly. 
            myvarnames = AllVoxelsDecay.Properties.VariableNames;
            for ii = 1:size(myvarnames,2)
                %AllVoxelsDecay.(myvarnames{ii});
                if iscell(AllVoxelsDecay.(myvarnames{ii}))
                    % If your table variable contains strings then we will have a cell
                    % array. If it's numeric data it will just be in a numeric array
                    AllVoxelsDecay.(myvarnames{ii}) = str2double(AllVoxelsDecay.(myvarnames{ii}));
                end
            end
            AllVoxelsDecay;

            % now convert to an array
            AllVoxelsDecay = table2array(AllVoxelsDecay);
            if count == 0
                AllVoxelsDecay_total = AllVoxelsDecay;
            else
                AllVoxelsDecay_total = [AllVoxelsDecay_total, AllVoxelsDecay]; %creating one long list of 12 x N, for N voxels
            end
            %AllVoxelsDecay = AllVoxelsDecay(:,any(~cellfun('isempty',AllVoxelsDecay),1)); %remove all empty columns
            count = count + 1;
            size(AllVoxelsDecay_total);
           % AllVoxelsDecay = AllVoxelsDecay(:,any(~cellfun(@isnan,AllVoxelsDecay,'UniformOutput',false),1)); %remove all NAN columns
        end
    end
end

%% saving and running on signal input
function RunAndSave_voxelwise_fourpeaks(PatientNum, ROItype,SignalInput)

    %% saving and running on signal input
    disp([PatientNum '_' ROItype])
    %% trying tri-exponential!
    
    %straight up
    ADCvalues = zeros(size(SignalInput,2),1);
    for voxelj = 1:size(SignalInput,2)
        currcurve = squeeze(double(SignalInput(:,voxelj))); %get signal from particular voxel for all images along z axis
        currcurve = currcurve(:)/currcurve(1);


        % only keep 50, 400, and 800 
        b = [0,10,30,50,80,120,200,400,800];
        b = [b(4), b(8), b(9)];
        data = [currcurve(4), currcurve(8), currcurve(9)];
        % ADC monoexp fit
        ln_S=log(data);
        p = polyfit(b, ln_S, 1);
        ADC = -(p(1));
        ADCvalues(voxelj,1) = ADC*1000;
    end
    %remove NaN before doing stats
    ADCvalues=ADCvalues(~isnan(ADCvalues));

    dataarray={mean(ADCvalues), median(ADCvalues), std(ADCvalues), kurtosis(ADCvalues), skewness(ADCvalues)};
    
%% for RENAL ALLOGRAFT, sara rois

    pathtodata = '/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM';
    ExcelFileName=[pathtodata, '/','xxRA_DiffusionSpectra_IVIM.xlsx']; % All results will save in excel file
%}

%% for Swathi ICC ROIs
%{
    pathtodata = '/Users/miraliu/Desktop/Data/RA/Swathi_ROIs';
    ExcelFileName=[pathtodata, '/','RA_Swathi_DiffusionSpectra_IVIM.xlsx']; % All results will save in excel file
%}
% for standard not sorted ones, with 4 peaks
%{
    %Patient ID	ROI Type	mean	stdev	median	skew	kurtosis	size n

    Identifying_Info = {['PN_' PatientNum], [PatientNum '_' ROItype]};
    Existing_Data = readcell(ExcelFileName,'Range','A:B','Sheet','Voxelwise_fourpeaks'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','Voxelwise_fourpeaks')
    end
%}



    %% for sorted ones with 4 peaks
    %Patient ID	ROI Type	mean	stdev	median	skew	kurtosis	size n

    Identifying_Info = {PatientNum, [PatientNum '_' ROItype]};
    Existing_Data = readcell(ExcelFileName,'Range','A:B','Sheet','ClinicalADC'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','ClinicalADC')
    end


end

%% Run and save diffusion spectra
% assuming every case has a full set of anatomic ROIs, 

% averaged over LP, MP, and UP now


%% note to self: if there is an error with all the left or all the right kidneys, check if reason is labelling. 
% in excel, can make new correctly labeled ROIs with new column from names see example below
% sort alphabetically (data, sort, column a, alphabetically)
% %= LEFT(cell,5) & "RK_" & RIGHT(left,LEN(cell)-5) #this would be to add RK to each of the ROIs

%% also note: change read in runNNLS_ML to 3mo to have it read and save in correct folder. 

%this is now combining slices and poles BEFORE signal input is fit!
function RA_DiffusionSpec_Voxelwise(varargin)
    %PatientNum = varargin{1};
    %PatientNum = ['RA_01_'  varargin{1}];
    PatientNum = ['RA_02_'  varargin{1}];
    if nargin == 1 || nargin == 2 && varargin{2} > 10
       
        RoiTypes = {'LP_C','LP_M','MP_C','MP_M','UP_C','UP_M'};
        medulreg = regexp(RoiTypes, '^.*.M$','match'); medulreg = medulreg(~cellfun('isempty',medulreg));
        cortreg = regexp(RoiTypes, '^.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); 

        if nargin == 2
            ab = varargin{2};
        else
            ab = 12; %expect only 1,2
        end

        % get average medullar ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, medulreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise(PatientNum,'M',SignalInput)
        % get average cortical ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise(PatientNum,'C',SignalInput)
    else
        error('incorrect input')
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
%{
    pathtodata = '/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/';
    pathtoCSV = [pathtodata '/' PatientNum '_IVIM.csv'];
%}



%% for Swathi ICC ROIs
    pathtodata = '/Users/miraliu/Desktop/Data/RA/Swathi_ROIs/';
    pathtoCSV = [pathtodata '/' PatientNum '_Swathi.csv'];
    



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
function RunAndSave_voxelwise(PatientNum, ROItype,SignalInput)

    %% saving and running on signal input
    disp([PatientNum '_' ROItype])
    %% trying tri-exponential!
    
    ffastvalues = zeros(size(SignalInput,2),1);
    fmedvalues = zeros(size(SignalInput,2),1);
    fslowvalues = zeros(size(SignalInput,2),1);
    Dfastvalues = zeros(size(SignalInput,2),1);
    Dmedvalues = zeros(size(SignalInput,2),1);
    Dslowvalues = zeros(size(SignalInput,2),1);
    %bvalues = [0,10,30,50,80,120,200,400,800];
    for voxelj = 1:size(SignalInput,2)
        currcurve = squeeze(double(SignalInput(:,voxelj))); %get signal from particular voxel for all images along z axis
        currcurve = currcurve(:)/currcurve(1);
        %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted(currcurve);
        %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted_both(currcurve);
        [~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML(currcurve); %best results so far regarding Mann-Whitney U & AUC
        
        if rsq>0.7 
            if resultsPeaks(1)<1000 %it's set to 10000 if no peaks found, see line 32 of NNLS_result_mod
                ffastvalues(voxelj,1) = resultsPeaks(1);
                fmedvalues(voxelj,1) = resultsPeaks(2);
                fslowvalues(voxelj,1) = resultsPeaks(3);
                Dfastvalues(voxelj,1) = resultsPeaks(4);
                Dmedvalues(voxelj,1) = resultsPeaks(5);
                Dslowvalues(voxelj,1) = resultsPeaks(6);
            end
        else
            ffastvalues(voxelj,1) = NaN;
            fmedvalues(voxelj,1) = NaN;
            fslowvalues(voxelj,1) = NaN;
            Dfastvalues(voxelj,1) = NaN;
            Dmedvalues(voxelj,1) = NaN;
            Dslowvalues(voxelj,1) = NaN;
        end
    end

    %remove NaN before doing stats
    ffastvalues=ffastvalues(~isnan(ffastvalues));
    fmedvalues=fmedvalues(~isnan(fmedvalues));
    fslowvalues=fslowvalues(~isnan(fslowvalues));
    Dfastvalues=Dfastvalues(~isnan(Dfastvalues));
    Dmedvalues=Dmedvalues(~isnan(Dmedvalues));
    Dslowvalues=Dslowvalues(~isnan(Dslowvalues));

    dataarray={mean(ffastvalues), median(ffastvalues), std(ffastvalues), kurtosis(ffastvalues), skewness(ffastvalues),...
                        mean(fmedvalues), median(fmedvalues), std(fmedvalues), kurtosis(fmedvalues), skewness(fmedvalues),...
                        mean(fslowvalues), median(fslowvalues), std(fslowvalues), kurtosis(fslowvalues), skewness(fslowvalues),...
                        mean(Dfastvalues), median(Dfastvalues), std(Dfastvalues), kurtosis(Dfastvalues), skewness(Dfastvalues),...
                        mean(Dmedvalues), median(Dmedvalues), std(Dmedvalues), kurtosis(Dmedvalues), skewness(Dmedvalues),...
                        mean(Dslowvalues), median(Dslowvalues), std(Dslowvalues), kurtosis(Dslowvalues), skewness(Dslowvalues),...
                        size(ffastvalues,1),size(SignalInput,2)};
                

            %% trying tri-exponential!
        %addpath '/Users/miraliu/Desktop/PostDocCode/Kidney_IVIM'
        %bvals = [10,30,50,80,120,200,400,800];
        %[resultsPeaks, rsq] = TriExpIVIMLeastSquaresEstimation(SignalInput,bvals);
    
        %plot(OutputDiffusionSpectrum);
        %pause(1)

%% for RENAL ALLOGRAFT, sara rois
%{
    pathtodata = '/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM';
    ExcelFileName=[pathtodata, '/','RA_DiffusionSpectra_IVIM.xlsx']; % All results will save in excel file
%}

%% for Swathi ICC ROIs
    pathtodata = '/Users/miraliu/Desktop/Data/RA/Swathi_ROIs';
    ExcelFileName=[pathtodata, '/','RA_Swathi_DiffusionSpectra_IVIM.xlsx']; % All results will save in excel file


    %Patient ID	ROI Type	mean	stdev	median	skew	kurtosis	size n

    Identifying_Info = {['PN_' PatientNum], [PatientNum '_' ROItype]};
    Existing_Data = readcell(ExcelFileName,'Range','A:B','Sheet','Voxelwise'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','Voxelwise')
    end

end

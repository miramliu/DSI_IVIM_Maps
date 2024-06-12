%% Run and save diffusion spectra
% assuming every case has a full set of anatomic ROIs, 

% averaged over LP, MP, and UP now


%% note to self: if there is an error with all the left or all the right kidneys, check if reason is labelling. 
% in excel, can make new correctly labeled ROIs with new column from names see example below
% sort alphabetically (data, sort, column a, alphabetically)
% %= LEFT(cell,5) & "RK_" & RIGHT(left,LEN(cell)-5) #this would be to add RK to each of the ROIs

%% also note: change read in runNNLS_ML to 3mo to have it read and save in correct folder. 

%this is now combining slices and poles BEFORE signal input is fit!
function RA_DiffusionSpec_Voxelwise_fourpeaks(varargin)
    %PatientNum = varargin{1};
    PatientNum = ['RA_01_'  varargin{1}];
    %PatientNum = ['RA_02_'  varargin{1}];
    if contains(PatientNum, 'V') %then is volunteer, with two kidneys
        %first run for right kidney
        %{
        RoiTypes = {'RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};
        cortreg = regexp(RoiTypes, '^.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); 
        ab = 12;
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab);
        RunAndSave_voxelwise_fourpeaks([PatientNum '_RK'],'C',SignalInput)
        %}
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
    ffastvalues = zeros(size(SignalInput,2),1);
    fmedvalues = zeros(size(SignalInput,2),1);
    fslowvalues = zeros(size(SignalInput,2),1);
    ffibrovalues = zeros(size(SignalInput,2),1);
    Dfastvalues = zeros(size(SignalInput,2),1);
    Dmedvalues = zeros(size(SignalInput,2),1);
    Dslowvalues = zeros(size(SignalInput,2),1);
    Dfibrovalues = zeros(size(SignalInput,2),1);
    %bvalues = [0,10,30,50,80,120,200,400,800];

    % sorted
    ffastvalues_sort = zeros(size(SignalInput,2),1);
    fmedvalues_sort = zeros(size(SignalInput,2),1);
    fslowvalues_sort = zeros(size(SignalInput,2),1);
    ffibrovalues_sort = zeros(size(SignalInput,2),1);
    Dfastvalues_sort = zeros(size(SignalInput,2),1);
    Dmedvalues_sort = zeros(size(SignalInput,2),1);
    Dslowvalues_sort = zeros(size(SignalInput,2),1);
    Dfibrovalues_sort = zeros(size(SignalInput,2),1);
    rsqvalues = zeros(size(SignalInput,2),1);

    for voxelj = 1:size(SignalInput,2)
        currcurve = squeeze(double(SignalInput(:,voxelj))); %get signal from particular voxel for all images along z axis
        currcurve = currcurve(:)/currcurve(1);
        %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted(currcurve);
        %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted_both(currcurve);
        [OutputSpectrum, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_fourpeaks(currcurve); %best results so far regarding Mann-Whitney U & AUC
        
        if rsq>0.7 
            if resultsPeaks(1)<1000 %it's set to 10000 if no peaks found, see line 32 of NNLS_result_mod
                ffastvalues(voxelj,1) = resultsPeaks(1);
                fmedvalues(voxelj,1) = resultsPeaks(2);
                fslowvalues(voxelj,1) = resultsPeaks(3);
                ffibrovalues(voxelj,1) = resultsPeaks(4);
                Dfastvalues(voxelj,1) = resultsPeaks(5);
                Dmedvalues(voxelj,1) = resultsPeaks(6);
                Dslowvalues(voxelj,1) = resultsPeaks(7);
                Dfibrovalues(voxelj,1) = resultsPeaks(8);
                rsqvalues(voxelj,1) = rsq;

                % now also try to sort them... 
                SortedresultsPeaks = ReSort_fourpeaks(resultsPeaks);
                ffastvalues_sort(voxelj,1) = SortedresultsPeaks(1);
                fmedvalues_sort(voxelj,1) = SortedresultsPeaks(2);
                fslowvalues_sort(voxelj,1) = SortedresultsPeaks(3);
                ffibrovalues_sort(voxelj,1) = SortedresultsPeaks(4);
                Dfastvalues_sort(voxelj,1) = SortedresultsPeaks(5);
                Dmedvalues_sort(voxelj,1) = SortedresultsPeaks(6);
                Dslowvalues_sort(voxelj,1) = SortedresultsPeaks(7);
                Dfibrovalues_sort(voxelj,1) = SortedresultsPeaks(8);

                %disp(voxelj)
                %disp(currcurve)
                %PlotSortedPeaks(voxelj, OutputSpectrum, SortedresultsPeaks)
                
            end
        else
            ffastvalues(voxelj,1) = NaN;
            fmedvalues(voxelj,1) = NaN;
            fslowvalues(voxelj,1) = NaN;
            ffibrovalues(voxelj,1) = NaN;
            Dfastvalues(voxelj,1) = NaN;
            Dmedvalues(voxelj,1) = NaN;
            Dslowvalues(voxelj,1) = NaN;
            Dfibrovalues(voxelj,1) = NaN;

            ffastvalues_sort(voxelj,1) = NaN;
            fmedvalues_sort(voxelj,1) = NaN;
            fslowvalues_sort(voxelj,1) = NaN;
            ffibrovalues_sort(voxelj,1) = NaN;
            Dfastvalues_sort(voxelj,1) = NaN;
            Dmedvalues_sort(voxelj,1) = NaN;
            Dslowvalues_sort(voxelj,1) = NaN;
            Dfibrovalues_sort(voxelj,1) = NaN;
            rsqvalues(voxelj,1) = NaN;
        end
    end

    %remove NaN before doing stats
    ffastvalues=ffastvalues(~isnan(ffastvalues));
    fmedvalues=fmedvalues(~isnan(fmedvalues));
    fslowvalues=fslowvalues(~isnan(fslowvalues));
    ffibrovalues=ffibrovalues(~isnan(ffibrovalues));
    Dfastvalues=Dfastvalues(~isnan(Dfastvalues));
    Dmedvalues=Dmedvalues(~isnan(Dmedvalues));
    Dslowvalues=Dslowvalues(~isnan(Dslowvalues));
    Dfibrovalues=Dfibrovalues(~isnan(Dfibrovalues));
    rsqvalues=rsqvalues(~isnan(rsqvalues));

    dataarray={mean(ffastvalues), median(ffastvalues), std(ffastvalues), kurtosis(ffastvalues), skewness(ffastvalues),...
                        mean(fmedvalues), median(fmedvalues), std(fmedvalues), kurtosis(fmedvalues), skewness(fmedvalues),...
                        mean(fslowvalues), median(fslowvalues), std(fslowvalues), kurtosis(fslowvalues), skewness(fslowvalues),...
                        mean(ffibrovalues), median(ffibrovalues), std(ffibrovalues), kurtosis(ffibrovalues), skewness(ffibrovalues),...
                        mean(Dfastvalues), median(Dfastvalues), std(Dfastvalues), kurtosis(Dfastvalues), skewness(Dfastvalues),...
                        mean(Dmedvalues), median(Dmedvalues), std(Dmedvalues), kurtosis(Dmedvalues), skewness(Dmedvalues),...
                        mean(Dslowvalues), median(Dslowvalues), std(Dslowvalues), kurtosis(Dslowvalues), skewness(Dslowvalues),...
                        mean(Dfibrovalues), median(Dfibrovalues), std(Dfibrovalues), kurtosis(Dfibrovalues), skewness(Dfibrovalues),...
                        size(ffastvalues,1),size(SignalInput,2),...
                        mean(rsqvalues), std(rsqvalues)};
    
    
    %remove NaN before doing stats
    ffastvalues_sort=ffastvalues_sort(~isnan(ffastvalues_sort));
    fmedvalues_sort=fmedvalues_sort(~isnan(fmedvalues_sort));
    fslowvalues_sort=fslowvalues_sort(~isnan(fslowvalues_sort));
    ffibrovalues_sort=ffibrovalues_sort(~isnan(ffibrovalues_sort));
    Dfastvalues_sort=Dfastvalues_sort(~isnan(Dfastvalues_sort));
    Dmedvalues_sort=Dmedvalues_sort(~isnan(Dmedvalues_sort));
    Dslowvalues_sort=Dslowvalues_sort(~isnan(Dslowvalues_sort));
    Dfibrovalues_sort=Dfibrovalues_sort(~isnan(Dfibrovalues_sort));

    dataarray_sort={mean(ffastvalues_sort), median(ffastvalues_sort), std(ffastvalues_sort), kurtosis(ffastvalues_sort), skewness(ffastvalues_sort),...
                        mean(fmedvalues_sort), median(fmedvalues_sort), std(fmedvalues_sort), kurtosis(fmedvalues_sort), skewness(fmedvalues_sort),...
                        mean(fslowvalues_sort), median(fslowvalues_sort), std(fslowvalues_sort), kurtosis(fslowvalues_sort), skewness(fslowvalues_sort),...
                        mean(ffibrovalues_sort), median(ffibrovalues_sort), std(ffibrovalues_sort), kurtosis(ffibrovalues_sort), skewness(ffibrovalues_sort),...
                        mean(Dfastvalues_sort), median(Dfastvalues_sort), std(Dfastvalues_sort), kurtosis(Dfastvalues_sort), skewness(Dfastvalues_sort),...
                        mean(Dmedvalues_sort), median(Dmedvalues_sort), std(Dmedvalues_sort), kurtosis(Dmedvalues_sort), skewness(Dmedvalues_sort),...
                        mean(Dslowvalues_sort), median(Dslowvalues_sort), std(Dslowvalues_sort), kurtosis(Dslowvalues_sort), skewness(Dslowvalues_sort),...
                        mean(Dfibrovalues_sort), median(Dfibrovalues_sort), std(Dfibrovalues_sort), kurtosis(Dfibrovalues_sort), skewness(Dfibrovalues_sort),...
                        size(ffastvalues_sort,1),size(SignalInput,2),...
                        mean(rsqvalues), std(rsqvalues)};


%% for RENAL ALLOGRAFT, sara rois

    pathtodata = '/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM';
    ExcelFileName=[pathtodata, '/','RA_DiffusionSpectra_IVIM_CORRECTED.xlsx']; % All results will save in excel file
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
    Existing_Data = readcell(ExcelFileName,'Range','A:B','Sheet','Voxelwise_sortedFourpeaks_take2'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        Export_Cell = [Identifying_Info,dataarray_sort];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','Voxelwise_sortedFourpeaks_take2')
    end


end

%% Run and save diffusion spectra
% assuming every case has a full set of anatomic ROIs, 

% averaged over LP, MP, and UP now


%% note to self: if there is an error with all the left or all the right kidneys, check if reason is labelling. 
% in excel, can make new correctly labeled ROIs with new column from names see example below
% sort alphabetically (data, sort, column a, alphabetically)
% %= LEFT(cell,5) & "RK_" & RIGHT(left,LEN(cell)-5) #this would be to add RK to each of the ROIs

%% also note: change read in runNNLS_ML to 3mo to have it read and save in correct folder. 

%this is now combining slices and poles BEFORE signal input is fit!

%% can be changed to resorting if you put in RunAndSave_voxelwise_ReSorted_ReSorted! 
% ML 2024 Feb 15th
function DiffusionSpec_Voxelwise(varargin)
    PatientNum = varargin{1};
    if nargin == 1 || nargin == 2 && varargin{2} > 10
        %if both left and right
        RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M','RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};
        if nargin == 2
            ab = varargin{2};
        else
            ab = 14; %assuming 4 slices (i.e. C1 - C4)
        end
    
        %Split into cortical and medul, and left and right
        cortregL = regexp(RoiTypes, '^L.*.C$','match'); cortregL =cortregL(~cellfun('isempty',cortregL)); cortregL = cortregL{:};
        cortregR = regexp(RoiTypes, '^R.*.C$','match'); cortregR =cortregR(~cellfun('isempty',cortregR)); cortregR = cortregR{:};
    
        medulregL = regexp(RoiTypes, '^L.*.M$','match'); medulregL = medulregL(~cellfun('isempty',medulregL)); medulregL = medulregL{:};
        medulregR = regexp(RoiTypes, '^R.*.M$','match'); medulregR = medulregR(~cellfun('isempty',medulregR)); medulregR = medulregR{:};
    
        %% left kidney
        % get average medullar ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, medulregL, ab); 
        %fit that and save it
        RunAndSave_voxelwise_ReSorted(PatientNum,'LK_M',SignalInput)
        % get average cortical ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortregL, ab); 
        %fit that and save it
        RunAndSave_voxelwise_ReSorted(PatientNum,'LK_C',SignalInput)
    
        %% right kidney
        % get average medullar ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, medulregR, ab); 
        %fit that and save it
        RunAndSave_voxelwise_ReSorted(PatientNum,'RK_M',SignalInput)
        % get average cortical ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortregR, ab); 
        %fit that and save it
        RunAndSave_voxelwise_ReSorted(PatientNum,'RK_C',SignalInput)
    elseif nargin == 2 && varargin{2} ==1
        RoiTypes = {'LP_C','LP_M','MP_C','MP_M','UP_C','UP_M'};
        medulreg = regexp(RoiTypes, '^.*.M$','match'); medulreg = medulreg(~cellfun('isempty',medulreg)); medulreg = medulreg{:};
        cortreg = regexp(RoiTypes, '^.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); cortreg = cortreg{:};

        ab = 14;

        % get average medullar ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, medulreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise_ReSorted(PatientNum,'M',SignalInput)
        % get average cortical ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise_ReSorted(PatientNum,'C',SignalInput)
%% only L kidney
    elseif nargin == 2 && varargin{2} ==2
        RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M'};
        medulreg = regexp(RoiTypes, '^L.*.M$','match'); medulreg = medulreg(~cellfun('isempty',medulreg)); medulreg = medulreg{:};
        cortreg = regexp(RoiTypes, '^L.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); cortreg = cortreg{:};

        ab = 14;

        % get average medullar ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, medulreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise_ReSorted(PatientNum,'LK_M',SignalInput)
        % get average cortical ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise_ReSorted(PatientNum,'LK_C',SignalInput)
%% only R kidney
    elseif nargin == 2 && varargin{2} ==3
        RoiTypes = {'RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};
        medulreg = regexp(RoiTypes, '^R.*.M$','match'); medulreg = medulreg(~cellfun('isempty',medulreg)); medulreg = medulreg{:};
        cortreg = regexp(RoiTypes, '^R.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); cortreg = cortreg{:};

        ab = 14;

        % get average medullar ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, medulreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise_ReSorted(PatientNum,'RK_M',SignalInput)
        % get average cortical ROI
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab); 
        %fit that and save it
        RunAndSave_voxelwise_ReSorted(PatientNum,'RK_C',SignalInput)

    elseif nargin == 2 && varargin{2} == 4
        SignalInput = ReadPatientDWIData_Lesion(PatientNum, 'Lesion'); 
        %fit that and save it
        RunAndSave_voxelwise_ReSorted(PatientNum,'Lesion',SignalInput)
    else
        error('incorrect input')
    end
end




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


    
%% for original baseline
    pathtodata = '/Users/miraliu/Desktop/Data/PN/ML_PartialNephrectomy_Export/';
    pathtoCSV = [pathtodata '/' PatientNum '/' PatientNum '_Scan1.csv'];
    %}
    
%% for interobserver
%{
    pathtodata = '/Users/miraliu/Desktop/Data/PN/Arthi Test ROIs/';
    pathtoCSV = [pathtodata PatientNum '_Arthi_IVIM.csv'];
    %}
    
%% for test-retest
    %{
    disp('for test-retest') %and then also change lines 70 - 103 in RunAndSave_voxelwise_ReSorted, and line 94 there. 
    pathtodata = '/Users/miraliu/Desktop/Data/PN/PartialNephrectomy_TestRetest/';
    pathtoCSV = [pathtodata '/P004_IVIM_Scan1_retest.csv']
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


% just save all diffusion spectra for plotting

function DiffusionSpectra_export(varargin)
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
    
        medulregL = regexp(RoiTypes, '^R.*.M$','match'); medulregL = medulregL(~cellfun('isempty',medulregL)); medulregL = medulregL{:};
        medulregR = regexp(RoiTypes, '^R.*.M$','match'); medulregR = medulregR(~cellfun('isempty',medulregR)); medulregR = medulregR{:};
    
        %% left kidney
        % get average medullar ROI
        SignalInput = AverageOverROIs(PatientNum, medulregL, ab); 
        %fit that and save it
        SaveExportSpectra(PatientNum,'LK_M',SignalInput)
        % get average cortical ROI
        SignalInput = AverageOverROIs(PatientNum, cortregL, ab); 
        %fit that and save it
        SaveExportSpectra(PatientNum,'LK_C',SignalInput)
    
        %% right kidney
        % get average medullar ROI
        SignalInput = AverageOverROIs(PatientNum, medulregR, ab); 
        %fit that and save it
        SaveExportSpectra(PatientNum,'RK_M',SignalInput)
        % get average cortical ROI
        SignalInput = AverageOverROIs(PatientNum, cortregR, ab); 
        %fit that and save it
        SaveExportSpectra(PatientNum,'RK_C',SignalInput)
    elseif nargin == 2 && varargin{2} ==1
        RoiTypes = {'LP_C','LP_M','MP_C','MP_M','UP_C','UP_M'};
        medulreg = regexp(RoiTypes, '^.*.M$','match'); medulreg = medulreg(~cellfun('isempty',medulreg)); medulreg = medulreg{:};
        cortreg = regexp(RoiTypes, '^.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); cortreg = cortreg{:};

        ab = 14;

        % get average medullar ROI
        SignalInput = AverageOverROIs(PatientNum, medulreg, ab); 
        %fit that and save it
        SaveExportSpectra(PatientNum,'_M',SignalInput)
        % get average cortical ROI
        SignalInput = AverageOverROIs(PatientNum, cortreg, ab); 
        %fit that and save it
        SaveExportSpectra(PatientNum,'_C',SignalInput)
%% only L kidney
    elseif nargin == 2 && varargin{2} ==2
        RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M'};
        medulreg = regexp(RoiTypes, '^L.*.M$','match'); medulreg = medulreg(~cellfun('isempty',medulreg)); medulreg = medulreg{:};
        cortreg = regexp(RoiTypes, '^L.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); cortreg = cortreg{:};

        ab = 14;

        % get average medullar ROI
        SignalInput = AverageOverROIs(PatientNum, medulreg, ab); 
        %fit that and save it
        SaveExportSpectra(PatientNum,'LK_M',SignalInput)
        % get average cortical ROI
        SignalInput = AverageOverROIs(PatientNum, cortreg, ab); 
        %fit that and save it
        SaveExportSpectra(PatientNum,'LK_C',SignalInput)
%% only R kidney
    elseif nargin == 2 && varargin{2} ==3
        RoiTypes = {'RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};
        medulreg = regexp(RoiTypes, '^R.*.M$','match'); medulreg = medulreg(~cellfun('isempty',medulreg)); medulreg = medulreg{:};
        cortreg = regexp(RoiTypes, '^R.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); cortreg = cortreg{:};

        ab = 14;

        % get average medullar ROI
        SignalInput = AverageOverROIs(PatientNum, medulreg, ab); 
        %fit that and save it
        SaveExportSpectra(PatientNum,'RK_M',SignalInput)
        % get average cortical ROI
        SignalInput = AverageOverROIs(PatientNum, cortreg, ab); 
        %fit that and save it
        SaveExportSpectra(PatientNum,'RK_C',SignalInput)
    else
        error('incorrect input')
    end
end

function SignalInput = AverageOverROIs(PatientNum, ROItypenames, ab) 

    for j = 1:length(ROItypenames)
        ROItypename = [PatientNum '_' ROItypenames{j}];
        %% CHANGE HERE FOR BASELINE, 3M0 OR 12MO
        if j == 1
            SignalInput = ReadPatientDWIData_flexible(PatientNum, ROItypename,ab);
            %SignalInput = ReadPatientDWIData_3mo(PatientNum, ROItype);
    
            %to match bi-exp, normalizing to b0
            SignalInput_av = SignalInput(:)/SignalInput(1);
        else
            SignalInput = ReadPatientDWIData_flexible(PatientNum, ROItypename,ab);
            SignalInput_av = SignalInput_av + SignalInput;
        end
        SignalInput = SignalInput_av/length(ROItypenames);
    end
end

%% saving and running on signal input
function SaveExportSpectra(PatientNum, ROItype,SignalInput)
    disp(PatientNum)
    disp(ROItype)
    %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted(SignalInput);
    %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted_both(SignalInput);
    
    addpath ../../Applied_NNLS_renal_DWI/rNNLS/nwayToolbox
    addpath ../../Applied_NNLS_renal_DWI/rNNLS
%    disp(PatientNum)

    %list_of_b_values = zeros(length(bvalues),max(bvalues));
    %list_of_b_values(h,1:length(b_values)) = b_values; %make matrix of b-values
    b_values = [0,10,30,50,80,120,200,400,800];

    %% Generate NNLS space of values, not entirely sure about this part, check with TG?
    ADCBasisSteps = 300; %(??)
    ADCBasis = logspace( log10(5), log10(2200), ADCBasisSteps);
    A = exp( -kron(b_values',1./ADCBasis));

    
    %% create empty arrays to fill
    amplitudes = zeros(ADCBasisSteps,1);
    resnorm = zeros(1);
    resid = zeros(length(b_values),1);
    y_recon = zeros(max(b_values),1);
    resultsPeaks = zeros(6,1); %6 was 9 before? unsure why


    %% try to git them with NNLS
    [TempAmplitudes, TempResnorm, TempResid ] = CVNNLS(A, SignalInput);
    
    amplitudes(:) = TempAmplitudes';
    resnorm(:) = TempResnorm';
    resid(1:length(TempResid)) = TempResid';
    y_recon(1:size(A,1)) = A * TempAmplitudes;

    % to match r^2 from bi-exp, check w/ octavia about meaning of this 
    SSResid = sum(resid.^2);
    SStotal = (length(b_values)-1) * var(SignalInput);
    rsq = 1 - SSResid/SStotal; 

    


    %% output renaming, just to stay consistent with the TG&JP code
    OutputDiffusionSpectrum = amplitudes;


    pathtodata = '/Users/miraliu/Desktop/Data/PN/ML_PartialNephrectomy_Export';
    ExcelFileName=[pathtodata, '/','PN_IVIM_DiffusionSpectra.xlsx']; % All results will save in excel file

    dataarray= {OutputDiffusionSpectrum};


    %Patient ID	ROI Type	mean	stdev	median	skew	kurtosis	size n

    Identifying_Info = {['PN_' PatientNum] [PatientNum '_' ROItype]}
    Existing_Data = readcell(ExcelFileName,'Range','A:B','Sheet','Spectra'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','Spectra')
    end

end

% to be able to get the data for the DWI analysis... hopefully.
function SignalInput = ReadPatientDWIData_flexible(varargin)
    if nargin == 2
        PatientNum = varargin{1}; 
        ROItype = varargin{2};
        a = 1; b = 4; %if there are 1 - 4 ROI (so C1 - C4 for example)
    elseif nargin ==3
        PatientNum = varargin{1}; 
        ROItype = varargin{2};
        if varargin{3} == 12
            a = 1; b = 2; %if only 1-2 ROIs per type (so C1-C2 for example)
        elseif varargin{3} == 34
            a = 3; b = 4; %if only 3-4 ROIs per type (so C3 - C4)
        elseif varargin{3} == 14
            a = 1; b = 4;
        end
    end

    
    pathtodata = '/Users/miraliu/Desktop/Data/PN/ML_PartialNephrectomy_Export/';
    pathtoCSV = [pathtodata '/' PatientNum '/' PatientNum '_Scan1.csv'];
    %}

  %% for test-retest 
%{
    disp('for test-retest')
    %for test-retest
    pathtodata = '/Users/miraliu/Desktop/Data/PartialNephrectomy_TestRetest/';
    pathtoCSV = [pathtodata '/P011_IVIM_Scan1_test.csv']
%}

    %read data
    DataFrame = readtable(pathtoCSV,'PreserveVariableNames', true, 'Range','A:E','Delimiter', ',');    
    ROITypeTable = DataFrame(startsWith(DataFrame.RoiName, ROItype),:);
    SignalInput = zeros(9,1);
    %average all four ROIs for analysis (CHECK IF I SHOULD DO THIS)
    for k = a:b %for each of the 4 ROIs of every type (%%CHECK!!!!!!)
        ROITypeTablesub = ROITypeTable(strcmp(ROITypeTable.RoiName, ROItype + string(k)),:); %so for example you want LK_LP_C, will check LK_LP_C1, LK_LP_C2 etc.
        
        % also make sure b-values are in order
        if ROITypeTablesub.Dynamic == [0;1;2;3;4;5;6;7;8]
            SignalInput =  SignalInput + ROITypeTablesub.RoiMean;
            %size(SignalInput)
        else
            ROITypeTablesub = sortrows(ROITypeTablesub,'Dynamic'); %order them according to dynamic, and get the mean from that
            SignalInput =  SignalInput + ROITypeTablesub.RoiMean;
        end
    end
    SignalInput = SignalInput./SignalInput(1); %normalize to b0

end
%% Run and save diffusion spectra
% assuming every case has a full set of anatomic ROIs, 


%% note to self: if there is an error with all the left or all the right kidneys, check if reason is labelling. 
% in excel, can make new correctly labeled ROIs with new column from names see example below
% sort alphabetically (data, sort, column a, alphabetically)
% %= LEFT(cell,5) & "RK_" & RIGHT(left,LEN(cell)-5) #this would be to add RK to each of the ROIs

%% also note: change read in runNNLS_ML to 3mo to have it read and save in correct folder. 

function DiffusionSpec_Anatomic(varargin)
if nargin == 1
    PatientNum = varargin{1};
    %if both left and right
    RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M','RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};
    ab = 14; %assuming 4 slices (i.e. C1 - C4)
elseif nargin == 2
    PatientNum = varargin{1};
    RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M','RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};

    if varargin{2} ==1 %unlabelled
        RoiTypes = {'LP_C','LP_M','MP_C','MP_M','UP_C','UP_M'};
        ab = 14;
    elseif varargin{2}==2 %left only
        RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M'};
        ab = 14;
    elseif varargin{2}==3
        RoiTypes = {'RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};
        ab = 14;
    else
        ab = varargin{2};
    end
end

%if only right or left
%RoiTypes = {'LP_C','LP_M','MP_C','MP_M','UP_C','UP_M'};

%for 3mo, when there's only left or right: 
% If only left
%RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M'};
% If only right
%RoiTypes = {'RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};

disp(PatientNum)
for i = 1:length(RoiTypes)
    ROItype = RoiTypes{i}

    ROItypename = [PatientNum '_' ROItype];

%% CHANGE HERE FOR BASELINE, 3M0 OR 12MO
    %SignalInput = ReadPatientDWIData_flexible(PatientNum, ROItypename,ab);
    %SignalInput = ReadPatientDWIData_3mo(PatientNum, ROItype);

    %SignalInput = ReadPatientDWIData_flexible_Arthi(PatientNum, ROItypename,ab); %arthi to compare against... 
    %to match bi-exp, normalizing to b0
%% for test-retest

    % edit the path in the function below
    SignalInput = ReadPatientDWIData_flexible(PatientNum, ROItypename,ab);


    SignalInput = SignalInput(:)/SignalInput(1);


    %% change line 27 in runnnls_ml to ReadpatientDWIData_3mo for 3mo
    [~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML(SignalInput);
    %this is restricted now
    %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted(SignalInput); %rest
    %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted_both(SignalInput);

    %% trying tri-exponential!
    %addpath '/Users/miraliu/Desktop/PostDocCode/Kidney_IVIM'
    %bvals = [0,10,30,50,80,120,200,400,800];
    %[resultsPeaks, rsq] = TriExpIVIMLeastSquaresEstimation_restricted(SignalInput,bvals);

    %plot(OutputDiffusionSpectrum);
    %pause(1)

    %{

%% for interobserver attempt
    pathtodata = '/Users/miraliu/Desktop/Data/Arthi test ROIs';
    ExcelFileName=[pathtodata, '/','PN_Arthi_IVIM_DiffusionSpectra.xlsx']; % All results will save in excel file

    %
%% for baseline 
    %pathtodata = '/Users/miraliu/Desktop/ML_PartialNephrectomy_Export';
    %ExcelFileName=[pathtodata, '/','PN_IVIM_DiffusionSpectra.xlsx']; % All results will save in excel file

    % for 3mo
    %pathtodata = '/Users/miraliu/Desktop/ML_PartialNephrectomy_Export_3mo';
    %ExcelFileName=[pathtodata, '/','PN_IVIM_DiffusionSpectra_3mo.xlsx']; % All results will save in excel file

    Identifying_Info = {['PN_' PatientNum], ROItype};
    Existing_Data = readcell(ExcelFileName,'Range','A:B','Sheet','Sheet1'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        dataarray= {resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),rsq};
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'Sheet','Sheet1','WriteMode','append')
    end

    %}

%% test- retest 
        % for test-retest
    disp('saving test-retest')
    pathtodata = '/Users/miraliu/Desktop/Data/PartialNephrectomy_TestRetest/';
    ExcelFileName=[pathtodata, '/','PN_TestRetesting.xlsx']; % All results will save in excel file

    dataarray= {resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),rsq};


    %Patient ID	ROI Type	mean	stdev	median	skew	kurtosis	size n

    Identifying_Info = {['PN_' PatientNum], 'IVIM_retest', [PatientNum '_' ROItype]}
    Existing_Data = readcell(ExcelFileName,'Range','A:C','Sheet','Voxelwise tri-IVIM'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','Voxelwise tri-IVIM')
    end

end

end
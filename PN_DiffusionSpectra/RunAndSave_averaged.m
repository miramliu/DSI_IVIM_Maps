%% saving and running on signal input
function RunAndSave_averaged(PatientNum, ROItype,SignalInput)
    disp(PatientNum)
    disp(ROItype)
    %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted(SignalInput);
    %[~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_restricted_both(SignalInput);
    [~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML(SignalInput); %best results so far regarding Mann-Whitney U & AUC

    %% trying tri-exponential!
    %addpath '/Users/miraliu/Desktop/PostDocCode/Kidney_IVIM'
    %bvals = [10,30,50,80,120,200,400,800];
    %[resultsPeaks, rsq] = TriExpIVIMLeastSquaresEstimation(SignalInput,bvals);

    %plot(OutputDiffusionSpectrum);
    %pause(1)

    %{

    pathtodata = '/Users/miraliu/Desktop/Data/ML_PartialNephrectomy_Export';
    ExcelFileName=[pathtodata, '/','PN_IVIM_DiffusionSpectra_TG.xlsx']; % All results will save in excel file

   
    Identifying_Info = {['PN_' PatientNum], ROItype};
    Existing_Data = readcell(ExcelFileName,'Range','A:B','Sheet','Rigid_Triexp'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        dataarray= {resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),rsq};
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'Sheet','Rigid_Triexp','WriteMode','append')
    end

    %}

    disp('saving test-retest')
    pathtodata = '/Users/miraliu/Desktop/Data/PartialNephrectomy_TestRetest/';
    ExcelFileName=[pathtodata, '/','PN_TestRetesting.xlsx']; % All results will save in excel file

    dataarray= {resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),rsq};


    %Patient ID	ROI Type	mean	stdev	median	skew	kurtosis	size n

    Identifying_Info = {['PN_' PatientNum], 'IVIM_test', [PatientNum '_' ROItype]}
    Existing_Data = readcell(ExcelFileName,'Range','A:C','Sheet','Voxelwise tri-IVIM'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','Voxelwise tri-IVIM')
    end

end
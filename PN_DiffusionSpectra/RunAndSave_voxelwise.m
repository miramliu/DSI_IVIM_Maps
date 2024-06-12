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
            ffastvalues(voxelj,1) = resultsPeaks(1);
            fmedvalues(voxelj,1) = resultsPeaks(2);
            fslowvalues(voxelj,1) = resultsPeaks(3);
            Dfastvalues(voxelj,1) = resultsPeaks(4);
            Dmedvalues(voxelj,1) = resultsPeaks(5);
            Dslowvalues(voxelj,1) = resultsPeaks(6);
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

    

    pathtodata = '/Users/miraliu/Desktop/Data/PN/ML_PartialNephrectomy_Export';
    ExcelFileName=[pathtodata, '/','PN_IVIM_DiffusionSpectra.xlsx']; % All results will save in excel file

   %{
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

    

    disp('saving test-retest')
    pathtodata = '/Users/miraliu/Desktop/Data/PartialNephrectomy_TestRetest/';
    ExcelFileName=[pathtodata, '/','PN_TestRetesting.xlsx']; % All results will save in excel file
    %}

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
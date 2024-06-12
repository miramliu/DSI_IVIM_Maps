% Input: 

%% output data for lesion diffusion spectrum via NNLS

% ML 2023 aug 21

function [OutputDiffusionSpectrum, Chi, Resid, y_recon, resultsPeaks] = RunNNLS_ML_Lesion(PatientNum,ROItype)

    addpath ../../Applied_NNLS_renal_DWI/rNNLS/nwayToolbox
    addpath ../../Applied_NNLS_renal_DWI/rNNLS
    disp(PatientNum)

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

    %ROItype = [PatientNum '_' ROItype];
    SignalInput = ReadPatientDWIData(PatientNum, ROItype);

    %% try to git them with NNLS
    [TempAmplitudes, TempResnorm, TempResid ] = CVNNLS(A, SignalInput);
    
    amplitudes(:) = TempAmplitudes';
    resnorm(:) = TempResnorm';
    resid(1:length(TempResid)) = TempResid';
    y_recon(1:size(A,1)) = A * TempAmplitudes;

    %% output renaming, just to stay consistent with the TG&JP code
    OutputDiffusionSpectrum = amplitudes;
    Chi = resnorm;
    Resid = resid;

    %plot(OutputDiffusionSpectrum)
    %pause()

    [GeoMeanRegionADC_1,GeoMeanRegionADC_2,GeoMeanRegionADC_3,RegionFraction1,RegionFraction2,RegionFraction3 ] = NNLS_result_mod_ML(OutputDiffusionSpectrum, ADCBasis);
    resultsPeaks(1) = RegionFraction1; %(frac_fast - RegionFraction1)./frac_fast.*100;
    resultsPeaks(2) = RegionFraction2; %(frac_med - RegionFraction2)./frac_med.*100;
    resultsPeaks(3) = RegionFraction3; %(frac_slow - )./frac_slow.*100;
    resultsPeaks(4) = GeoMeanRegionADC_1; %(diff_fast - GeoMeanRegionADC_1./1000)./diff_fast.*100;
    resultsPeaks(5) = GeoMeanRegionADC_2; %(diff_med - GeoMeanRegionADC_2./1000)./diff_med.*100;
    resultsPeaks(6) = GeoMeanRegionADC_3; %(diff_slow - GeoMeanRegionADC_3./1000)./diff_slow.*100;

    %% generating the different components based on Gladytz et al
    %Dblood ~ 180
    %Dtubule ~ 5.8
    %Dtissue ~ 1.5
    %so gonna say there are < 3 peaks, to then split them up as fast if > 10, med if 10 > x > 2, and slow if < 2? 
    
    if nnz(~resultsPeaks) > 0 
        resultsPeaks = RecompartmentalizeMultiexponential(resultsPeaks);
    end
    

    %pathtodata = '/Users/neuroimaging/Desktop/ML_PartialNephrectomy_Export';
    %ExcelFileName=[pathtodata, '/','PN_IVIM_Lesion_DiffusionSpectra.xlsx']; % All results will save in excel file

     % for interobserver attempt
    pathtodata = '/Users/miraliu/Desktop/Data/Arthi test ROIs';
    ExcelFileName=[pathtodata, '/','PN_Arthi_IVIM_DiffusionSpectra.xlsx']; % All results will save in excel file


    Identifying_Info = {['PN_' PatientNum], ROItype};
    Existing_Data = readcell(ExcelFileName,'Range','A:B'); %read only identifying info that already exists
    MatchFunc = @(A,B)cellfun(@isequal,A,B);
    idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));

    if sum(idx)==0
        disp('saving data in excel')
        dataarray= {resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6),OutputDiffusionSpectrum};
        Export_Cell = [Identifying_Info,dataarray];
        writecell(Export_Cell,ExcelFileName,'WriteMode','append')
    end
end


% to be able to get the data for the DWI analysis... hopefully.
function SignalInput = ReadPatientDWIData(PatientNum, ROItype)

    %pathtodata = '/Users/neuroimaging/Desktop/ML_PartialNephrectomy_Export';
    %pathtoCSV = [pathtodata '/' PatientNum '/' PatientNum '_Scan1.csv'];
    
    %interobserver arthi
    pathtodata = '/Users/miraliu/Desktop/Data/Arthi Test ROIs/';
    pathtoCSV = [pathtodata '/' PatientNum  '_Arthi_IVIM.csv'];

    %read data
    DataFrame = readtable(pathtoCSV,'PreserveVariableNames', true, 'Range','A:E','Delimiter', ',');
    %ROITypeTable = DataFrame(startsWith(DataFrame.RoiName, ROItype),:);
    ROITypeTable = DataFrame(contains(DataFrame.RoiName, ROItype),:);
   

    SignalInput = zeros(9,1);
    %average all four ROIs for analysis (CHECK IF I SHOULD DO THIS)=
    ROITypeTablesub = ROITypeTable(contains(ROITypeTable.RoiName, ROItype ),:); %so should just be lesion
    % also make sure b-values are in order
    totalslices = nnz(~ROITypeTable.Dynamic); %the number of zeros (i.e. slices)
    slices = unique(ROITypeTable.ImageNo);
    
    if ROITypeTablesub.Dynamic(1:totalslices:end) == [0;1;2;3;4;5;6;7;8]
        for slice = 1:length(slices)
            ROITypeTablesub = ROITypeTable(ismember(ROITypeTable.ImageNo, slices(slice)),:); %this will get all lesion on slice, 
            ROITypeTablesub = sortrows(ROITypeTablesub,'Dynamic'); %order them according to dynamic, and get the mean from that


            SignalInput =  SignalInput + ROITypeTablesub.RoiMean(1:end); %avearge over all slices
            %length(ROITypeTablesub.RoiMean(slice:totalslices:end))
            %SignalInput =  SignalInput + ROITypeTablesub.RoiMean(slice:totalslices:end); %avearge over all slices
            %size(SignalInput)
        end
        SignalInput = SignalInput./SignalInput(1); %normalize to b0
        
    else
        ROITypeTablesub = sortrows(ROITypeTablesub,'Dynamic'); %order them according to dynamic, and get the mean from that
        for slice = 1:totalslices
            SignalInput =  SignalInput + ROITypeTablesub.RoiMean(slice:totalslices:end);
            %size(SignalInput)
        end
        SignalInput = SignalInput./SignalInput(1); %normalize to b0
    end
    
end

%so gonna say there are < 3 peaks, to then split them up as fast if > 10, med if 10 > x > 2, and slow if < 2? 
function n = DetermineComponent(value)
    if value >= 10
        n = 1;
    elseif value < 10 
        if value > 4 
            n = 2;
        else
            n = 3;
        end
    elseif isnan(value) 
        error('Nan')
    end
end


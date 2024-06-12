% Input: 
%% after TG discussion on Sept 14th, trying to run it with restricted D_tissue AND D_blood via partial regularization
function [OutputDiffusionSpectrum, rsq, Resid, y_recon, resultsPeaks] = RunNNLS_ML_restricted_both(SignalInput)

    addpath ../../Applied_NNLS_renal_DWI/rNNLS/nwayToolbox
    addpath ../../Applied_NNLS_renal_DWI/rNNLS
    %disp(PatientNum)

    %list_of_b_values = zeros(length(bvalues),max(bvalues));
    %list_of_b_values(h,1:length(b_values)) = b_values; %make matrix of b-values
    b_values = [0,10,30,50,80,120,200,400,800];

    %% Generate NNLS space of values, not entirely sure about this part, check with TG?
    ADCBasisSteps = 300; %(??)
    ADCBasis = logspace( log10(5), log10(2200), ADCBasisSteps);

    %%% Diffusion Parameters (Baseline) from TG paper
    diff_fast   = 0.180;
    diff_med    = 0.0058; %[0.006 0.007 0.008 0.009 0.010];
    diff_slow   = 0.0015;
    %frac_fast   = 0.10;
    %frac_med    = 0.30;
    %frac_slow   = 0.60;

    ADCThresh=1./sqrt([diff_fast*diff_med diff_med*diff_slow]);
    %ADCBasis_fix = [1/diff_fast logspace( log10(ADCThresh(1)), log10(ADCThresh(2)), ADCBasisSteps/3-2) 1/diff_slow];
    ADCBasis_fix = [1/diff_fast logspace( log10(ADCThresh(1)), log10(ADCThresh(2)), ADCBasisSteps/3-2) 1/diff_slow];
    A_fix = exp( -kron(b_values',1./ADCBasis_fix));

    
    %% create empty arrays to fill
    amplitudes = zeros(length(ADCBasis_fix),1);
    resnorm = zeros(1);
    resid = zeros(length(b_values),1);
    y_recon = zeros(max(b_values),1);
    resultsPeaks = zeros(6,1); %6 was 9 before? unsure why

    %% try to git them with NNLS
    %[TempAmplitudes, TempResnorm, TempResid ] = CVNNLS(A, SignalInput);
    [TempAmplitudes, TempResnorm, TempResid ] = CVNNLS_PartialRegularization(A_fix, SignalInput, [1 length(ADCBasis_fix)]);
    
    amplitudes(:) = TempAmplitudes';
    resnorm(:) = TempResnorm';
    resid(1:length(TempResid)) = TempResid';
    y_recon(1:size(A_fix,1)) = A_fix * TempAmplitudes;

    % to match r^2 from bi-exp, check w/ octavia about meaning of this 
    SSResid = sum(resid.^2);
    SStotal = (length(b_values)-1) * var(SignalInput);
    rsq = 1 - SSResid/SStotal; 

    


    %% output renaming, just to stay consistent with the TG&JP code
    OutputDiffusionSpectrum = amplitudes;
    %plot(OutputDiffusionSpectrum);
    %pause(1)
    Chi = resnorm;
    Resid = resid;

    %attempt with TG version? 
    % assumed ADC thresh from 2_Simulation...
    ADCThresh = 1./sqrt([0.180*0.0058 0.0058*0.0015]);
    [GeoMeanRegionADC_1,GeoMeanRegionADC_2,GeoMeanRegionADC_3,RegionFraction1,RegionFraction2,RegionFraction3 ] = NNLS_resultTG(OutputDiffusionSpectrum, ADCBasis_fix, ADCThresh);


    %[GeoMeanRegionADC_1,GeoMeanRegionADC_2,GeoMeanRegionADC_3,RegionFraction1,RegionFraction2,RegionFraction3 ] = NNLS_result_mod_ML(OutputDiffusionSpectrum, ADCBasis_fix);
    resultsPeaks(1) = RegionFraction1; %(frac_fast - RegionFraction1)./frac_fast.*100;
    resultsPeaks(2) = RegionFraction2; %(frac_med - RegionFraction2)./frac_med.*100;
    resultsPeaks(3) = RegionFraction3; %(frac_slow - )./frac_slow.*100;
    resultsPeaks(4) = GeoMeanRegionADC_1; %(diff_fast - GeoMeanRegionADC_1./1000)./diff_fast.*100;
    resultsPeaks(5) = GeoMeanRegionADC_2; %(diff_med - GeoMeanRegionADC_2./1000)./diff_med.*100;
    resultsPeaks(6) = GeoMeanRegionADC_3; %(diff_slow - GeoMeanRegionADC_3./1000)./diff_slow.*100;

end

% to be able to get the data for the DWI analysis... hopefully.
function SignalInput = ReadPatientDWIData_3mo(PatientNum, ROItype)

    pathtodata = '/Users/miraliu/Desktop/Data/ML_PartialNephrectomy_Export_3mo';
    pathtoCSV = [pathtodata '/' PatientNum '/' PatientNum '_Scan2.csv'];
    
    %read data
    DataFrame = readtable(pathtoCSV,'PreserveVariableNames', true, 'Range','A:E','Delimiter', ',');    
    ROITypeTable = DataFrame(startsWith(DataFrame.RoiName, ROItype),:);
    SignalInput = zeros(9,1);
    %average all four ROIs for analysis (CHECK IF I SHOULD DO THIS)
    for k = 1:4 %for each of the 4 ROIs of every type (%%CHECK!!!!!!)
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
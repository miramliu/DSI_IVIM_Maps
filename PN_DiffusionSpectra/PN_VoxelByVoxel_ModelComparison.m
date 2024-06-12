%% Run voxel-by-voxel comparison between different models in PN study


% Mira Liu 3/14/2024
function PN_VoxelByVoxel_ModelComparison(varargin)
    addpath '/Users/miraliu/Desktop/PostDocCode/Applied_NNLS_renal_DWI/RA_DiffusionSpectra'
    addpath '/Users/miraliu/Desktop/PostDocCode/Applied_NNLS_renal_DWI/rNNLS'
    addpath '/Users/miraliu/Desktop/PostDocCode/Applied_NNLS_renal_DWI/rNNLS/nwayToolbox'
    if nargin == 1
        PatientNum = varargin{1};
        %if both left and right
        RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M','RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};
        ab = 14; %assuming 4 slices (i.e. C1 - C4)
        startvox = 1;
    elseif nargin > 1
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
        if nargin == 3
            startvox = varargin{2};
        else
            startvox = 1;
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
        SignalInput = ReadPatientDWIData_flexible(PatientNum, ROItypename,ab);
    
    
        SignalInput = SignalInput(:)/SignalInput(1);
    
    
        RunComparativeModels(PatientNum,'C',SignalInput, startvox)

       
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



%% saving and running on signal input
function RunComparativeModels(PatientNum, ROItype,SignalInput,startvox)

    %% saving and running on signal input
    disp([PatientNum '_' ROItype])
    bvalues = [0, 10, 30, 50, 80, 120, 200, 400, 800];
    allb = 0:800;


    for voxelj = startvox:size(SignalInput,2)
        currcurve = squeeze(double(SignalInput(:,voxelj))); %get signal from particular voxel for all images along z axis
        currcurve = currcurve(:)/currcurve(1);
        disp(voxelj)
        disp(currcurve)

        figure(1);
        scatter(bvalues, currcurve,20, "filled", 'MarkerFaceColor', 'black');
        hold on;

        %% for ADC and IVIM
        [MMSE,~,~,~,~,~,~,~,~,~,~,~]=IVIMBayesianEstimation(bvalues,currcurve);
      
        %goodness of ADC fit
        curveADC1=currcurve(bvalues>100);
        curveADC = curveADC1(:)/curveADC1(1); %normalize
        ADCfit=polyfit(bvalues(bvalues>100),log(curveADC),1);
       
        %goodness of ADC fit
        ADCf=curveADC(1)*exp(-bvalues(bvalues>100).*abs(ADCfit(1)))
        yresidADC=curveADC'-ADCf
        SSresidADC=sum(yresidADC.^2)
        SStotalADC = (length(curveADC)-1) * var(curveADC)
        rsqADC = 1 - SSresidADC/SStotalADC

        if rsqADC >0.7
            fprintf('ADC voxel: ')
            disp(1000*abs(ADCfit(1)))
            plot(allb, curveADC(1)*exp(-allb.*abs(ADCfit(1))), "red",'LineWidth',2,'DisplayName','ADC')
            hold on;
        end

        %fit curve from IVIM Bayesian
        curveFit=currcurve(1)*(exp(-MMSE.Ds.*bvalues)*MMSE.f+exp(-MMSE.D.*bvalues)*(1-MMSE.f));
        yresid = minus(currcurve' ,curveFit);
        SSresid = sum(yresid.^2);
        SStotal = (length(currcurve)-1) * var(currcurve);
        rsq = 1 - SSresid/SStotal;
        %MMSE
        % code that constrains writing the map only if rsq>0.7
        if rsq>0.7
            disp('IVIM voxel: ')
            disp([MMSE.f, 1000*MMSE.Ds, 1000*MMSE.D]);
            plot(allb, MMSE.f*exp(-allb.*MMSE.Ds) + (1-MMSE.f)*exp(-allb.*MMSE.D), "green",'LineWidth',2,'DisplayName','IVIM')
            hold on
        end

        %% for rigid triexponential
        [resultsPeaks, rsq] = TriExpIVIMLeastSquaresEstimation(currcurve,bvalues);
        if rsq>0.7
            disp('Rigid Triexp Voxel: ')
            disp(resultsPeaks)
            plot(allb, resultsPeaks(1)*exp(-allb.*resultsPeaks(4)) + resultsPeaks(2)*exp(-allb.*resultsPeaks(5)) + resultsPeaks(3)*exp(-allb.*resultsPeaks(6)), "blue", 'LineWidth',2, 'DisplayName','Tri-exponential');
            hold on
        end


        %% first spectral
        [OutputSpectrum, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_fourpeaks(currcurve); %best results so far regarding Mann-Whitney U & AUC
        
        if rsq>0.7 
            if resultsPeaks(1)<1000 %it's set to 10000 if no peaks found, see line 32 of NNLS_result_mod

                % now also try to sort them... 
                SortedresultsPeaks = ReSort_fourpeaks(resultsPeaks);
                disp('spectral voxel: ')
                disp(SortedresultsPeaks)
                plot(allb, SortedresultsPeaks(1)*exp(-allb.*SortedresultsPeaks(5)/1000) + SortedresultsPeaks(2)*exp(-allb.*SortedresultsPeaks(6)/1000) + SortedresultsPeaks(3)*exp(-allb.*SortedresultsPeaks(7)/1000) + SortedresultsPeaks(4)*exp(-allb.*SortedresultsPeaks(8)/1000), "magenta", 'LineWidth',2, 'DisplayName','Spectral')
                
                hold off;
                legend
                PlotSortedPeaks(voxelj, OutputSpectrum, SortedresultsPeaks)
                
            end
        else
            hold off;
            legend
        end


        

    end
end
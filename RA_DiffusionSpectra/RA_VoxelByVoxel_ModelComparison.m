%% Given signal from a single voxel, return plots and values and Rsquared for ADC, IVIM, tri-exp, and model free spectral


% Mira Liu 3/11/2024
function RA_VoxelByVoxel_ModelComparison(varargin)

    addpath '/Users/miraliu/Desktop/PostDocCode/Kidney_IVIM'
    addpath '/Users/miraliu/Desktop/PostDocCode/Applied_NNLS_renal_DWI/rNNLS'
    addpath '/Users/miraliu/Desktop/PostDocCode/Applied_NNLS_renal_DWI/rNNLS/nwayToolbox'
    %PatientNum = varargin{1};
    PatientNum = ['RA_01_'  varargin{1}];
    %PatientNum = ['RA_02_'  varargin{1}];
    if contains(PatientNum, 'V') %then is volunteer, with two kidneys
        if nargin >1 
            startvox = varargin{2};
            if nargin ==3
                savespec = 1;
            else
                savespec = 0;
            end
        else
            startvox = 1;
            savespec = 0;
            
        end
        %first run for right kidney
        RoiTypes = {'RK_LP_C','RK_LP_M','RK_MP_C','RK_MP_M','RK_UP_C','RK_UP_M'};
        cortreg = regexp(RoiTypes, '^.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); 
        ab = 12;
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab);
        RunComparativeModels([PatientNum '_RK'],'C',SignalInput,startvox,savespec)

        % now run for Left Kidney
        RoiTypes = {'LK_LP_C','LK_LP_M','LK_MP_C','LK_MP_M','LK_UP_C','LK_UP_M'};
        cortreg = regexp(RoiTypes, '^.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); 
        ab = 12;
        SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab);
        RunComparativeModels([PatientNum '_LK'],'C',SignalInput,startvox,savespec)

    else %is allograft study, so only one allograft
        if nargin < 4
           
            RoiTypes = {'LP_C','LP_M','MP_C','MP_M','UP_C','UP_M'};
            medulreg = regexp(RoiTypes, '^.*.M$','match'); medulreg = medulreg(~cellfun('isempty',medulreg));
            cortreg = regexp(RoiTypes, '^.*.C$','match'); cortreg = cortreg(~cellfun('isempty',cortreg)); 
    
            ab = 12; 
            % not doing cortical for RA IFTA 
            % get average medullar ROI
            %{
            SignalInput = ReadPatientDWIData_voxelwise(PatientNum, medulreg, ab); 
            %fit that and save it
            RunComparativeModels(PatientNum,'M',SignalInput)
            %}
            % get average cortical ROI
            SignalInput = ReadPatientDWIData_voxelwise(PatientNum, cortreg, ab); 
            %fit that and save it
            if nargin >1 
                startvox = varargin{2};
                if nargin ==3
                    savespec = 1;
                else
                    savespec = 0;
                end
            else
                startvox = 1;
                savespec = 0;
            end
            RunComparativeModels(PatientNum,'C',SignalInput, startvox, savespec)
        

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

    %% for RENAL ALLOGRAFT
    pathtodata = '/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/';
    pathtoCSV = [pathtodata '/' PatientNum '_IVIM.csv'];

    
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
function RunComparativeModels(PatientNum, ROItype,SignalInput,startvox, savespec)


    %% saving and running on signal input
    disp([PatientNum '_' ROItype])
    bvalues = [0, 10, 30, 50, 80, 120, 200, 400, 800];
    allb = 0:800;

    if savespec == 0 
        endvox = size(SignalInput,2);
    else
        endvox = startvox;
    end
    for voxelj = startvox:endvox
        currcurve = squeeze(double(SignalInput(:,voxelj))); %get signal from particular voxel for all images along z axis
        currcurve = currcurve(:)/currcurve(1);
        disp(voxelj)
        disp(currcurve)

        figure(1);
        scatter(bvalues, currcurve,20, "filled", 'MarkerFaceColor', 'black');
        hold on;


        %{ 
        %% for ADC and IVIM
        [MMSE,~,~,~,~,~,~,~,~,~,~,~]=IVIMBayesianEstimation(bvalues,currcurve);
      
        %goodness of ADC fit
        ADCfit=polyfit(bvalues(bvalues>100),log(currcurve(bvalues>100)),1);
       
        %goodness of ADC fit
        curveADC=currcurve(bvalues>100);
        ADCf=curveADC(1)*exp(-bvalues(bvalues>100).*abs(ADCfit(1)));
        yresidADC=curveADC'-ADCf;
        SSresidADC=sum(yresidADC.^2);
        SStotalADC = (length(curveADC)-1) * var(curveADC);
        rsqADC = 1 - SSresidADC/SStotalADC;

        
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

        %}
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

        %% if is indicated to save, have it here.
        if savespec == 1
            dataarray = OutputSpectrum;
            pathtodata = '/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM';
            ExcelFileName=[pathtodata, '/','RA_DiffusionSpectra_IVIM.xlsx']; % All results will save in excel file
        
        
        
            %Patient ID	ROI Type	mean	stdev	median	skew	kurtosis	size n
        
            Identifying_Info = {PatientNum, [PatientNum '_' ROItype], voxelj};
            Existing_Data = readcell(ExcelFileName,'Range','A:C','Sheet','Voxelwise_spectralplots'); %read only identifying info that already exists
            MatchFunc = @(A,B)cellfun(@isequal,A,B);
            idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));
        
            if sum(idx)==0
                disp('saving data in excel')
                Export_Cell = [Identifying_Info,dataarray];
                writecell(Export_Cell,ExcelFileName,'WriteMode','append','Sheet','Voxelwise_spectralplots')
            end
        end
        

    end
    disp('All Done!')

end

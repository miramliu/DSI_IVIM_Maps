function [parameter_map, spectralmap] = DSI_FIT_continuousNNLS_kidney(b_values, ImageStack, lambda)
%------------------------------------------------------%
% Fit S(b)/So=CBV*exp(-bD*)+(1-CBV)*exp(-bD)           %
%------------------------------------------------------%
    [N_Bvalues, nx, ny] = size(ImageStack);

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
    
    %create empty parameter map
    parameter_map = zeros(nx,ny,6);
    spectralmap = zeros(nx, ny, 300);

    
    for i=1:nx
        for j=1:ny
            if (ImageStack(1,i,j) > 100 ) 

                % for normal b values
                SignalInput = squeeze(double(ImageStack(1:N_Bvalues,i,j)/ImageStack(1,i,j))); 


                %% for combined fine + coarse IVIM!!!!!! 
                %SignalInput1 = squeeze(double(ImageStack(3:11,i,j)/ImageStack(1,i,j))); 
                %SignalInput2 = squeeze(double(ImageStack(12:19,i,j)/ImageStack(2,i,j))); 
                %plot(Bvalues(2:end), [1; SignalInput1; SignalInput2])
                %SignalInput = [1; SignalInput1; SignalInput2];

               
                %% try to fit them with NNLS
                if strcmp(lambda, 'cv')
                    [TempAmplitudes, TempResnorm, TempResid ] = CVNNLS(A, SignalInput);
                else

                %% fitting with simple NNLS, with an assumed constant regularization paramater of lambda = #b-value/SNR = 0.1
                %lambda = 6; %
                    [TempAmplitudes, TempResnorm, TempResid ] = simpleCVNNLS_curveregularized(A, SignalInput, lambda); %this now also still has the ends regularized
                end

                
                amplitudes(:) = TempAmplitudes';
                resnorm(:) = TempResnorm';
                resid(1:length(TempResid)) = TempResid';
                y_recon(1:size(A,1)) = A * TempAmplitudes;
            
                % to match r^2 from bi-exp, check w/ octavia about meaning of this 
                SSResid = sum(resid.^2);
                SStotal = (length(b_values)-1) * var(SignalInput);
                rsq = 1 - SSResid/SStotal; 


                OutputDiffusionSpectrum = amplitudes;

                %% for plotting
                %{
                plot(b_values,SignalInput)
                pause(1)
                %% output renaming, just to stay consistent with the TG&JP code
                
                semilogx((1./ADCBasis)*1000,OutputDiffusionSpectrum)
                hold on;
                xline(.8), xline(5), xline(50);
                pause(1)
                hold off;
                %plot(OutputDiffusionSpectrum);
                %pause(1)
                Chi = resnorm;
                Resid = resid;
            
                %}
                %attempt with TG version? prior to TG meeting Sept 14th. 
                % assumed ADC thresh from 2_Simulation...
                %ADCThresh = 1./sqrt([0.180*0.0058 0.0058*0.0015]);

                [GeoMeanRegionADC_1, GeoMeanRegionADC_2, GeoMeanRegionADC_3, RegionFraction1, RegionFraction2, RegionFraction3] = NNLS_result_mod_ML(TempAmplitudes, ADCBasis);

                resultsPeaks(1) = RegionFraction1; %(frac_fast - RegionFraction1)./frac_fast.*100;
                resultsPeaks(2) = RegionFraction2; %(frac_med - RegionFraction2)./frac_med.*100;
                resultsPeaks(3) = RegionFraction3; %(frac_slow - )./frac_slow.*100;
                resultsPeaks(4) = GeoMeanRegionADC_1; %(diff_fast - GeoMeanRegionADC_1./1000)./diff_fast.*100;
                resultsPeaks(5) = GeoMeanRegionADC_2; %(diff_med - GeoMeanRegionADC_2./1000)./diff_med.*100;
                resultsPeaks(6) = GeoMeanRegionADC_3; %(diff_slow - GeoMeanRegionADC_3./1000)./diff_slow.*100;



                if rsq>0.7
                    if resultsPeaks(1)<1000 %it's set to 10000 if no peaks found, see line 32 of NNLS_result_mod
                        % now  try to sort them... 
                        SortedresultsPeaks = ReSort_threepeaks_Jonas5(resultsPeaks);
                        parameter_map(i,j,1) = SortedresultsPeaks(1); %vasc frac
                        parameter_map(i,j,2) = SortedresultsPeaks(2); %tubule frac
                        parameter_map(i,j,3) = SortedresultsPeaks(3); %tissue frac
                        parameter_map(i,j,4) = SortedresultsPeaks(4); %vasc D
                        parameter_map(i,j,5) = SortedresultsPeaks(5); %tubule D
                        parameter_map(i,j,6) = SortedresultsPeaks(6); %tissue D
    
                        spectralmap(i,j,:) = OutputDiffusionSpectrum;
                    else
                        parameter_map(i,j,:) = zeros(6,1);
                        spectralmap(i,j,:) = zeros(300,1);
                    end
                else
                    parameter_map(i,j,:) = zeros(6,1);
                    spectralmap(i,j,:) = zeros(300,1);
                end

            else
               parameter_map(i,j,:) = zeros(6,1);
               spectralmap(i,j,:) = zeros(300,1);
            end
            
        end
    end
end


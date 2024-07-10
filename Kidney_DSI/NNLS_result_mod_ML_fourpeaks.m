%% modified by ML to take any number of peaks from 1 - 3 

% still in prograss if it's 3+

% Ml Aug 2023

%% with with 4peaks if its 3+! 

% ML Jan 2024 (woah, 4 months ago? wild)

function [ GeoMeanRegionADC_1,GeoMeanRegionADC_2,GeoMeanRegionADC_3,GeoMeanRegionADC_4, RegionFraction1,RegionFraction2,RegionFraction3,RegionFraction4] = NNLS_result_mod_ML_fourpeaks( TempAmplitudes, ADCBasis )

    [locsMax, pksMax]=peakseekTG(TempAmplitudes,1,realmin);
    [locsMin, pksMin]=peakseekTG(-TempAmplitudes-(min(-TempAmplitudes)));
    
    peaksMax = locsMax(pksMax ~= 0);
    pksMax = pksMax(pksMax ~= 0);
    if length(peaksMax) < 2 % try to find peaks in curvature
      [locsMax, pksMax]=peakseekTG(-diff(diff(TempAmplitudes)),1,realmin);
      peaksMax = locsMax(pksMax ~= 0);
      pksMax = TempAmplitudes(peaksMax);
    end
    
    while length(peaksMax) > 4.5 % fuse closest peaks to reduce number to 4.
	    [neglPeakPos,neglPeak]=min(diff(peaksMax(1:end-1))); % find the two closest peaks
	    if pksMax(neglPeak)>pksMax(neglPeak+1) % which of both is bigger?
		    neglPeak=neglPeak+1; % neglect the latter one
	    end
	    peaksMax=peaksMax(setdiff(1:end,neglPeak));
	    pksMax=pksMax(setdiff(1:end,neglPeak));
    end
    % check for peaks
    %disp('peak maxes')
    %disp(peaksMax)
    if length(peaksMax)<1
        GeoMeanRegionADC_1 = 0;
        RegionFraction1 = 10000; %just to catch it. 
        GeoMeanRegionADC_2 = 0;
        RegionFraction2 = 0;
        GeoMeanRegionADC_3 = 0;
        RegionFraction3 = 0;
        GeoMeanRegionADC_4 = 0;
        RegionFraction4 = 0;
    else
        %Peak1
        %disp('peak 1')
        Peak1End = locsMin(locsMin > peaksMax(1));
        if length(peaksMax) > 1 %if there's more than just 1 peak)
            %disp('peak 2')
            Peak2End = locsMin(locsMin > peaksMax(2));
            if isempty(Peak2End)
                [locsMinCurv, pksMinCurv]=peakseekTG(diff(diff(TempAmplitudes)));% Try to find mimimum in Curvature
                Peak2End = locsMinCurv(locsMinCurv > peaksMax(2));
                if isempty(Peak2End) % if it's still empty
                    peaksMax = peaksMax(1); % remove second peaks
                end

            elseif length(peaksMax) >2 %if there's more than 2 peaks
                if length(peaksMax) > 3 %if 4 peaks
                    %disp('peak 3 if 4 peaks')
                    Peak3End = locsMin(locsMin > peaksMax(3)); % then need to define peak3end, and then peak4 end is the end. 
                else
                    %disp('peak 3 if 3 peaks')
                    Peak3End = length(ADCBasis); %else it's just the end of the spectrum
                end
            end
            %% for case 0019
            %{
            if Peak2End == Peak1End %if they're equal, just one weird case
                [locsMax, pksMax]=peakseekTG(TempAmplitudes,1,realmin);
                peaksMax = locsMax(pksMax ~= 0); %go with the original 
            end
            %}
        end
        
        TotalArea = sum(TempAmplitudes);
        
        range1 = 1:Peak1End(1); %ADCBasis >= ADCBasis(1)  &  ADCBasis < ADCBasis(Peak1End(1)+1);
        
        ADCBasisRange1 = ADCBasis(range1);
        ADCampsRange1 = TempAmplitudes(range1);
        RegionFraction1 = sum( ADCampsRange1 ) / TotalArea;
        
        ADCwidth1 = ADCBasisRange1(ADCampsRange1 >= pksMax(1)./2);
        ADCwidth1 = 1./ADCwidth1(1) - 1./ADCwidth1(end);
        
        GeoMeanRegionADC_1 = (1./ exp( dot( ADCampsRange1, log( ADCBasisRange1 ) ) ./ ( RegionFraction1*TotalArea ) )).*1000;

        if length(peaksMax) > 1 %if there's more than just 1 peak)
        %peak 2
            range2 = (Peak1End(1)+1):Peak2End(1); %ADCBasis >= ADCBasis(Peak1End(1)+1)  &  ADCBasis < ADCBasis(Peak2End(1)+1);
            
            ADCBasisRange2 = ADCBasis(range2);
            ADCampsRange2 = TempAmplitudes(range2);
            RegionFraction2 = sum( ADCampsRange2 ) / TotalArea;
            
            ADCwidth2 = ADCBasisRange2(ADCampsRange2 >= pksMax(2)./2);
            if isempty(ADCwidth2)
    
            else
              ADCwidth2 = 1./ADCwidth2(1) - 1./ADCwidth2(end);
            end
            
            GeoMeanRegionADC_2 = (1./exp( dot( ADCampsRange2, log( ADCBasisRange2 ) ) ./ ( RegionFraction2*TotalArea ) )).*1000;
        else
            %disp('no 2nd peak')
            %set to zero
            GeoMeanRegionADC_2 = 0;
            RegionFraction2 = 0;
        
        end
        
        if length(peaksMax) > 2
         %Peak3
                range3 = (Peak2End(1)+1):Peak3End(1); %ADCBasis >= ADCBasis(Peak2End(1)+1)  &  ADCBasis < ADCBasis(end);
                
                ADCBasisRange3 = ADCBasis(range3);
                ADCampsRange3 = TempAmplitudes(range3);
                RegionFraction3 = sum( ADCampsRange3 ) / TotalArea;
                
                GeoMeanRegionADC_3 = (1./exp( dot( ADCampsRange3, log( ADCBasisRange3 ) ) ./ ( RegionFraction3*TotalArea ) )).*1000;
         else
             %disp('no 3rd peak')
            %set to zero
            GeoMeanRegionADC_3 = 0;
            RegionFraction3 = 0;
        end

        if length(peaksMax) > 3
         %Peak4
                range4 = (Peak3End(1)+1):length(ADCBasis); %ADCBasis >= ADCBasis(Peak2End(1)+1)  &  ADCBasis < ADCBasis(end);
                
                ADCBasisRange4 = ADCBasis(range4);
                ADCampsRange4 = TempAmplitudes(range4);
                RegionFraction4 = sum( ADCampsRange4 ) / TotalArea;
                
                GeoMeanRegionADC_4 = (1./exp( dot( ADCampsRange4, log( ADCBasisRange4 ) ) ./ ( RegionFraction4*TotalArea ) )).*1000;
         else
             %disp('no 3rd peak')
            %set to zero
            GeoMeanRegionADC_4 = 0;
            RegionFraction4 = 0;
        end


    end
    %disp([GeoMeanRegionADC_1,GeoMeanRegionADC_2,GeoMeanRegionADC_3,GeoMeanRegionADC_4, RegionFraction1,RegionFraction2,RegionFraction3,RegionFraction4])
end
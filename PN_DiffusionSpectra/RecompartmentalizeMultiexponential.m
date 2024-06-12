%% Given fractions and diffusion coefficients will correct order
% into fast, medium, and slow if there are < 3 of the expected
% tri-exponential 

% Mira Liu Aug 24 2023


function dummyresultspeaks = RecompartmentalizeMultiexponential(resultsPeaks)
    dummyresultspeaks = resultsPeaks;
    idx = find(resultsPeaks);
    correctthese = idx(idx>3); %get the diffusion coefficients that are not zero
    for k =1:numel(correctthese) %for the diffusion coefficients that need to be shuffed appropriately
        j = correctthese(k);
        n = DetermineComponent(resultsPeaks(j)); %see the speed of this peak
        if n ~= j-3 %if it needs to be moved to a different speed fraction
            %move to the correct fraction
            dummyresultspeaks(n) = resultsPeaks(j-3);
            dummyresultspeaks(n+3) = resultsPeaks(j);
            %make the one it was moved from zero now
            if dummyresultspeaks(j-3) == resultsPeaks(j-3) %if it has NOT been replaced by a prevoius move 
                dummyresultspeaks(j-3) = 0; %set to zero
                dummyresultspeaks(j) = 0;
            end
            
        end
        %pause()
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
%%  four part peaks, sort into blood, tubule, tissue, and fibrosis
% ML Feb 29th
% written originally by location along diffusion coefficient spectra
% now written to include largest peak as diffusion. 

% important changes from ReSort_fourpeaks_orig: 'expected' diffusion is 1.8 now as opposed to 1.5, 
% and threshold for blood is now 50 as opposed to 10. and now peak size is considered. 
% assumes fibrosis < .8, tissue is > .8, < 5, tubule is > 2, < 50, blood is > 50 
function SortedresultsPeaks = ReSort_fourpeaks(resultsPeaks)

    %% for note... 
    %disp('------------------------------------------------------------------------- ')
    f_blood = resultsPeaks(1);
    f_tubule = resultsPeaks(2);
    f_tissue = resultsPeaks(3);
    f_fibro = resultsPeaks(4);
    D_blood = resultsPeaks(5);
    D_tubule = resultsPeaks(6);
    D_tissue = resultsPeaks(7);
    D_fibro = resultsPeaks(8);
    %SortedresultsPeaks = [f_blood, f_tubule, f_tissue, f_fibro, D_blood, D_tubule, D_tissue, D_fibro];

    %% already in ascending order!!
    CompartmentFractions = [f_blood, f_tubule, f_tissue, f_fibro];
    CompartmentDiffusions = [D_blood, D_tubule, D_tissue, D_fibro];

    if nnz(CompartmentFractions) > 1
        SortingDone = 0; %sorting is not done yet
        if nnz(CompartmentFractions) ==2
            idxs = find(CompartmentDiffusions); %find which ones are non-zero
            difference = (abs(CompartmentDiffusions-1.8)); % find all value distance from assumed diffusion peak 
            [~, minidx] = min([difference(idxs(1)), difference(idxs(2))]); %find the closest to diffusion of the 3 non-zero peaks
            [~, maxidx] = max([difference(idxs(1)), difference(idxs(2))]); %find the closest to diffusion of the 3 non-zero peaks

            % added part regarding fraction for determining which one is diffusion peak
            [~, compartmaxidx] = max([CompartmentFractions(idxs(1)), CompartmentFractions(idxs(2))]); %find the largest of the 2 peaks
 
            if compartmaxidx == minidx % if max peak is also closest to diffusion
                tissue_idx = idxs(minidx); %the diffusion index is the index of the closest to 1.8 10-3 
                max_idx = idxs(maxidx); %the bigger difference is the smaller peak
            else % if the largest peak is NOT the one that is closest to diffusion, how then to decide? 
                smaller_idx = idxs(minidx); %the diffusion index is the index of the closest to 1.8 10-3, which in this case has a smaller fraction
                larger_idx = idxs(maxidx); %the bigger distance from 1.8, which in this case has a larger fraction.
                %IF the largest is over .8, then the largest is diffusion 
                if CompartmentDiffusions(larger_idx) > 0.8  
                    if CompartmentDiffusions(larger_idx) < 5
                        tissue_idx = larger_idx; %the diffusion index is the index of the closest to 1.8 10-3 
                        max_idx = smaller_idx; %the bigger difference, so inelegant sorry. slow dya. 
                    else %if the largest peak is over 5, then tissue is the smaller peak
                        tissue_idx = smaller_idx; %the diffusion index is the index of the closest to 1.8 10-3 
                        max_idx = larger_idx; %still don't know what the other peak is though
                    end
                else %IF the largest is under .8, and furthest from diffusion... 
                    if CompartmentDiffusions(smaller_idx) > 5 %if the other one is not tissue diffusion, the larger one is (even if < .8)
                        f_tissue= CompartmentFractions(larger_idx);
                        D_tissue= CompartmentDiffusions(larger_idx);
                        f_fibro = CompartmentFractions(smaller_idx);
                        D_fibro = CompartmentDiffusions(smaller_idx);    

                        SortedresultsPeaks = [0, 0, f_tissue, f_fibro, 0, 0, D_tissue, D_fibro];
                        SortingDone = 1; %it is set, no need to sort the 'extra' one
                    else %the other diffusion compartment is < 5, so the smaller peak is diffusion, and the largest peak under .8 is fibrosis. 
                        tissue_idx = smaller_idx; %the diffusion index is the index of the closest to 1.8 10-3 
                        f_tissue= CompartmentFractions(smaller_idx);
                        D_tissue= CompartmentDiffusions(smaller_idx);
                        f_fibro = CompartmentFractions(larger_idx);
                        D_fibro = CompartmentDiffusions(larger_idx);
    
                        SortedresultsPeaks = [0, 0, f_tissue, f_fibro, 0, 0, D_tissue, D_fibro];
                        SortingDone = 1; %it is set, no need to sort the 'extra' one
                    end
                end
            end

        %% Once tissue peak has been selected, sort the others based on diffusion coefficient
            if SortingDone == 0
                % now we know which one is the tissue fraction
                f_tissue= CompartmentFractions(tissue_idx);
                D_tissue= CompartmentDiffusions(tissue_idx);
    
                %if non-tissue peak is faster
                if CompartmentDiffusions(max_idx) > CompartmentDiffusions(tissue_idx)
    
                    %if it's > 50, it's blood flow !! note changing to > 50,
                    if CompartmentDiffusions(max_idx) > 50 
                        f_blood = CompartmentFractions(max_idx);
                        D_blood = CompartmentDiffusions(max_idx);
                        
                        SortedresultsPeaks = [f_blood, 0, f_tissue, 0, D_blood, 0, D_tissue, 0];
                    else %if it's < 50
                        f_tubule = CompartmentFractions(max_idx);
                        D_tubule = CompartmentDiffusions(max_idx);
    
                        SortedresultsPeaks = [0, f_tubule, f_tissue, 0, 0, D_tubule, D_tissue, 0];
                    end
    
                else %if it's < tissue
                    f_fibro = CompartmentFractions(max_idx);
                    D_fibro = CompartmentDiffusions(max_idx);
    
                    SortedresultsPeaks = [0, 0, f_tissue, f_fibro, 0, 0, D_tissue, D_fibro];
                end
            end
         
        elseif nnz(CompartmentFractions) ==3 
            idxs = find(CompartmentDiffusions); %find which ones are non-zero
            difference = (abs(CompartmentDiffusions-1.8)); % find all value distance from assumed diffusion peak 
            [~, minidx] = min([difference(idxs(1)), difference(idxs(2)), difference(idxs(3))]); %find the closest to diffusion of the 3 non-zero peaks
            [~, maxidx] = max([difference(idxs(1)), difference(idxs(2)), difference(idxs(3))]); %find the closest to diffusion of the 3 non-zero peaks
            %disp('check 1')
            % added part regarding fraction for determining which one is diffusion peak
            [~, compartmaxidx] = max([CompartmentFractions(idxs(1)), CompartmentFractions(idxs(2)), CompartmentFractions(idxs(3))]); %find the largest of the 3 non-zero peaks
            if compartmaxidx == minidx % if largest peak is also closest to diffusion
                if CompartmentDiffusions(idxs(compartmaxidx)) > 0.8 && CompartmentDiffusions(idxs(compartmaxidx)) < 5 % if it's in the diffusion range
                    tissue_idx = idxs(minidx); %the diffusion index is the index of the closest to 1.8 10-3 
                    max_idx = idxs(maxidx); %the bigger difference, smaller peak
                    max_and_min = [minidx, maxidx];
                    allidx = [1,2,3];
                    middleidx = setdiff(allidx, max_and_min); % the one that is inbetween 
                    middle_idx = idxs(middleidx);
    
                    f_tissue= CompartmentFractions(tissue_idx);
                    D_tissue= CompartmentDiffusions(tissue_idx);
                    SortingDone = 0; % not done sorting
                else%if largest peak is also closest to diffusion, but is < 0.8
                    % check if there is a peak in the diffusion range
                    %disp('check 2')
                    if ~any(CompartmentDiffusions >=.8 & CompartmentDiffusions < 5) %if none of the peaks are in that range
                        %then that largest peak that's closest to diffusion but < 0.8 is the diffusion peak
                        tissue_idx = idxs(minidx); %the diffusion index is the index of the closest to 1.8 10-3 
                        max_idx = idxs(maxidx); %the bigger difference, smaller peak
                        max_and_min = [minidx, maxidx];
                        allidx = [1,2,3];
                        middleidx = setdiff(allidx, max_and_min); % the one that is inbetween 
                        middle_idx = idxs(middleidx);
        
                        f_tissue= CompartmentFractions(tissue_idx);
                        D_tissue= CompartmentDiffusions(tissue_idx);
                        SortingDone = 0; % not done sorting
                        %{ 
                    % this section was editted and removed 3/1/2024. See notes for details as to why.
                    else %else, there is a peak in the diffusion range, and the largest peak closest to diffusion is smaller than it, so the largest peak closest is actually fibrosis.
                        %that means the closest peak is fibrosis, the middle peak is tissue diffusion. 

                        max_and_min = [minidx, maxidx];
                        allidx = [1,2,3];
                        middleidx = setdiff(allidx, max_and_min); % the one that is inbetween 
                        middle_idx = idxs(middleidx);
                        max_idx = idxs(maxidx); %the bigger difference, smaller peak
                        min_idx = idxs(minidx); %the bigger difference, smaller peak

                        f_fibro = CompartmentFractions(min_idx); %fibro is the large peak that's closest
                        D_fibro = CompartmentDiffusions(min_idx);

                        f_tissue= CompartmentFractions(middle_idx);
                        D_tissue= CompartmentDiffusions(middle_idx);

                        if CompartmentDiffusions(max_idx) > 50 
                            f_blood = CompartmentFractions(max_idx); %blood is the middle difference
                            D_blood = CompartmentDiffusions(max_idx);
    
                            SortedresultsPeaks = [f_blood, 0, f_tissue, f_fibro, D_blood, 0, D_tissue, D_fibro];
                            SortingDone = 1; %sorting is done

                        else %if it's < 50
                            f_tubule = CompartmentFractions(max_idx); %tubule is the middle difference
                            D_tubule = CompartmentDiffusions(max_idx);
    
                            SortedresultsPeaks = [0, f_tubule, f_tissue, f_fibro, 0, D_tubule, D_tissue, D_fibro];
                            SortingDone = 1; %sorting is done
                        end
                    end
                        %}
                    % added II march 1 2024
                    else % if closest peak to 1.8 is largest peak, but is not in range....and there IS a peak in that range
                        %disp('check 3')
                        min_idx = idxs(minidx);
                        max_idx = idxs(maxidx);
                        max_and_min = [minidx, maxidx];
                        allidx = [1,2,3];
                        middleidx = setdiff(allidx, max_and_min); % the one that is inbetween 
                        middle_idx = idxs(middleidx);
                        %disp(CompartmentDiffusions)
                        if any(CompartmentDiffusions <.8) && any(CompartmentDiffusions > 5) %if there's one peak above aand one peak below tissue range
                            tissue_idx = middle_idx; % then middle index is it. It's not the min (closeslt, largest, but not in range), and max woudl be even further
                            f_tissue= CompartmentFractions(tissue_idx);
                            D_tissue= CompartmentDiffusions(tissue_idx);
                            %disp('check 4')

                            if CompartmentDiffusions(min_idx) < CompartmentDiffusions(max_idx) %if min is less than max, min is the fibrosis
                                f_fibro = CompartmentFractions(min_idx);
                                D_fibro = CompartmentDiffusions(min_idx);
                                if CompartmentDiffusions(max_idx) > 50 %if the max is over 50, it's blood
                                    f_blood = CompartmentFractions(max_idx); %blood is the other max-difference
                                    D_blood = CompartmentDiffusions(max_idx);
                                    SortedresultsPeaks = [f_blood, 0, f_tissue, f_fibro, D_blood, 0, D_tissue, D_fibro];
                                    SortingDone = 1; %sorting is done
                                else
                                    f_tubule = CompartmentFractions(max_idx);
                                    D_tubule = CompartmentDiffusions(max_idx);
                                    SortedresultsPeaks = [0, f_tubule, f_tissue, f_fibro, 0, D_tubule, D_tissue, D_fibro];
                                    SortingDone = 1; %sorting is done
                                end
                            else % if max is less than min, then max is the fibrosis
                                f_fibro = CompartmentFractions(max_idx);
                                D_fibro = CompartmentDiffusions(max_idx);
                                if CompartmentDiffusions(min_idx) > 50 %if the max is over 50, it's blood
                                    f_blood = CompartmentFractions(min_idx); %blood is the other max-difference
                                    D_blood = CompartmentDiffusions(min_idx);
                                    SortedresultsPeaks = [f_blood, 0, f_tissue, f_fibro, D_blood, 0, D_tissue, D_fibro];
                                    SortingDone = 1; %sorting is done
                                else
                                    f_tubule = CompartmentFractions(min_idx);
                                    D_tubule = CompartmentDiffusions(min_idx);
                                    SortedresultsPeaks = [0, f_tubule, f_tissue, f_fibro, 0, D_tubule, D_tissue, D_fibro];
                                    SortingDone = 1; %sorting is done
                                end
                            end
                        else %if there is a peak in tissue range, and there are 2 other peaks either both bove or both below the tissue range
                            if CompartmentDiffusions(min_idx) < .8 %if both peaks are smaller than the tissue range (then slow tubule, NO BLOOD)
                                if CompartmentDiffusions(max_idx) > CompartmentDiffusions(min_idx) %if max is the one in the range then 
                                    f_tubule = CompartmentFractions(max_idx);
                                    D_tubule = CompartmentDiffusions(max_idx);
                                    f_tissue = CompartmentFractions(min_idx);
                                    D_tissue = CompartmentDiffusions(min_idx);
                                    f_fibro = CompartmentFractions(middle_idx);
                                    D_fibro = CompartmentDiffusions(middle_idx);
                                    SortedresultsPeaks = [0, f_tubule, f_tissue, f_fibro, 0, D_tubule, D_tissue, D_fibro];
                                    SortingDone = 1; %sorting is done
                                else %if max is < largest peak, then it is fibrosis
                                    f_tubule = CompartmentFractions(middle_idx);
                                    D_tubule = CompartmentDiffusions(middle_idx);
                                    f_tissue = CompartmentFractions(min_idx);
                                    D_tissue = CompartmentDiffusions(min_idx);
                                    f_fibro = CompartmentFractions(max_idx);
                                    D_fibro = CompartmentDiffusions(max_idx);
                                    SortedresultsPeaks = [0, f_tubule, f_tissue, f_fibro, 0, D_tubule, D_tissue, D_fibro];
                                    SortingDone = 1; %sorting is done
                                end
                            else % if both peaks are both above the tissue range, NO FIBROSIS.
                                if CompartmentDiffusions(max_idx)>CompartmentDiffusions(middle_idx)
                                    f_tubule = CompartmentFractions(min_idx);
                                    D_tubule = CompartmentDiffusions(min_idx);
                                    f_tissue = CompartmentFractions(middle_idx);
                                    D_tissue = CompartmentDiffusions(middle_idx);
                                    f_blood = CompartmentFractions(max_idx);
                                    D_blood = CompartmentDiffusions(max_idx);
                                    SortedresultsPeaks = [f_blood, f_tubule, f_tissue, 0, D_blood, D_tubule, D_tissue, 0];
                                    SortingDone = 1; %sorting is done

                                else %if middle is < max 
                                    f_tubule = CompartmentFractions(min_idx);
                                    D_tubule = CompartmentDiffusions(min_idx);
                                    f_tissue = CompartmentFractions(max_idx);
                                    D_tissue = CompartmentDiffusions(max_idx);
                                    f_blood = CompartmentFractions(middle_idx);
                                    D_blood = CompartmentDiffusions(middle_idx);
                                    SortedresultsPeaks = [f_blood, f_tubule, f_tissue, 0, D_blood, D_tubule, D_tissue, 0];
                                    SortingDone = 1; %sorting is done
                                end
                            end
                        end
                    end
                end

                % if it has only been assigned tissue compartment... 
                if SortingDone ==0 
                    %if tissue diffusion it's the smallest (i.e. no fibrosis peak lower than tissue diffusion)
                    if CompartmentDiffusions(tissue_idx) == min(nonzeros(CompartmentDiffusions))
                        f_blood = CompartmentFractions(max_idx);
                        D_blood = CompartmentDiffusions(max_idx);
                        f_tubule = CompartmentFractions(middle_idx);
                        D_tubule = CompartmentDiffusions(middle_idx);
                        SortedresultsPeaks = [f_blood, f_tubule, f_tissue, 0, D_blood, D_tubule, D_tissue, 0];
                        SortingDone = 1; %sorting is done
                    % Added III march 1 2024
                    elseif CompartmentDiffusions(tissue_idx) == max(nonzeros(CompartmentDiffusions))
                        if CompartmentFractions(min_idx)/CompartmentFractions(middle_idx) > 1.5 % if middle is within 1.5 of tissue (min) in terms of size
                            f_tissue = CompartmentFractions(middle_idx); %rename tissue
                            D_tissue = CompartmentDiffusions(middle_idx);
                            f_tubule = CompartmentFractions(min_idx);
                            D_tubule = CompartmentDiffusions(min_idx);
                            f_fibro = CompartmentFractions(max_idx);
                            D_fibro = CompartmentDiffusions(max_idx);
                            SortedresultsPeaks = [0, f_tubule, f_tissue, f_fibro, 0, D_tubule, D_tissue, D_fibro];
                            SortingDone = 1; %sorting is done
                        else %if middle is smaller... but two peaks les than tissue, merge into one fibrosis peak
                            f_fibro = CompartmentFractions(max_idx) + CompartmentFractions(middle_idx);
                            weightedDiffs = CompartmentFractions(max_idx)*CompartmentDiffusion(max_idx) + CompartmentFractions(middle_idx)*CompartmentDiffusion(middle_idx);
                            D_fibro = weightedDiffs/(CompartmentFractions(max_idx) + CompartmentFractions(middle_idx));
                            % make it a 2 peak spectrum
                            SortedresultsPeaks = [0, 0, f_tissue, f_fibro, 0, 0, D_tissue, D_fibro];
                            SortingDone = 1; %sorting is done
                        end
                    else %if one of them is bigger than tissue and the other is smaller... 
                        % if furthest diff peak > tissue peak
                        if CompartmentDiffusions(max_idx) > CompartmentDiffusions(tissue_idx) 
                            %either it is tubule or perfusion
                            %if it's > 50, it's blood flow
                            if CompartmentDiffusions(max_idx) > 50 
                                f_blood = CompartmentFractions(max_idx); %blood is the other max-difference
                                D_blood = CompartmentDiffusions(max_idx);
                                
                                f_fibro = CompartmentFractions(middle_idx); %fibro is the middle-difference
                                D_fibro = CompartmentDiffusions(middle_idx);
        
                                SortedresultsPeaks = [f_blood, 0, f_tissue, f_fibro, D_blood, 0, D_tissue, D_fibro];
                                SortingDone = 1; %sorting is done
                            else %if it's < 50
                                f_tubule = CompartmentFractions(max_idx); %tubule is the other max-difference
                                D_tubule = CompartmentDiffusions(max_idx);
        
                                f_fibro = CompartmentFractions(middle_idx); %fibro is the middle-difference
                                D_fibro = CompartmentDiffusions(middle_idx);
                                SortedresultsPeaks = [0, f_tubule, f_tissue, f_fibro, 0, D_tubule, D_tissue, D_fibro];
                                SortingDone = 1; %sorting is done
                            end
                        else % if the furthest diff peak is < tissue peak, then that max_idx is fibro (< tissue)
                            f_fibro = CompartmentFractions(max_idx);
                            D_fibro = CompartmentDiffusions(max_idx);
                            if CompartmentDiffusions(middle_idx) > 50 
                                f_blood = CompartmentFractions(middle_idx); %blood is the middle difference
                                D_blood = CompartmentDiffusions(middle_idx);
        
                                SortedresultsPeaks = [f_blood, 0, f_tissue, f_fibro, D_blood, 0, D_tissue, D_fibro];
                                SortingDone = 1; %sorting is done
    
                            else %if it's < 50
                                f_tubule = CompartmentFractions(middle_idx); %tubule is the middle difference
                                D_tubule = CompartmentDiffusions(middle_idx);
        
                                SortedresultsPeaks = [0, f_tubule, f_tissue, f_fibro, 0, D_tubule, D_tissue, D_fibro];
                                SortingDone = 1; %sorting is done
                            end
                        end
                    end
                end

            else % if largest peak is NOT the closest to 1.8 (minidx is not equal to compartmaxidx)
                % if the largest peak is in the diffusion range... just call it diffusion anyway
                if  CompartmentDiffusions(idxs(compartmaxidx)) > 0.8 && CompartmentDiffusions(idxs(compartmaxidx)) < 5 
                    %disp('check 3')
                    tissue_idx = idxs(compartmaxidx);
                    f_tissue= CompartmentFractions(tissue_idx);
                    D_tissue= CompartmentDiffusions(tissue_idx);
                    if maxidx == compartmaxidx % if it is the furthest... 
                        min_idx = idxs(minidx);
                        max_idx = idxs(maxidx);
                        max_and_min = [minidx, maxidx];
                        allidx = [1,2,3];
                        middleidx = setdiff(allidx, max_and_min); % the one that is inbetween 
                        middle_idx = idxs(middleidx);
                        SortingDone = 0; % not done sorting
                        SortType = 3; %tissue peak idx is 'maxidx'
                    else % it isn't the min and isn't the max distance, so it's the middle
                        min_idx = idxs(minidx);
                        max_idx = idxs(maxidx);
                        middle_idx = idxs(compartmaxidx);
                        SortingDone = 0; % not done sorting
                        SortType = 2; % tissue peak idx is middle

                    end
                else % if it's not in the diffusion range... 
                    %if there are NO peaks in that range
                    if ~any(CompartmentDiffusions >=.8 & CompartmentDiffusions < 5) 
                        %then that largest peak is the diffusion peak %%%%%%%%%%%%%% NOTE THIS IS WHERE I SAY IF THERE ARE TWO LARGE PEAKS,
                        %CLOSEST TO DIFFUSION IS DIFFUSION. IF THERE'S OEN LARGE PEAK, one small peak that's closer, THE LARGE PEAK IS DIFFUSION
                        B = sort(CompartmentFractions, 'descend');
                        Max1 = B(1); % largest
                        Max2 = B(2); % second largest
                        if Max1/Max2 < 1.5 % if the largest peak is less than 1.5 times the size of the second largest one... then the closest one is diffusion
                            tissue_idx = idxs(minidx); %the diffusion index is the index of the closest to 1.8 10-3 
                            max_idx = idxs(maxidx); %the bigger difference, smaller peak
                            min_idx = idxs(minidx);
                            max_and_min = [minidx, maxidx];
                            allidx = [1,2,3];
                            middleidx = setdiff(allidx, max_and_min); % the one that is inbetween 
                            middle_idx = idxs(middleidx);
            
                            f_tissue= CompartmentFractions(tissue_idx);
                            D_tissue= CompartmentDiffusions(tissue_idx);
                            SortingDone = 0; % not done sorting
                            SortType = 1; %tissue peak idx is min 
                        else % if the largest peak is much larger than the second peak. the largest peak is diffusion
                            tissue_idx = idxs(compartmaxidx);
                            if compartmaxidx == maxidx
                                max_idx = idxs(maxidx); %furthest idx is the largest one... yikes. 
                                min_idx = idxs(minidx); %the bigger difference, smaller peak
                                max_and_min = [minidx, maxidx];
                                allidx = [1,2,3];
                                middleidx = setdiff(allidx, max_and_min); % the one that is inbetween 
                                middle_idx = idxs(middleidx);
                
                                f_tissue= CompartmentFractions(tissue_idx);
                                D_tissue= CompartmentDiffusions(tissue_idx);
                                SortingDone = 0; % not done sorting
                                SortType = 3; %tissue peak is max
                            else %if compartmaxidx isn't the maxidx or the minidx, it's the middle one
                                max_idx = idxs(maxidx); %the bigger difference, smaller peak
                                min_idx = idxs(minidx); %the bigger difference, smaller peak
                                middle_idx = idxs(compartmaxidx);
                                f_tissue= CompartmentFractions(tissue_idx);
                                D_tissue= CompartmentDiffusions(tissue_idx);
                                SortingDone = 0; % not done sorting
                                SortType = 2; %tissue peak is middle
                            end
                        end
                    else %if there IS a diffusion compartment in the tissue range (but it isn't the largest peak, as the largest peak isnt closest to diffusion) then the one in the tissue range is the peak.
                        tissue_idx = idxs(minidx); %the diffusion index is the index of the closest to 1.8 10-3, the one in the diffusion range.
                        max_idx = idxs(maxidx); %the bigger difference, smaller peak
                        min_idx = idxs(minidx);
                        max_and_min = [minidx, maxidx];
                        allidx = [1,2,3];
                        middleidx = setdiff(allidx, max_and_min); % the one that is inbetween 
                        middle_idx = idxs(middleidx);
        
                        f_tissue= CompartmentFractions(tissue_idx);
                        D_tissue= CompartmentDiffusions(tissue_idx);
                        SortingDone = 0; % not done sorting
                        SortType = 1; %tissue peak is min
                    end
                end
                % to do and be added!!
                % if it has only been assigned tissue compartment... and the tissue compartment is min (closest to diffusion)
                if SortingDone ==0 
                    % attempt to change 'max' and 'middle' to 'other1' and 'other2' to allow tissue to not just be min idx
                    if SortType == 1
                        % sorttype1 means Tissue is min, trying to sort max and middle
                        % replaced max_idx with other1_idx
                        % replaced middle_idx with other2_idx
                        tissue_idx = min_idx; %already known, but to be sure.
                        other1_idx = max_idx;
                        other2_idx = middle_idx;
                    elseif SortType == 2
                        %sorttype2 means tissue is middle, trying to sort max and min 
                        tissue_idx = middle_idx; %already known, but to be sure.
                        other1_idx = max_idx; 
                        other2_idx = min_idx;
                    elseif SortType == 3
                        %sorttype2 means tissue is middle, trying to sort max and min 
                        tissue_idx = max_idx; %already known, but to be sure.
                        other1_idx = middle_idx; 
                        other2_idx = min_idx;
                    end
                    %if tissue diffusion it's the smallest (i.e. no fibrosis peak lower than tissue diffusion)
                    if CompartmentDiffusions(tissue_idx) == min(nonzeros(CompartmentDiffusions))
                        f_blood = CompartmentFractions(other1_idx); % max for 1 or 2, middle for 2
                        D_blood = CompartmentDiffusions(other1_idx);
                        f_tubule = CompartmentFractions(other2_idx); %min for 2 or 3, middle for 1
                        D_tubule = CompartmentDiffusions(other2_idx);
                        SortedresultsPeaks = [f_blood, f_tubule, f_tissue, 0, D_blood, D_tubule, D_tissue, 0];
                        SortingDone = 1; %sorting is done
                    % Added III march 1 2024
                    elseif CompartmentDiffusions(tissue_idx) == max(nonzeros(CompartmentDiffusions))
                        if CompartmentFractions(tissue_idx)/CompartmentFractions(other2_idx) > 1.5 % if middle is within 1.5 of tissue (min) in terms of size
                            f_tissue = CompartmentFractions(other2_idx); %rename tissue
                            D_tissue = CompartmentDiffusions(other2_idx);
                            f_tubule = CompartmentFractions(tissue_idx); %tubule is now what tissue was
                            D_tubule = CompartmentDiffusions(tissue_idx);
                            f_fibro = CompartmentFractions(other1_idx);
                            D_fibro = CompartmentDiffusions(other1_idx);
                            SortedresultsPeaks = [0, f_tubule, f_tissue, f_fibro, 0, D_tubule, D_tissue, D_fibro];
                            SortingDone = 1; %sorting is done
                        else %if middle is smaller... but two peaks les than tissue, merge into one fibrosis peak
                            f_fibro = CompartmentFractions(other1_idx) + CompartmentFractions(other2_idx);
                            weightedDiffs = CompartmentFractions(other1_idx)*CompartmentDiffusion(other1_idx) + CompartmentFractions(other2_idx)*CompartmentDiffusion(other2_idx);
                            D_fibro = weightedDiffs/(CompartmentFractions(other1_idx) + CompartmentFractions(other2_idx));
                            % make it a 2 peak spectrum
                            SortedresultsPeaks = [0, 0, f_tissue, f_fibro, 0, 0, D_tissue, D_fibro];
                            SortingDone = 1; %sorting is done
                        end
                    else %if one of them is bigger than tissue and the other is smaller... 
                        % if furthest diff peak > tissue peak
                        if CompartmentDiffusions(other1_idx) > CompartmentDiffusions(tissue_idx) 
                            %either it is tubule or perfusion
                            %if it's > 50, it's blood flow
                            if CompartmentDiffusions(other1_idx) > 50 
                                f_blood = CompartmentFractions(other1_idx); %blood is the other max-difference
                                D_blood = CompartmentDiffusions(other1_idx);
                                
                                f_fibro = CompartmentFractions(other2_idx); %fibro is the closest as tissue is the 
                                D_fibro = CompartmentDiffusions(other2_idx);
        
                                SortedresultsPeaks = [f_blood, 0, f_tissue, f_fibro, D_blood, 0, D_tissue, D_fibro];
                                SortingDone = 1; %sorting is done
                            else %if it's < 50
                                f_tubule = CompartmentFractions(other1_idx); %tubule is the other max-difference
                                D_tubule = CompartmentDiffusions(other1_idx);
        
                                f_fibro = CompartmentFractions(other2_idx); %fibro is the middle-difference
                                D_fibro = CompartmentDiffusions(other2_idx);
                                SortedresultsPeaks = [0, f_tubule, f_tissue, f_fibro, 0, D_tubule, D_tissue, D_fibro];
                                SortingDone = 1; %sorting is done
                            end
                        else % if the furthest diff peak is < tissue peak, then that other1_idx is fibro (< tissue)
                            f_fibro = CompartmentFractions(other1_idx);
                            D_fibro = CompartmentDiffusions(other1_idx);
                            if CompartmentDiffusions(other2_idx) > 50 
                                f_blood = CompartmentFractions(other2_idx); %blood is the middle difference
                                D_blood = CompartmentDiffusions(other2_idx);
        
                                SortedresultsPeaks = [f_blood, 0, f_tissue, f_fibro, D_blood, 0, D_tissue, D_fibro];
                                SortingDone = 1; %sorting is done
    
                            else %if it's < 50
                                f_tubule = CompartmentFractions(other2_idx); %tubule is the middle difference
                                D_tubule = CompartmentDiffusions(other2_idx);
        
                                SortedresultsPeaks = [0, f_tubule, f_tissue, f_fibro, 0, D_tubule, D_tissue, D_fibro];
                                SortingDone = 1; %sorting is done
                            end
                        end
                    end
                end
            end
        else %  it's 4 peaks and it's just it's in descending order... 

            SortedresultsPeaks = [f_blood, f_tubule, f_tissue, f_fibro, D_blood, D_tubule, D_tissue, D_fibro];
        end
    else %if only one peak... then that one peak has got to be the diffusion one... 
        idxs = find(resultsPeaks); %find which one is non-zero
        SortedresultsPeaks = [0,0,resultsPeaks(idxs(1)),0,0,0,resultsPeaks(idxs(2)),0] ;
    end

end










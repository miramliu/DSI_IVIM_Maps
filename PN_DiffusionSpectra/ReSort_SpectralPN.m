% for the three part peaks, sort into blood, tubule, and tissue
% ML 2024 march 14thth

%%NOTE, THRESHOLD FOR BLOOD WAS CHANGED FROM 10 TO 50, BUT IS KEPT AT 10 FOR PAPER AND PRESENTATION. 50 SEEMED BEST FOR ALLOGRAFTS

function SortedresultsPeaks = ReSort_SpectralPN(resultsPeaks)

    %% for note... 
    %disp('------------------------------------------------------------------------- ')
    f_blood = resultsPeaks(1);
    f_tubule = resultsPeaks(2);
    f_tissue = resultsPeaks(3);
    D_blood = resultsPeaks(4);
    D_tubule = resultsPeaks(5);
    D_tissue = resultsPeaks(6);
    %SortedresultsPeaks = [f_blood, f_tubule, f_tissue, f_fibro, D_blood, D_tubule, D_tissue, D_fibro];

    CompartmentFractions = [f_blood, f_tubule, f_tissue];
    CompartmentDiffusions = [D_blood, D_tubule, D_tissue];

    if nnz(CompartmentFractions) > 1
        if nnz(CompartmentFractions) ==2
            idxs = find(CompartmentDiffusions); %find which ones are non-zero
            %difference = (abs(CompartmentDiffusions-1.5)); % find all value distance from assumed diffusion peak of 1.5
            %[~, minidx] = min([difference(idxs(1)), difference(idxs(2))]); %find the closest to diffusion of the 2 non-zero peaks
            %[~, maxidx] = max([difference(idxs(1)), difference(idxs(2))]); %find the furthest from diffusion of the 2 non-zero peaks
            CompartmentDiffusions(CompartmentDiffusions == 0 ) = NaN; %set to zero
            [~, minidx] = min(CompartmentDiffusions); %smallest diffusion
            [~, maxidx] = max(CompartmentDiffusions); %largest diffusion

            tissue_idx = idxs(minidx); %the diffusion index is the index of the closest to 1.5 10-3 
            max_idx = idxs(maxidx); %the bigger difference, so inelegant sorry. slow dya. 
            
            % now we know which one is the tissue fraction
            f_tissue= CompartmentFractions(tissue_idx);
            D_tissue= CompartmentDiffusions(tissue_idx);
            %if non-tissue peak is bigger
            if CompartmentDiffusions(max_idx) > CompartmentDiffusions(tissue_idx) %assumed true, but lazy so keeping this.

                %if it's > 50, it's blood flow, else it's tubular?
                if CompartmentDiffusions(max_idx) > 50 %Changed to 50. which was used for allograft. 
                    f_blood = CompartmentFractions(max_idx);
                    D_blood = CompartmentDiffusions(max_idx);
                    
                    SortedresultsPeaks = [f_blood, 0, f_tissue, D_blood, 0, D_tissue];
                else %if it's < 10
                    f_tubule = CompartmentFractions(max_idx);
                    D_tubule = CompartmentDiffusions(max_idx);

                    SortedresultsPeaks = [0, f_tubule, f_tissue, 0, D_tubule, D_tissue];
                end
            end
            
        else % it's in descending order... 

            SortedresultsPeaks = [f_blood, f_tubule, f_tissue, D_blood, D_tubule, D_tissue];
        end
    else %if only one peak... then that one peak has got to be the diffusion one... 
        idxs = find(resultsPeaks); %find which one is non-zero
        SortedresultsPeaks = [0,0,resultsPeaks(idxs(1)),0,0,resultsPeaks(idxs(2))] ;
    end

end










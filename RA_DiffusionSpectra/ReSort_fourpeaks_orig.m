%%  four part peaks, sort into blood, tubule, tissue, and fibrosis
% ML Jan 31 2024
% written originally by location along diffusion coefficient spectra

function SortedresultsPeaks = ReSort_fourpeaks_orig(resultsPeaks)

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

    CompartmentFractions = [f_blood, f_tubule, f_tissue, f_fibro];
    CompartmentDiffusions = [D_blood, D_tubule, D_tissue, D_fibro];

    if nnz(CompartmentFractions) > 1
        if nnz(CompartmentFractions) ==2
            idxs = find(CompartmentDiffusions); %find which ones are non-zero
            difference = (abs(CompartmentDiffusions-1.5)); % find all value distance from assumed diffusion peak 
            [~, minidx] = min([difference(idxs(1)), difference(idxs(2))]); %find the closest to diffusion of the 3 non-zero peaks
            [~, maxidx] = max([difference(idxs(1)), difference(idxs(2))]); %find the closest to diffusion of the 3 non-zero peaks

            tissue_idx = idxs(minidx); %the diffusion index is the index of the closest to 1.5 10-3 
            max_idx = idxs(maxidx); %the bigger difference, so inelegant sorry. slow dya. 
            
            % now we know which one is the tissue fraction
            f_tissue= CompartmentFractions(tissue_idx);
            D_tissue= CompartmentDiffusions(tissue_idx);
            %if non-tissue peak is bigger
            if CompartmentDiffusions(max_idx) > CompartmentDiffusions(tissue_idx)

                %if it's > 10, it's blood flow
                if CompartmentDiffusions(max_idx) > 10 
                    f_blood = CompartmentFractions(max_idx);
                    D_blood = CompartmentDiffusions(max_idx);
                    
                    SortedresultsPeaks = [f_blood, 0, f_tissue, 0, D_blood, 0, D_tissue, 0];
                else %if it's < 10
                    f_tubule = CompartmentFractions(max_idx);
                    D_tubule = CompartmentDiffusions(max_idx);

                    SortedresultsPeaks = [0, f_tubule, f_tissue, 0, 0, D_tubule, D_tissue, 0];
                end

            else %if it's < tissue
                f_fibro = CompartmentFractions(max_idx);
                D_fibro = CompartmentDiffusions(max_idx);

                SortedresultsPeaks = [0, 0, f_tissue, f_fibro, 0, 0, D_tissue, D_fibro];
            end
            
        elseif nnz(CompartmentFractions) ==3 
            idxs = find(CompartmentDiffusions); %find which ones are non-zero
            difference = (abs(CompartmentDiffusions-1.5)); % find all value distance from assumed diffusion peak 
            [~, minidx] = min([difference(idxs(1)), difference(idxs(2)), difference(idxs(3))]); %find the closest to diffusion of the 3 non-zero peaks
            [~, maxidx] = max([difference(idxs(1)), difference(idxs(2)), difference(idxs(3))]); %find the closest to diffusion of the 3 non-zero peaks

            tissue_idx = idxs(minidx); %the diffusion index is the index of the closest to 1.5 10-3 
            max_idx = idxs(maxidx); %the bigger difference, so inelegant sorry. slow dya. 
            max_and_min = [tissue_idx, max_idx];
            all = [1,2,3];
            middle_idx = all(~ismember(all,max_and_min)); % the one that isn't furthest from diffusion...
            
            f_tissue= CompartmentFractions(tissue_idx);
            D_tissue= CompartmentDiffusions(tissue_idx);

            %CompartmentDiffusions(tissue_idx)
            %min(CompartmentDiffusions) 
            %if it's the smallest 
            if CompartmentDiffusions(tissue_idx) == min(nonzeros(CompartmentDiffusions))
                f_blood = CompartmentFractions(max_idx);
                D_blood = CompartmentDiffusions(max_idx);
                f_tubule = CompartmentFractions(middle_idx);
                D_tubule = CompartmentDiffusions(middle_idx);
                SortedresultsPeaks = [f_blood, f_tubule, f_tissue, 0, D_blood, D_tubule, D_tissue, 0];
                %disp('check!!')
            else %if one of them is bigger than tissue and the other is smaller... 
                % if max diff peak > tissue peak
                if CompartmentDiffusions(max_idx) > CompartmentDiffusions(tissue_idx) 
                    %either it is tubule or perfusion
                    %if it's > 10, it's blood flow
                    if CompartmentDiffusions(max_idx) > 10 
                        f_blood = CompartmentFractions(max_idx); %blood is the other max-difference
                        D_blood = CompartmentDiffusions(max_idx);
                        
                        f_fibro = CompartmentFractions(middle_idx); %fibro is the middle-difference
                        D_fibro = CompartmentDiffusions(middle_idx);

                        SortedresultsPeaks = [f_blood, 0, f_tissue, f_fibro, D_blood, 0, D_tissue, D_fibro];
                    else %if it's < 10
                        f_tubule = CompartmentFractions(max_idx); %tubule is the other max-difference
                        D_tubule = CompartmentDiffusions(max_idx);

                        f_fibro = CompartmentFractions(middle_idx); %fibro is the middle-difference
                        D_fibro = CompartmentDiffusions(middle_idx);
                        SortedresultsPeaks = [0, f_tubule, f_tissue, f_fibro, 0, D_tubule, D_tissue, D_fibro];
                    end
                else % if the tissue is >  other, then other is fibrosis (?)
                    f_fibro = CompartmentFractions(max_idx);
                    D_fibro = CompartmentDiffusions(max_idx);
                    if CompartmentDiffusions(middle_idx) > 10 
                        f_blood = CompartmentFractions(middle_idx); %blood is the other max-difference
                        D_blood = CompartmentDiffusions(middle_idx);

                        SortedresultsPeaks = [f_blood, 0, f_tissue, f_fibro, D_blood, 0, D_tissue, D_fibro];
                    else %if it's < 10
                        f_tubule = CompartmentFractions(middle_idx); %tubule is the other max-difference
                        D_tubule = CompartmentDiffusions(middle_idx);

                        SortedresultsPeaks = [0, f_tubule, f_tissue, f_fibro, 0, D_tubule, D_tissue, D_fibro];
                    end
                end

            end

        else % it's in descending order... 

            SortedresultsPeaks = [f_blood, f_tubule, f_tissue, f_fibro, D_blood, D_tubule, D_tissue, D_fibro];
        end
    else %if only one peak... then that one peak has got to be the diffusion one... 
        idxs = find(resultsPeaks); %find which one is non-zero
        SortedresultsPeaks = [0,0,resultsPeaks(idxs(1)),0,0,0,resultsPeaks(idxs(2)),0] ;
    end

end










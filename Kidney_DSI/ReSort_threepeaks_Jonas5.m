% for the three part peaks, sort into blood, tubule, and tissue
% ML 2024 May 22nd


% ML june 26 2024
% now corrects to be jonas way of sorting by dffusion coefficient but with threhsold of 5!


function SortedresultsPeaks = ReSort_threepeaks_Jonas5(resultsPeaks)

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

    [bloodf, tubulef, tissuef, bloodD, tubuleD, tissueD] = deal(0);
    if nnz(CompartmentFractions) > 0
        idxs = find(CompartmentDiffusions); %find which ones are non-zero
        for j=1:length(idxs)
            index = idxs(j); %the jth index that is non zero....
            if ~isnan(CompartmentDiffusions(index)) % if it's not NaN
                if CompartmentDiffusions(index) < 5
                    if tissueD ==0 
                        tissueD = CompartmentDiffusions(index);
                        tissuef = CompartmentFractions(index);
                    else %if more than one compartment falls within this boundary
                        tissueD = (tissueD*tissuef + CompartmentDiffusions(index)*CompartmentFractions(index))./2; % weighted average of diffusion coefficients
                        tissuef = tissuef + CompartmentFractions(index); %sum of the total fraction
                    end
                elseif CompartmentDiffusions(index) < 50 && CompartmentDiffusions(index) >=5
                    if tubuleD ==0 
                        tubuleD = CompartmentDiffusions(index);
                        tubulef = CompartmentFractions(index);
                    else %if more than one compartment falls within this boundary
                        tubuleD = (tubuleD*tubulef + CompartmentDiffusions(index)*CompartmentFractions(index))./2; % weighted average of diffusion coefficients
                        tubulef = tubulef + CompartmentFractions(index); %sum of the total fraction
                    end
                elseif CompartmentDiffusions(index) >= 50
                    if bloodD ==0 
                        bloodD = CompartmentDiffusions(index);
                        bloodf = CompartmentFractions(index);
                    else %if more than one compartment falls within this boundary
                        bloodD = (bloodD*bloodf + CompartmentDiffusions(index)*CompartmentFractions(index))./2; % weighted average of diffusion coefficients
                        bloodf = bloodf + CompartmentFractions(index); %sum of the total fraction
                    end
                else
                    disp(CompartmentDiffusions(index))
                    error('there is a bug somewhere, all values should fall within these boundaries')
                end
            else % if it is NaN
                if index ==1  %then blood is zero
                    [bloodD, bloodf]=deal(0);
                elseif index ==2%then tubule is zero
                    [tubuleD, tubulef]=deal(0);
                elseif index ==3
                    [tissueD, tissuef]=deal(0);
                else
                    disp(index)
                    error('what is up with the indexing')
                end
            end
        end
    end
    SortedresultsPeaks = [bloodf, tubulef, tissuef, bloodD, tubuleD, tissueD];
end

















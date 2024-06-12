%% bulky code to recomparmentalize multi-exponential
% the original sheet is just the standard output
% will then sort into the 3 components based on limits/compartmentalization
% based on the diffusion coefficient

function RecompartmentalizeExcel_voxelwise()
    pathtodata = '/Users/miraliu/Desktop/ML_PartialNephrectomy_Export';
    ExcelFileName=[pathtodata, '/','PN_IVIM_DiffusionSpectra.xlsx']; % All results will save in excel file

    Table = readcell(ExcelFileName, 'Sheet','Voxelwise');

    for j = 1:size(Table,1)
        Identifying_Info = Table(j,1:2);
        %rsq = Table(j,9);

        disp(j)
        try
            resultsPeaks = cell2mat(Table(j,[19 24 29])); % median D
        catch
            %check for missing values and set to zero
            dummy = Table(j,[19 24 29]);
            for i = 1:6
                if strcmp(class(dummy{i}),'missing')
                    dummy{i} = 0;
                end
            end
            resultsPeaks = cell2mat(dummy);
        end

        if nnz(~resultsPeaks) > 0 
            resultsPeaks = RecompartmentalizeMultiexponential_voxelwise(resultsPeaks);
        end

        Existing_Data = readcell(ExcelFileName,'Sheet','Recompart Voxelwise','Range','A:B'); %read only identifying info that already exists
        MatchFunc = @(A,B)cellfun(@isequal,A,B);
        idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));
    
        if sum(idx)==0
            disp('saving data in excel')
            dataarray= {resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6)};
            Export_Cell = [Identifying_Info,dataarray];
            writecell(Export_Cell,ExcelFileName,'Sheet', 'Recompart Voxelwise','WriteMode','append')
        end

    end

    

end

%% Given fractions and diffusion coefficients will correct order
% into fast, medium, and slow if there are < 3 of the expected
% tri-exponential 

% Mira Liu Aug 24 2023


function dummyresultspeaks = RecompartmentalizeMultiexponential_voxelwise(resultsPeaks)
    dummyresultspeaks = resultsPeaks;
    idx = find(resultsPeaks);
    correctthese = idx(idx>3); %get the diffusion coefficients that are not zero
    for k =1:numel(correctthese) %for the diffusion coefficients that need to be shuffed appropriately
        j = correctthese(k);
        n = DetermineComponent(resultsPeaks(j)); %see the diffusion sspeed of this peak
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
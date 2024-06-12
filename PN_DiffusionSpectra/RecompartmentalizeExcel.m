%% bulky code to recomparmentalize multi-exponential
% the original sheet is just the standard output
% will then sort into the 3 components based on limits/compartmentalization
% based on the diffusion coefficient

function RecompartmentalizeExcel()
    pathtodata = '/Users/miraliu/Desktop/ML_PartialNephrectomy_Export';
    ExcelFileName=[pathtodata, '/','PN_IVIM_DiffusionSpectra.xlsx']; % All results will save in excel file

    Table = readcell(ExcelFileName, 'Sheet','Original');

    for j = 1:size(Table,1)
        Identifying_Info = Table(j,1:2);
        %rsq = Table(j,9);

        disp(j)
        try
            resultsPeaks = cell2mat(Table(j,3:8));
        catch
            %check for missing values and set to zero
            dummy = Table(j,3:8);
            for i = 1:6
                if strcmp(class(dummy{i}),'missing')
                    dummy{i} = 0;
                end
            end
            resultsPeaks = cell2mat(dummy);
        end

        if nnz(~resultsPeaks) > 0 
            resultsPeaks = RecompartmentalizeMultiexponential(resultsPeaks);
        end

        Existing_Data = readcell(ExcelFileName,'Sheet','Recompartmentalized','Range','A:B'); %read only identifying info that already exists
        MatchFunc = @(A,B)cellfun(@isequal,A,B);
        idx = cellfun(@(Existing_Data)all(MatchFunc(Identifying_Info,Existing_Data)),num2cell(Existing_Data,2));
    
        if sum(idx)==0
            disp('saving data in excel')
            dataarray= {resultsPeaks(1),resultsPeaks(2),resultsPeaks(3),resultsPeaks(4),resultsPeaks(5),resultsPeaks(6)};
            Export_Cell = [Identifying_Info,dataarray];
            writecell(Export_Cell,ExcelFileName,'Sheet', 'Recompartmentalized','WriteMode','append')
        end

    end

    

end
%% to create image of kidney!

function StackedProcessed = CreateSpectralFigure()
    %StackedDicoms = MakeStackedDicoms();
    load('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_055_TraceForFigure/AllograftMask.mat', 'AllograftMask')
    load('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_055_TraceForFigure/StackedDicoms.mat','StackedDicoms')

    AllograftMaskedDicoms = squeeze(StackedDicoms(:,:,:)).*AllograftMask;
    [nx,ny] = size(squeeze(StackedDicoms(:,:,1)));
    StackedProcessed = zeros(nx, ny, 10);
    for j=1:nx
        for k = 1:ny
            if AllograftMaskedDicoms(j,k,1) > 0 % if it's nonzero
                currcurve = squeeze(AllograftMaskedDicoms(j,k,:))/AllograftMaskedDicoms(j,k,1); %normalized
                %disp([j k])
                [~, rsq, ~, ~, resultsPeaks] = RunNNLS_ML_fourpeaks(currcurve);
                SortedresultsPeaks = ReSort_fourpeaks(resultsPeaks);
                if rsq> 0.7
                    StackedProcessed(j, k,1) = SortedresultsPeaks(1); %f vasc
                    StackedProcessed(j, k,2) = SortedresultsPeaks(2); % f tubule
                    StackedProcessed(j, k,3) = SortedresultsPeaks(3); % f tissue
                    StackedProcessed(j, k,4) = SortedresultsPeaks(4); % f fibro
                    StackedProcessed(j, k,5) = SortedresultsPeaks(4) + SortedresultsPeaks(3); % f combined
                    StackedProcessed(j, k,6) = SortedresultsPeaks(5); % D vasc
                    StackedProcessed(j, k,7) = SortedresultsPeaks(6); % D tubule
                    StackedProcessed(j, k,8) = SortedresultsPeaks(7); % D tissue
                    StackedProcessed(j, k,9) = SortedresultsPeaks(8); % D fibro
                    StackedProcessed(j, k,10) = (SortedresultsPeaks(7)*SortedresultsPeaks(3) + SortedresultsPeaks(8)*SortedresultsPeaks(4))/(SortedresultsPeaks(3) + SortedresultsPeaks(4));
                else
                    StackedProcessed(j,k,1) = 0;
                    StackedProcessed(j,k,2) = 0;
                    StackedProcessed(j,k,3) = 0;
                    StackedProcessed(j,k,4) = 0;
                    StackedProcessed(j,k,5) = 0;
                    StackedProcessed(j,k,6) = 0;
                    StackedProcessed(j,k,7) = 0;
                    StackedProcessed(j,k,8) = 0;
                    StackedProcessed(j,k,9) = 0;
                    StackedProcessed(j,k,10) = 0;
                end
            end
        end
    end

    fD_spectral = MakeFDmasks(StackedProcessed);
    
end


function StackedDicoms = MakeStackedDicoms()
    %% Stack dicoms
    check = dicomread('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_055_TraceForFigure/IM-0028-0001-0001.dcm');
    [nx,ny] = size(check);
    
    StackedDicoms = zeros(nx,ny,9); %stacked dicoms nx, ny, by b-values
    for j = 0:8 %for 9 b values
        k = 7+(j*16); %(get each of the 7 slices for all 9 b-values
        if k < 10
            k = strcat('00', string(k));
        elseif k < 100
            k = strcat('0', string(k));
        end
        strcat('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_055_TraceForFigure/IM-0028-00',string(k), '-0001.dcm')
        X = dicomread(strcat('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_055_TraceForFigure/IM-0028-0',string(k), '-0001.dcm'));
        StackedDicoms(:,:,j+1)=X;
    
    end
end




function fD_spectral = MakeFDmasks(StackedProcessed)
    fD_vasc = squeeze(StackedProcessed(:,:,1)).*squeeze(StackedProcessed(:,:,5));
    fD_tubule = squeeze(StackedProcessed(:,:,2)).*squeeze(StackedProcessed(:,:,6));
    fD_parench = squeeze(StackedProcessed(:,:,3)).*squeeze(StackedProcessed(:,:,7));
    fD_fibro = squeeze(StackedProcessed(:,:,4)).*squeeze(StackedProcessed(:,:,8));
    fD_slow = squeeze(StackedProcessed(:,:,5)).*squeeze(StackedProcessed(:,:,9));
    
    fD_spectral=zeros(84, 200, 3);
    fD_spectral(:, :, 1) = fD_vasc;
    fD_spectral(:, :, 2) = fD_tubule;
    fD_spectral(:, :, 3) = fD_parench;
    fD_spectral(:, :, 3) = fD_fibro;
    fD_spectral(:, :, 3) = fD_slow;
    save('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_055_TraceForFigure/StackedSpectral_fD.mat', 'fD_spectral');

end
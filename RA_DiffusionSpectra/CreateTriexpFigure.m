%% to create image of kidney!

function StackedProcessed = CreateTriexpFigure()
    %StackedDicoms = MakeStackedDicoms();
    load('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_028_TraceForFigure/AllograftMask.mat', 'AllograftMask')
    load('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_028_TraceForFigure/StackedDicoms.mat','StackedDicoms')

    AllograftMaskedDicoms = squeeze(StackedDicoms(:,:,:)).*AllograftMask;
    [nx,ny] = size(squeeze(StackedDicoms(:,:,1)));
    StackedProcessed = zeros(nx, ny, 7);
    for j=1:nx
        for k = 1:ny
            if AllograftMaskedDicoms(j,k,1) > 0 % if it's nonzero
                currcurve = squeeze(AllograftMaskedDicoms(j,k,:))/AllograftMaskedDicoms(j,k,1); %normalized
                %disp([j k])
                bvals = [0,10,30,50,80,120,200,400,800];
                [SortedresultsPeaks, rsq] = TriExpIVIMLeastSquaresEstimation(currcurve,bvals);
                if rsq> 0.7
                    StackedProcessed(j, k,1) = SortedresultsPeaks(1); % f vasc
                    StackedProcessed(j, k,2) = SortedresultsPeaks(2); % f tubule
                    StackedProcessed(j, k,3) = SortedresultsPeaks(3); % f tissue
                    StackedProcessed(j, k,4) = SortedresultsPeaks(4); % D vasc
                    StackedProcessed(j, k,5) = SortedresultsPeaks(5); % D tubule
                    StackedProcessed(j, k,6) = SortedresultsPeaks(6); % D tissue
                    StackedProcessed(j, k,7) = rsq; % rsq
                else
                    StackedProcessed(j,k,1) = 0;
                    StackedProcessed(j,k,2) = 0;
                    StackedProcessed(j,k,3) = 0;
                    StackedProcessed(j,k,4) = 0;
                    StackedProcessed(j,k,5) = 0;
                    StackedProcessed(j,k,6) = 0;
                    StackedProcessed(j,k,7) = rsq;
                end
            end
        end
    end

    save('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_028_TraceForFigure/StackedProcessed.mat', 'StackedProcessed');


    %% then save fd masks


    fD_vasc = squeeze(StackedProcessed(:,:,1)).*squeeze(StackedProcessed(:,:,4));
    fD_tubule = squeeze(StackedProcessed(:,:,2)).*squeeze(StackedProcessed(:,:,5));
    fD_parench = squeeze(StackedProcessed(:,:,3)).*squeeze(StackedProcessed(:,:,6));
    fD_triexp=zeros(84, 200, 3);
    fD_triexp(:, :, 1) = fD_vasc;
    fD_triexp(:, :, 2) = fD_tubule;
    fD_triexp(:, :, 3) = fD_parench;
    save('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_028_TraceForFigure/StackedTriexp_fD.mat', 'fD_triexp');
end


function StackedDicoms = MakeStackedDicoms()
    %% Stack dicoms
    % first get trace ticoms from database to computer, put path to them here
    check = dicomread('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_028_TraceForFigure/IM-0028-0001-0001.dcm');
    [nx,ny] = size(check);
    
    StackedDicoms = zeros(nx,ny,9); %stacked dicoms nx, ny, by b-values
    for j = 0:8 %for 9 b values
        k = 7+(j*16); %(get each of the 7 slices for all 9 b-values
        if k < 10
            k = strcat('00', string(k));
        elseif k < 100
            k = strcat('0', string(k));
        end
        strcat('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_028_TraceForFigure/IM-0028-00',string(k), '-0001.dcm')
        X = dicomread(strcat('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_028_TraceForFigure/IM-0028-0',string(k), '-0001.dcm'));
        StackedDicoms(:,:,j+1)=X;
    
    end

    % then save
    save('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_028_TraceForFigure/StackedDicoms.mat','StackedDicoms')

    % then make allograft mask!
    imshow(squeeze(StackedDicoms(:,:,5)),[])
    AllograftMask = roipoly;
    save('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_028_TraceForFigure/AllograftMask.mat', 'AllograftMask');

end
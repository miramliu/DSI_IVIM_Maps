% given a mat file, run spectral analysis

% mat file in the format of C. Federau's matfiles. 
% 20 slices, 16 b values.
function RunKidney_DSI_IVIM(varargin)


    % if you have only the raw data that needs to be made into a dicom stack, input path to dicoms
    if nargin > 2
        dicomfolderpath = varargin{1};
        dicomstart = varargin{2};
        dicomend = varargin{3};
        slice = varargin{4};
        dicompath = fullfile(dicomfolderpath,dicomstart);
    
        % load the stacked dicoms and the allograft mask
        try 
            loaded = load(fullfile(dicomfolderpath,'StackedDicoms.mat'),'StackedDicoms');
            StackedDicoms = loaded.StackedDicoms;
        catch
            StackedDicoms = MakeStackedDicoms(dicompath, dicomend,slice);
            save(fullfile(dicomfolderpath,'StackedDicoms.mat'),'StackedDicoms');
    
        end
    
        try 
            loaded = load(fullfile(dicomfolderpath,'AllograftMask.mat'),'AllograftMask');
            AllograftMask = loaded.AllograftMask;
        catch
            disp('ready to draw an ROI?')
            pause()
            figure,imshow(squeeze(StackedDicoms(:,:,1)),[]),truesize([400 400])
            AllograftMask = roipoly;
            save(fullfile(dicomfolderpath,'AllograftMask.mat'),'AllograftMask');
            close();
        end
    elseif nargin ==2  %have already generated a dicom stack, load them for processing
        dicomfolderpath = varargin{1};
        slice = varargin{2};
        loaded = load(fullfile(dicomfolderpath,'AllograftMask.mat'),'AllograftMask');
        AllograftMask = loaded.AllograftMask;
        loaded = load(fullfile(dicomfolderpath,'StackedDicoms.mat'),'StackedDicoms');
        StackedDicoms = loaded.StackedDicoms;
    else
        error('Input dicom folder path, dicom name starter and dicome name end, and slice, or folder to the pre-processed mat files and slice')
    end


    AllograftMaskedDicoms = squeeze(StackedDicoms(:,:,:)).*AllograftMask;


    Bvalues = [0, 10, 30, 50, 80, 120, 200, 400, 800 ];
    disp(['started: '  + string(datetime("now"))])


    AllograftMaskedDicoms = permute(AllograftMaskedDicoms, [3,1,2]); %to have it bval, nx, ny

    [parameter_map, spectral_map] =  DSI_FIT_continuousNNLS_kidney(Bvalues,AllograftMaskedDicoms);



    IVIM_DSI.Parameter_Volume     = parameter_map;
    IVIM_DSI.Spectral_Volume      = spectral_map; %% file size too large... can only save peaks themselves for one slice at a time. Matlab limitation?
    

    SaveDIR = fullfile(dicomfolderpath, "IVIM_DSI" + "_slice_" + string(slice) + ".mat");
    save (SaveDIR, 'IVIM_DSI');
    disp(['saved.... ' SaveDIR])


    disp(['Completed: ' + string(datetime("now"))])
end



%% some nested functions
function StackedDicoms = MakeStackedDicoms(dicompath, dicomend, slice)
    %% Stack dicoms
    check = dicomread(strcat(dicompath,'0001', dicomend));
    [nx,ny] = size(check);
    
    slices_number = 10; %often 16. can automate this at some point to just check the total number of dicoms and divide by number of b values... 07/05/2024
    StackedDicoms = zeros(nx,ny,9); %stacked dicoms nx, ny, by b-values
    for j = 0:8 %for 9 b values
        k = slice+(j*slices_number); %(get each of the 7 slices for all 9 b-values
        if k < 10
            k = strcat('000', string(k));
        elseif k < 100
            k = strcat('00', string(k));
        elseif k < 1000
            k = strcat('0', string(k));
        end
        %strcat('/Users/miraliu/Desktop/Data/RA/RenalAllograft_IVIM/RA_01_028_TraceForFigure/IM-0028-',string(k), '-0001.dcm')
        X = dicomread(strcat(dicompath,string(k), dicomend));
        StackedDicoms(:,:,j+1)=X;
    
    end
end






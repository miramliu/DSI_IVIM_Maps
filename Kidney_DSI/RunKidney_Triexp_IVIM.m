% given a mat file, run spectral analysis

% mat file in the format of C. Federau's matfiles. 
% 20 slices, 16 b values.
function RunKidney_Triexp_IVIM(varargin)


        % if you have only the raw data that needs to be made into a dicom stack, input path to dicoms
    if nargin > 2
        dicomfolderpath = varargin{1};
        dicomstart = varargin{2};
        dicomend = varargin{3};
        slice = varargin{4};
    
        % load the stacked dicoms and the allograft mask
        try 
            loaded = load(fullfile(dicomfolderpath,'StackedDicoms'+ "_slice_" + string(slice) + ".mat"),'StackedDicoms');
            StackedDicoms = loaded.StackedDicoms;
        catch
            StackedDicoms = MakeStackedDicoms(dicomfolderpath,dicomstart, dicomend,slice);
            save(fullfile(dicomfolderpath,'StackedDicoms' + "_slice_" + string(slice) + ".mat"),'StackedDicoms');
    
        end
    
        try 
            loaded = load(fullfile(dicomfolderpath,'AllograftMask' + "_slice_" + string(slice) + ".mat"),'AllograftMask');
            AllograftMask = loaded.AllograftMask;
        catch
            disp('ready to draw an ROI?')
            pause()
            figure,imshow(squeeze(StackedDicoms(:,:,1)),[]),truesize([400 400])
            AllograftMask = roipoly;
            save(fullfile(dicomfolderpath,'AllograftMask' + "_slice_" + string(slice) + ".mat"),'AllograftMask');
            close();
        end
    elseif nargin ==2  %have already generated a dicom stack, load them for processing
        dicomfolderpath = varargin{1};
        slice = varargin{2};
        loaded = load(fullfile(dicomfolderpath,'AllograftMask'+ "_slice_" + string(slice) + ".mat"),'AllograftMask');
        AllograftMask = loaded.AllograftMask;
        loaded = load(fullfile(dicomfolderpath,'StackedDicoms'+ "_slice_" + string(slice) + ".mat"),'StackedDicoms');
        StackedDicoms = loaded.StackedDicoms;
    else
        error('Input dicom folder path, dicom name starter and dicome name end, and slice, or folder to the pre-processed mat files and slice')
    end

    AllograftMaskedDicoms = squeeze(StackedDicoms(:,:,:)).*AllograftMask;


    Bvalues = [0, 10, 30, 50, 80, 120, 200, 400, 800 ];
    disp(['started: '  + string(datetime("now"))])


    AllograftMaskedDicoms = permute(AllograftMaskedDicoms, [3,1,2]); %to have it bval, nx, ny

    parameter_map =  CreateTriexpFigure(Bvalues,AllograftMaskedDicoms);



    IVIM_Triexp.Parameter_Volume     = parameter_map;
    
    SaveDIR = fullfile(dicomfolderpath, "IVIM_Triexp" + "_slice_" + string(slice) + ".mat");
    save (SaveDIR, 'IVIM_Triexp');
    disp(['saved.... ' SaveDIR])


    disp(['Completed: ' + string(datetime("now"))])
end



%% some nested functions
function StackedDicoms = MakeStackedDicoms(dicomfolderpath, dicomstart, dicomend, slice)
    dicompath = fullfile(dicomfolderpath,dicomstart);

    %% Stack dicoms
    check = dicomread(strcat(dicompath,'0001', dicomend));
    [nx,ny] = size(check);

    % get number of slices
    filenames = dir(fullfile(dicomfolderpath,'*.dcm'));
    total_Im = numel(filenames);
    
    slices_number = total_Im/9; %often 16. can automate this at some point to just check the total number of dicoms and divide by number of b values... 07/05/2024
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



%% to create image of kidney!

function parameter_map = CreateTriexpFigure(b_values, ImageStack)


    [N_Bvalues, nx, ny] = size(ImageStack);
    parameter_map = zeros(nx,ny,6);
    for j=1:nx
        for k=1:ny
            if (ImageStack(1,j,k) > 0 ) 

                % for normal b values
                SignalInput = squeeze(double(ImageStack(1:N_Bvalues,j,k)/ImageStack(1,j,k))); 
                %disp([j k]);\
                [SortedresultsPeaks, rsq] = TriExpIVIMLeastSquaresEstimation(SignalInput,b_values);
                if rsq> 0.7
                    parameter_map(j, k,1) = SortedresultsPeaks(1); % f vasc
                    parameter_map(j, k,2) = SortedresultsPeaks(2); % f tubule
                    parameter_map(j, k,3) = SortedresultsPeaks(3); % f tissue
                    parameter_map(j, k,4) = SortedresultsPeaks(4); % D vasc
                    parameter_map(j, k,5) = SortedresultsPeaks(5); % D tubule
                    parameter_map(j, k,6) = SortedresultsPeaks(6); % D tissue
                    %parameter_map(j, k,7) = rsq; % rsq
                else
                    parameter_map(j,k,1) = 0;
                    parameter_map(j,k,2) = 0;
                    parameter_map(j,k,3) = 0;
                    parameter_map(j,k,4) = 0;
                    parameter_map(j,k,5) = 0;
                    parameter_map(j,k,6) = 0;
                    %parameter_map(j,k,7) = rsq;
                end
            end
        end
    end

end


% use this to test:

% b = [0 10 20 50 80 100 250 500 1000];
% signal = 100*(0.15*exp(-b*0.2) + 0.85*exp(-b*0.001));
% data = signal + 2*randn(size(b));
% [MMSE,MAP,curveFit,logPr,logLh,logPost] = IVIMBayesianEstimation(b,data);
% data = signal + 15*randn(size(b));
% [MMSE,MAP,curveFit,logPr,logLh,logPost] = IVIMBayesianEstimation(b,data);


%% editted by ML Sep 15 2023 to be tri-exponential
%% using starting values from healthy kidney used in JP & TG paper
function [results, rsq] = TriExpIVIMLeastSquaresEstimation(data,bvals)

% Starting Diffusion Parameters (Baseline)
diff_fast   = 0.180;
diff_med    = 0.0058; %[0.006 0.007 0.008 0.009 0.010];
diff_slow   = 0.0015;
frac_fast   = 0.10;
frac_med    = 0.30;
frac_slow   = 0.60;

%plot(bvals,data)
% trying to just fit in one shot... 
[f, ~] = fit(bvals', data  , ...   
            'A*exp(-x*B) + C*exp(-x*D)+E*exp(-x*G)' , ... %this is the tri-exponential, A = 1 - C - E to make sure they all add up to 1.0
            'Startpoint', [frac_fast, diff_fast, frac_med, diff_med, frac_slow, diff_slow]                  , ... % SWITCHED ORDER to D, f 12/28/21
            'Lower'     , [0.0 0.0 0.0 0.0 0.0 0.0]                        , ... 
            'MaxIter'   , 100000                              , ...
            'Upper'     , [1 .3 1 .05 1 .005 ]                         , ... %vague tri-exponential limits
            'TolFun'    , 10e-30                             );

fastfract = f.A;
medfract = f.C;
slowfract = f.E;
fastdiff = f.B;
meddiff = f.D;
slowdiff = f.G;
%
% maybe try fixing diffusion if the fit isn't good enough? 
% compute curve for MMSE estimate
curveFit = fastfract*exp(-bvals*fastdiff) + medfract*exp(-bvals*meddiff) + slowfract*exp(-bvals*slowdiff);
%plot(bvals, curveFit)
% compute root square error
yresid = minus(data' ,curveFit);
SSresid = sum(yresid.^2);
SStotal = (length(data)-1) * var(data);
rsq = 1 - SSresid/SStotal;

results = [fastfract, medfract, slowfract, fastdiff, meddiff, slowdiff];


end    






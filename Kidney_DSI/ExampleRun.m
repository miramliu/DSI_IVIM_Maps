% ML 2024 July 10


% load relevant folders
addpath /Users/miraliu/Desktop/PostDocCode/DSI_IVIM_Maps/
addpath /Users/miraliu/Desktop/PostDocCode/DSI_IVIM_Maps/noise_matrix
addpath /Users/miraliu/Desktop/PostDocCode/DSI_IVIM_Maps/rNNLS
addpath /Users/miraliu/Desktop/PostDocCode/DSI_IVIM_Maps/rNNLS/nwayToolbox



% run voxel-by-voxel fit
RunKidney_DSI_IVIM('/Users/miraliu/Desktop/PostDocCode/DSI_IVIM_Maps/Kidney_DSI/Example/', 6);

% upon completion should see "IVIM_DSI_slice_6.m" file. 
% structure should contain "Parameter_Volume" which has the three compartment fractions and three compartment diffusion coefficients
% "Spectral_Volume" should contain the spectra per voxel. This can be used to view the spectra per voxel in a GUI that I have in progress. 


% once completed, load and see the "flow" maps in ml/100g/min as follows using another GUI of mine: 

load('/Users/miraliu/Desktop/PostDocCode/DSI_IVIM_Maps/Kidney_DSI/Example/IVIM_DSI_slice_6.mat')
Parameter_Volume = IVIM_DSI.Parameter_Volume;
fD_maps(:,:,1)=Parameter_Volume(:,:,1).*Parameter_Volume(:,:,4)*1.12;
fD_maps(:,:,2)=Parameter_Volume(:,:,2).*Parameter_Volume(:,:,5)*1.12;
fD_maps(:,:,3)=Parameter_Volume(:,:,3).*Parameter_Volume(:,:,6)*1.12;
imagestack(fD_maps)

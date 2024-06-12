%Arthi double reader check 
% Arthi ROIs read in IVIM 
% list of the commands run

% kidney ROIs
% done with RunNNLS_ML and CVNNLS and NNLS_result_mod_ML
%{
DiffusionSpec_Voxelwise('P001')
DiffusionSpec_Voxelwise('P002',3)
DiffusionSpec_Voxelwise('P003',3)
DiffusionSpec_Voxelwise('P006')
DiffusionSpec_Voxelwise('P007')
DiffusionSpec_Voxelwise('P008')
DiffusionSpec_Voxelwise('P009')
DiffusionSpec_Voxelwise('P010')
DiffusionSpec_Voxelwise('P012')
DiffusionSpec_Voxelwise('P013')
DiffusionSpec_Voxelwise('P014')
DiffusionSpec_Voxelwise('P015')
DiffusionSpec_Voxelwise('P017')
DiffusionSpec_Voxelwise('P018')
DiffusionSpec_Voxelwise('P019')
DiffusionSpec_Voxelwise('P020')
DiffusionSpec_Voxelwise('P021')
DiffusionSpec_Voxelwise('P022')
DiffusionSpec_Voxelwise('P024')
DiffusionSpec_Voxelwise('P025')
DiffusionSpec_Voxelwise('P026')
DiffusionSpec_Voxelwise('P027')
DiffusionSpec_Voxelwise('P028')
DiffusionSpec_Voxelwise('P029')
DiffusionSpec_Voxelwise('P030')
%}
DiffusionSpec_Voxelwise('P031')
DiffusionSpec_Voxelwise('P032')
DiffusionSpec_Voxelwise('P033')
%}


%Lesion ROIs
%{
[~,~,~,~,~] = RunNNLS_ML_Lesion('P001','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P002','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P003','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P006','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P007','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P008','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P009','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P010','Lesion');

[~,~,~,~,~] = RunNNLS_ML_Lesion('P012','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P013','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P014','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P015','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P017','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P018','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P019','Lesion');

[~,~,~,~,~] = RunNNLS_ML_Lesion('P020','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P021','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P022','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P024','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P025','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P026','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P027','Lesion');

[~,~,~,~,~] = RunNNLS_ML_Lesion('P028','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P029','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P030','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P031','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P032','Lesion');
[~,~,~,~,~] = RunNNLS_ML_Lesion('P033','Lesion');
%}








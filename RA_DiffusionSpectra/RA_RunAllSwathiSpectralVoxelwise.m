

%% Run all SWATHI renal allograft IVIM cases




% MAKE SURE THE EXCEL FILE IN THE CODE IS THE CORRECT EXPORT FILE. MUST BE SWATHI EXPORT!
%{
RA_DiffusionSpec_Voxelwise_ADC('P001')
RA_DiffusionSpec_Voxelwise_ADC('P002')
RA_DiffusionSpec_Voxelwise_ADC('P003')


RA_DiffusionSpec_Voxelwise_ADC('P006')

RA_DiffusionSpec_Voxelwise_ADC('P007') % got april 10th 2024
RA_DiffusionSpec_Voxelwise_ADC('P008') 
RA_DiffusionSpec_Voxelwise_ADC('P009')

RA_DiffusionSpec_Voxelwise_ADC('P024') % got april 10th 2024

RA_DiffusionSpec_Voxelwise_ADC('P026')
RA_DiffusionSpec_Voxelwise_ADC('P027')
RA_DiffusionSpec_Voxelwise_ADC('P028')
RA_DiffusionSpec_Voxelwise_ADC('P029')
RA_DiffusionSpec_Voxelwise_ADC('P030')
RA_DiffusionSpec_Voxelwise_ADC('P031')

RA_DiffusionSpec_Voxelwise_ADC('P041')

%}

%% site 2 (cornell)
%for center 2, change PatientNumb to RA_02 rather than RA_01 in
%RA_DiffusionSpec_Voxelwise_ADC, line 17 or 18


RA_DiffusionSpec_Voxelwise_ADC('P007')
RA_DiffusionSpec_Voxelwise_ADC('P008')
RA_DiffusionSpec_Voxelwise_ADC('P009')
RA_DiffusionSpec_Voxelwise_ADC('P010')
RA_DiffusionSpec_Voxelwise_ADC('P011')
%}


%% healthy volunteers (thank you!!)
%must change 
%{
RA_DiffusionSpec_Voxelwise_ADC('V004') %change line 16/17 to RA_01
RA_DiffusionSpec_Voxelwise_ADC('V001') %change line 16/17 to RA_02
RA_DiffusionSpec_Voxelwise_ADC('V005') %change line 16/17 to RA_01




%}
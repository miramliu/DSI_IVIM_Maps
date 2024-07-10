# DSI_IVIM_Maps

# Overview
Code written in Matlab 2023a by Mira M. Liu for processing diffusion spectrum of multi b-value DWI for multi-compartment imaging. 
It takes a stack of dicoms off the scanner, sorts them by b-value trace, fits them to a continuous diffusion spectrum, and outputs maps and spectra on a voxel-by-voxel basis as matfiles.


See "ExampleRun.m" for how to run the code.

# Code Base
This code was adapted by Mira Liu to create spectral maps. The individual nonnegative least squares fit of each signal decay is adapted from https://github.com/JoaoPeriquito/NNLS_computation_of_renal_DWI. 
Therefore, if you use any version of this code, please cite "Continuous diffusion spectrum computation for diffusion-weighted magnetic resonance imaging of the kidney tubule system" by J. Periquito & T. Gladytz et al., doi.org/10.21037/qims-20-1360, as well as "Quantification of multi-compartment flow from spectral diffusion of IVIM (DSI-IVIM)" by M. Liu et al., doi.org/TBD.


This repository is meant to be a code base, not professional software; it is meant to be forked and edited as needed.

It is set to assume a maximum of three compartments, but this maximum can be adjusted

The b-values must be changed, and number of slices adjusted if converting from dicoms to a stacked matfile for DSI post-processing.

The number of basis vectors is set to 300, but the number and range can be adjusted

# Alternates
If python for advanced DWI/IVIM is of interest, please check out https://github.com/darksim33/Pyneapple by J. Jasse and T. Gladytz.


Any questions, comments, or concerns can be sent to Mira Liu.
06/12/2024
 

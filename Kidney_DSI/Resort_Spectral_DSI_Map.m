function [Resorted_spectralmap] = Resort_Spectral_DSI_Map(varargin)

Spectral_Volume = varargin{1};
[nx,ny,~] = size(Spectral_Volume);



Resorted_spectralmap = zeros(nx, ny, 8);


ADCBasisSteps = 300; %(??)
ADCBasis = logspace( log10(5), log10(2200), ADCBasisSteps);
b_values = [0, 10, 30, 50, 80, 120, 200, 400, 800 ];

A = exp( -kron(b_values',1./ADCBasis));

%% get the peaks and resort them 
for ii=1:nx
    for jj=1:ny
        OutputDiffusionSpectrum = squeeze(Spectral_Volume(ii,jj,:));
        if sum(OutputDiffusionSpectrum) >0 
            [GeoMeanRegionADC_1,GeoMeanRegionADC_2,GeoMeanRegionADC_3,GeoMeanRegionADC_4,RegionFraction1,RegionFraction2,RegionFraction3,RegionFraction4 ] = NNLS_result_mod_ML_fourpeaks(OutputDiffusionSpectrum, ADCBasis);
            resultsPeaks(1) = RegionFraction1; %(frac_fast - RegionFraction1)./frac_fast.*100;
            resultsPeaks(2) = RegionFraction2; %(frac_med - RegionFraction2)./frac_med.*100;
            resultsPeaks(3) = RegionFraction3; %(frac_slow - )./frac_slow.*100;
            resultsPeaks(4) = RegionFraction4; %(frac_fibro - )./frac_slow.*100;
            resultsPeaks(5) = GeoMeanRegionADC_1; %(diff_fast - GeoMeanRegionADC_1./1000)./diff_fast.*100;
            resultsPeaks(6) = GeoMeanRegionADC_2; %(diff_med - GeoMeanRegionADC_2./1000)./diff_med.*100;
            resultsPeaks(7) = GeoMeanRegionADC_3; %(diff_slow - GeoMeanRegionADC_3./1000)./diff_slow.*100;
            resultsPeaks(8) = GeoMeanRegionADC_4; %(diff_fibro - GeoMeanRegionADC_3./1000)./diff_slow.*100;
            
            SortedresultsPeaks = ReSort_fourpeaks(resultsPeaks);

            Resorted_spectralmap(ii,jj,:) = [SortedresultsPeaks(1),SortedresultsPeaks(2),SortedresultsPeaks(3),SortedresultsPeaks(4),SortedresultsPeaks(5),SortedresultsPeaks(6),SortedresultsPeaks(7), SortedresultsPeaks(8)];
        end
    end
end
    




end
function PlotSortedPeaks(ii, OutputSpectrum, SortedresultsPeaks)
figure(2);
ADCBasisSteps = 300; %(??)
ADCBasis = logspace( log10(5), log10(2200), ADCBasisSteps);
semilogx((1./ADCBasis)*1000, OutputSpectrum)
hold on

%% for RA sort

xline(.8)
xline(5)
xline(50) 
%}

%% for PN sort? 
%xline(10)



title(string(ii))
y = max(OutputSpectrum)/3;
peakNames = {'vasc', 'tubule', 'tissue', 'fibro','vasc', 'tubule', 'tissue', 'fibro'};
for j = length(SortedresultsPeaks)/2+1:length(SortedresultsPeaks) 
    peakNumber = j; %get second half of the indices (to get diffusion coefficients)
    if SortedresultsPeaks(peakNumber) > 0 % for diffusion of the nonzero peaks
        %disp(SortedresultsPeaks(peakNumber))
        %disp(peakNames(peakNumber))
        text(SortedresultsPeaks(peakNumber), y, peakNames(peakNumber), 'FontSize',16)
    end
end

pause()

hold off
end
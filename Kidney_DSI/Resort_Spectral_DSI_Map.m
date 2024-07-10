function [Resorted_spectralmap] = Resort_Spectral_DSI_Map(varargin)

Parameter_Volume = varargin{1};
[slices,nx,ny,~] = size(Parameter_Volume);

if nargin==2
    RunSlices=varargin{2};
else
    RunSlices= slices;
end


Resorted_spectralmap = zeros(size(Parameter_Volume));
%% get the peaks and resort them 
for slice_ii= 1:length(RunSlices)
    slice=RunSlices(slice_ii);
    for ii=1:nx
        for jj=1:ny
            OriginalPeaks = squeeze(Parameter_Volume(slice,ii,jj,:));
            if sum(OriginalPeaks(1:3)) >0 
                SortedresultsPeaks = ReSort_fourpeaks(resultsPeaks);
                
                Resorted_spectralmap(slice,ii,jj,:) = [SortedresultsPeaks(1),SortedresultsPeaks(2),SortedresultsPeaks(3),SortedresultsPeaks(5),SortedresultsPeaks(6),SortedresultsPeaks(7)];
            end
        end
    end
    




end
% to be able to get the data for the DWI analysis... hopefully.
function SignalInput = ReadPatientDWIData_flexible_Arthi(varargin)
    if nargin == 2
        PatientNum = varargin{1}; 
        ROItype = varargin{2};
        a = 1; b = 4; %if there are 1 - 4 ROI (so C1 - C4 for example)
    elseif nargin ==3
        PatientNum = varargin{1}; 
        ROItype = varargin{2};
        if varargin{3} == 12
            a = 1; b = 2; %if only 1-2 ROIs per type (so C1-C2 for example)
        elseif varargin{3} == 34
            a = 3; b = 4; %if only 3-4 ROIs per type (so C3 - C4)
        elseif varargin{3} == 14
            a = 1; b = 4;
        end
    end

    pathtodata = '/Users/miraliu/Desktop/Data/Arthi Test ROIs/';
    pathtoCSV = [pathtodata '/' PatientNum  '_Arthi_IVIM.csv'];
    
    %read data
    DataFrame = readtable(pathtoCSV,'PreserveVariableNames', true, 'Range','A:E','Delimiter', ',');    
    ROITypeTable = DataFrame(startsWith(DataFrame.RoiName, ROItype),:);
    SignalInput = zeros(9,1);
    %average all four ROIs for analysis (CHECK IF I SHOULD DO THIS)
    for k = a:b %for each of the 4 ROIs of every type (%%CHECK!!!!!!)
        ROITypeTablesub = ROITypeTable(strcmp(ROITypeTable.RoiName, ROItype + string(k)),:); %so for example you want LK_LP_C, will check LK_LP_C1, LK_LP_C2 etc.
        
        % also make sure b-values are in order
        if ROITypeTablesub.Dynamic == [0;1;2;3;4;5;6;7;8]
            SignalInput =  SignalInput + ROITypeTablesub.RoiMean;
            %size(SignalInput)
        else
            ROITypeTablesub = sortrows(ROITypeTablesub,'Dynamic'); %order them according to dynamic, and get the mean from that
            SignalInput =  SignalInput + ROITypeTablesub.RoiMean;
        end
    end
    SignalInput = SignalInput./SignalInput(1); %normalize to b0

end

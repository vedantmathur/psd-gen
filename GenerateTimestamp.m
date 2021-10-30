function TimeStamp = GenerateTimestamp(filename,naming)
%##########################################################################
% VARIABLE DEFINITIONS:
%   tsIndexLow - beginning CSC index of the 2 hour block
%   tsLow - CSC start time stamp of the 2 hour block
%   twoHrStart - Interpolated exact start time of the 2 hour block
%   twoHrStartIndex - Index in relation to the full interpolated vector of exact start time of the 2 hour block
%   tsIndexHigh - End CSC index of the 2 hour block
%   tsHigh - CSC end time stamp of the 2 hour block
%   twoHrEnd - Interpolated exact stop time of the 2 hour block
%   twoHrEndIndex - Index in relation to the full interpolated vector of exact stop time of the 2 hour block
%   interp2HrStartIndex - Start index in relation to the CSC time stamp
%   interp2HrEndIndex - Stop index in relation to the CSC time stamp
%##########################################################################

timestamps = Nlx2MatCSC(filename,[1 0 0 0 0],0,1);   % Extract timestamp information from CSC file.
%msgbox('.dll worked','Pop-up');
timestamps = timestamps';
eelen = length(timestamps);
nsamp = 512;    % Default number of valid samples per data packet

m = 1;
n = 0;

interpLength = nsamp * eelen; % Length of interpolated time stamp vector if it were created
fileEndCheck = 1;   % Used to determine when end of CSC time stamp vector has been reached

while m < interpLength && fileEndCheck < eelen
    n =n + 1;   % Counter for index of 2 hour blocks in time stamp file that is created
    remainder = rem(m, nsamp); % Used to determine where in the nsamp bin the interpolated time stamp is in relation to the CSC time stamp.
    if isequal(m, 1)    % Check to see if at first time stamp
        tsIndexLow(n) = 1; %#ok<*AGROW>
        tsLow(n) = timestamps(1);
        %twoHrStart(n) = timestamps(1);
        twoHrStartIndex(n) = 1;
    else
        if remainder > 0
            tsIndexLow(n) = floor(m/nsamp) + 1;
            tsLow(n) = timestamps(tsIndexLow(n));
            twoHrStartIndex(n) = m;
        else
            tsIndexLow(n) = floor(m/nsamp);
            tsLow(n) = timestamps(tsIndexLow(n));
            twoHrStartIndex(n) = m;
        end
    end
    interval = (timestamps(tsIndexLow(n)+1) - tsLow(n))/nsamp; % Determine the time stamp resolution.
    twoHrStart(n) = tsLow(n) + (remainder - 1) * interval;
    highPoint = twoHrStart(n) + 7200*1000000;
    tsIndexHigh(n) = find(timestamps <= highPoint, 1, 'last');
    fileEndCheck = tsIndexHigh(n);
    tsHigh(n) = timestamps(tsIndexHigh(n));
    interpBinTsHigh(1) = tsHigh(n);
    for i = 2:nsamp
        interpBinTsHigh(i) = interval + interpBinTsHigh(i-1);
    end
    interpBinIndex = find(interpBinTsHigh <= highPoint, 1, 'last');
    twoHrEnd(n) = interpBinTsHigh(interpBinIndex);
    clear interpBinTsHigh
    twoHrEndIndex(n) = (nsamp * (tsIndexHigh(n)-1)) + interpBinIndex;
    m = twoHrEndIndex(n) + 1;  
end
clear timestamps        

%Request user input to name time stamp file:
prompt = {'Enter the filename you want to save it as: (just the name)'};
def = {'SubjectNumberDate'};
dlgTitle = 'Input for Timestamp utility';
lineNo = 1;
answer = strcat(naming,'_TS');
filename = char(answer(1,:));
timestampfile = strcat(filename,'.xlsx');
% fod = fopen(timestampfile,'w'); %Creates and opens user-named file

%Convert twoHr Indices to interp sectioned indices by 2 hr blocks:
for i = 1:n
    interp2HrStartIndex(i) = rem((twoHrStartIndex(i)-1),512) + 1;
    interp2HrEndIndex(i) = twoHrEndIndex(i) - ((tsIndexLow(i) - 1)*nsamp + 1);
%     % Write start & end times for each epoch (can be <2hr):
%     fprintf(fod,'%f\t %f\t %f\t %f\t %f\t %f\n', tsLow(i), tsHigh(i), interp2HrStartIndex(i),...
%         interp2HrEndIndex(i), twoHrStart(i), twoHrEnd(i)); 
end
% Write start & end times for each epoch to a real Excel (1997-2003 .XLS) file (can be <2hr):
xlswrite(timestampfile, [tsLow', tsHigh', interp2HrStartIndex',...
    interp2HrEndIndex', twoHrStart', twoHrEnd'], 'Sheet1');
TimeStamp = timestampfile 
end


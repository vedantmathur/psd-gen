% Includes


% Functions


% Main

% Open CSV File
T = readtable('DATA/1697_day1_frontalPSD_JH01-Jun-2020_12-9.xlsx','Sheet','PowerSpectra');


% [~,sheet_name] = xlsfinfo('DATA/1697_day1_frontalPSD_JH01-Jun-2020_12-9.xlsx');
% for k=1:numel(sheet_name)
%   data{k} = xlsread('DATA/1697_day1_frontalPSD_JH01-Jun-2020_12-9.xlsx',sheet_name{k});
% end

% Read data from columns gamma=5-10Hz
% 5Hz = 53 10Hz = 104, read all rows
R = T(:,53:104);
% plot(R(1,1))
% Average all values
% % https://www.mathworks.com/help/matlab/matlab_prog/calculations-on-tables.html#CalculationsOnTablesExample-3
surf(R)
R.AvgVec = mean(R{:,:},2);
% head(R);
% 
vec = R.AvgVec(2:end);
plot(vec)


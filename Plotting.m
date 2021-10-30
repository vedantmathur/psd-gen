function Plotting(XLSfile)
%PLOTTING Summary of this function goes here
%   Detailed explanation goes here
data = xlsread('test.xlsx');
[rows,cols] = size(data);
sz = rows-2;
time = data(3:rows,1);
freq = data(1,3:cols);
PSD = data(3:rows,3:cols);
time = reshape(time,[1,sz]);

figure();
contour(freq,time,PSD);
title("POWER SPECTRAL DENSITY(uV^2/Hz)");
xlabel("Frequency(Hz)",'fontsize',20);
ylabel("Time(s)",'fontsize',20);
zlabel("PSD",'fontsize',20);

end


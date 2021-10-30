%data = csvread('orig_data.csv');
data = xlsread('test.xlsx');

time = data(3:101,1);
freq = data(1,3:255);
PSD = data(3:101,3:255);
time = reshape(time,[1,99]);

figure();
contour(freq,time,PSD);
title("POWER SPECTRAL DENSITY(uV^2/Hz)");
xlabel("Frequency(Hz)",'fontsize',20);
ylabel("Time(s)",'fontsize',20);
zlabel("PSD",'fontsize',20);
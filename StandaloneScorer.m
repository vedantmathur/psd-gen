function file_handle = StandaloneScorer(cscfilename,timestamp,EEG_LP,EEG_HP)
    CSC_file = cscfilename;
    TS_file = timestamp;
    
    timestampSections = xlsread(TS_file);
    
    [EEG_samples, EEG_timestamps, reducedSamplingRate] = loadEEGData(CSC_file, timestampSections, EEG_LP, EEG_HP);
    [epochDuration, dt, df, fNyquist, size] = findepochsize(EEG_timestamps, reducedSamplingRate);
    % Epoch Duration is the sampling time - 10 seconds generally, 10.0012
    % exactly
    % dt is 1.00e-03
    % df is the interval unit 0.100
    % fnyquist is the nyquist frequency 500 (1000Hz)

    % Plot Raw Data and Save to a figure
    % plot(EEG_timestamps, EEG_samples)
    
    % Do Power Spectral Analysis
    faxis = (0:df:fNyquist); % Make the frequency axis.
    %timeline = 282.6754:epochDuration:86673.5077;
    timeline = timestampSections(1,1) * 10e-7:epochDuration:timestampSections(end,2) * 10e-7;
    % Get the index of the max frequency and taper the frequency axis to account
    lastFreqIndex = find(faxis <= EEG_LP, 1, 'last');
    faxis = faxis(1:lastFreqIndex);
    scoredEpochPowerSpectrum = zeros(length(timeline), lastFreqIndex);

    %for i = 1:length(timeline)
    for i = 1:1000
        % FROM SDK: Getting points that fit our 10 second epoch range
        stPointIndex = find((EEG_timestamps > (timeline(i) - 0.1 )) & (EEG_timestamps <timeline(i) + 0.1));

        diff = EEG_timestamps(stPointIndex) - timeline(i);
        [~,index]=min(abs(diff));

        st_pt = stPointIndex(index);
        end_pt= st_pt + size - 1;                
        if end_pt <= length(EEG_timestamps)
            x = EEG_samples(st_pt:end_pt);
            xh = hann(length(x)).*x;
            Sxx = 2*dt^2/epochDuration * fft(xh).*conj(fft(xh)); 
            Sxx=real(Sxx);
            scoredEpochPowerSpectrum(i, :) = Sxx(1:lastFreqIndex);
        end

    end
    
    % Plot and save Power Spectral Analysis as a figure
    % plot(faxis, scoredEpochPowerSpectrum)
    
    % Implement write to Excel    
    resultsFilename = strcat(date,'PSD.xlsx');
    sheetName = 'PowerSpectra';
    columnHeaders = {'Power_Spectra(uV^2/Hz)'};
    xlswrite(resultsFilename,columnHeaders, sheetName, 'A1');
    clear columnHeaders
    columnHeaders = {'Time_(s)'};
    xlswrite(resultsFilename,columnHeaders, sheetName, 'A2');
    clear columnHeaders
    columnHeaders = {'Frequency(Hz)'};
    xlswrite(resultsFilename,columnHeaders, sheetName, 'C1');
    clear columnHeaders
    xlswrite(resultsFilename,faxis, sheetName, 'C2');
    %Write results to the 'PowerSpectra' sheet:
    xlswrite(resultsFilename,timeline', sheetName, 'A3');
    xlswrite(resultsFilename, zeros(length(timeline),1,'uint32'), sheetName, 'B3');
    xlswrite(resultsFilename,scoredEpochPowerSpectrum, sheetName, 'C3');
    msgbox("finished running PSD analysis");   

end

function [epochDuration, dt, df, fNyquist, size] = findepochsize(EEG_timestamps, reducedSamplingRate)

% Find the EPOCHSIZE of 10 seconds:
index=find((EEG_timestamps(1)+9.999 < EEG_timestamps) & (EEG_timestamps < EEG_timestamps(1)+10.001));
if (isempty(index)) == 1
    index=find((EEG_timestamps(1)+9.99 < EEG_timestamps) & (EEG_timestamps < EEG_timestamps(1)+10.01));
end
diff= EEG_timestamps(index(1):index(end)) - (EEG_timestamps(1)+10);
[minimum,ind]=min(abs(diff)); %#ok<ASGLU>
try
    size=index(ind);
catch %#ok<CTCH>
    fprintf('There is an error in calculating the EPOCHSIZE of 10sec in read_n_extract_datafiles\n');
end
epochDuration = EEG_timestamps(size+1) - EEG_timestamps(1);
dt = 1/reducedSamplingRate; % Define the sampling interval.
df = 1/epochDuration; % Determine the frequency resolution.
fNyquist = reducedSamplingRate/2; % Determine the Nyquist frequency.

end

function [EEG_samples, EEG_timestamps, Fs] = loadEEGData(CscFilename, timestampSections, EEG_LP, EEG_HP)
% This function loads in the CSC amplitude and timestamps for the selected
% CSC file.  It also automatically down-samples.

waithandle= waitbar(0.2,'Loading the EEG data');pause(0.2);
lowertimestamp = timestampSections(1,1);
uppertimestamp = timestampSections(end,2);
[Timestamps,cscSamplingRate,Samples]=Nlx2MatCSC(CscFilename,[1 0 1 0 1],0,4,[lowertimestamp uppertimestamp]);
cscSamplingRate = cscSamplingRate(1);
unfilt_samples=double(Samples(:)');
exactLow = timestampSections(1,3);
exactHi = length(unfilt_samples);
clear Samples
close(waithandle);

% Precise time stamps should be calculated here:
waithandle = waitbar(0.6,'Extracting EEG Timestamps...'); pause(0.2);
[EEG_TIMESTAMPS_temp,EEG_SAMPLES_temp] = generate_timestamps_from_Ncsfiles(Timestamps,unfilt_samples,exactLow, exactHi,[]);
clear Timestamps unfilt_samples
close(waithandle);

% Automated down-sampling to down-smple to 1kHz if greater or output an error if below 250Hz:
if cscSamplingRate > 1050
    DS = (1:1:32);
    DSampSF = cscSamplingRate./DS;
    indSampfactor = find(DSampSF >= 1000);
    Fs = DSampSF(indSampfactor(end));
    sampFactor = DS(indSampfactor(end));
    msgbox({['Recording Sampling Rate:  ' num2str(cscSamplingRate) 'Hz'];...
        ['Down-Sampled Sampling Rate:  ' num2str(round(Fs)) 'Hz'];...
        ['Sampling Factor:  ' num2str(sampFactor) '']});
elseif cscSamplingRate < 250
    msgbox({['Recording Sampling Rate:  ' num2str(cscSamplingRate) 'Hz'];...
        'This sampling rate is too low to run the phase analyses.';...
        'Phase-O-Matic will now close.'});
    exit
else  % In practice, we should be sampling at at least 1kHz, but older files may have been recorded at slower frequencies.
    Fs = cscSamplingRate;
    sampFactor = 1;
    msgbox({['Recording Sampling Rate:  ' num2str(cscSamplingRate) 'Hz'];...
        'This sampling rate is acceptable to run the phase analyses.'});
end

% Convert amplitude to uV
physInput = 2;  %Needed to select proper error box in HeaderADBit.
ADBit2uV = HeaderADBit(CscFilename, physInput);    %Extract the AD Bit Value.
EEG_SAMPLES_temp = EEG_SAMPLES_temp * ADBit2uV;   %Convert amplitude of signal from AD Bits to microvolts.

%Design bandpass filter:
[z, p, k] = ellip(7,1,60, [EEG_HP EEG_LP]/(cscSamplingRate/2),'bandpass');
[sos, g] = zp2sos(z,p,k);
%Apply bandpass filter to EEG data:
EEG_SAMPLES_temp = filtfilt(sos,g, EEG_SAMPLES_temp);
% %  Low pass filter for EEG signals
% [Blow,Alow] = ellip(7,1,60, EEG_LP/(cscSamplingRate/2));           % Default setting implements low pass filter with 30hz cutoff
% EEG_SAMPLES_temp = filter(Blow,Alow,EEG_SAMPLES_temp);

waithandle = waitbar(0.3,'Downsampling EEG Data...'); pause(0.2);
EEG_TIMESTAMPS_temp = EEG_TIMESTAMPS_temp(1:sampFactor:end);
EEG_SAMPLES_temp = EEG_SAMPLES_temp(1:sampFactor:end);
close(waithandle);

%waithandle = waitbar(0.7,'Deshifting EEG Data...'); pause(0.2);
% EEG_timestamps = [];
% EEG_samples = [];
EEG_samples = EEG_SAMPLES_temp;%( floor( ( length(coeffs)/2 )/sampFactor ):(length(EEG_SAMPLES_temp) - floor( (length(coeffs)/2)/sampFactor) ));
EEG_timestamps = EEG_TIMESTAMPS_temp;%(1:length(EEG_samples));
% close(waithandle);
clear EEG_SAMPLES_temp EEG_TIMESTAMPS_temp

%#####################

end
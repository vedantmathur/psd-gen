# Power Spectral Generator from CSC Files
** No CSC files are included so this README is purely BYOCSC (bring your own csc)

## How to Use
This is built to extract the power spectra from a multi-hour neural recording. The SleepScorer can currently do that but it requires manual scoring to work. This is a one click solution missing the "state variable".

See [Prerequisites](#Prerequisites) for dependencies.

1. Ensure the dependencies are included in Matlab (Right click -> Include drectory and subdirectories)
2. Run mlapp
3. Browse for your CSC file, allow it to process
4. Press the Analysis button to generate an XLSX file with your PSD.

Step 4 may take up to 30 minutes for a 3 hour recording, scaling linearly. 

## Prerequisites
This program only runs on Windows (for now), due to SDK limitations. I will talk to Neuralynx soon to resolve this. You will also need the following tools. You can place the folders in the main root of the project folder, or include them in MATLAB when running.

- MATLAB R2021A (or later, no idea if this works on previous versions)
- [SharedSubFunctions](https://github.com/poe-lab/SharedSubFunctions)
- [TimeStampGenerators](https://github.com/poe-lab/TimeStampGenerators)
- [SDK_neuralynx_v5.0.1](https://github.com/poe-lab/SDK_neuralynx_v5.0.1)
- A CSC File that you want the PSD of :)


## Known Issues
- Well, it doesn't work on Mac
- Dependency script needs to be rewriten in BASH for Windows
- Rearrange and strip software
- Fix the header row/column in XLSX file. 
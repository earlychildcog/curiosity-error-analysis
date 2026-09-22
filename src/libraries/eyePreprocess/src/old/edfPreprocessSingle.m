function hPupilData = edfPreprocessSingle(edfFilename, settings)
arguments
    edfFilename string {mustBeFile}
    settings
end
[folder, file] = fileparts(edfFilename);


matFilename = fullfile(folder,"matlabData",file + ".mat");

rawdata = edfDataConverter(edfFilename, matFilename, settings)













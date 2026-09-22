% Visit 2: sampling rate was wrong (half = 4Hz) between 20/02/24 and
% 22/03/24 AM as well as on 18/12/24 (+ 3 more files saved in 2015 because
% of clock reset after power cut)


addpath(genpath("src"));
% lib.include("eyePreprocess")
visit = 2;

flagParallel = true;
if flagParallel
    if ~isempty(gcp('nocreate')) && isa(gcp('nocreate'), 'ThreadPool')       % only process pool works here
        gcp('nocreate').delete;
    elseif isempty(gcp('nocreate'))
        parpool('Processes');
    end
end

% folder    = fullfile(pwd,'data','eyetracking',sprintf('Visit%d',visit),sprintf('edf-visit%d',visit));
pathData = fullfile(filesep,'Users',getenv('USER'),'Data','curE',sprintf('Visit%d', visit), 'eyetracking', sprintf('edf-visit%d',visit));
filenames = string({dir(fullfile(pathData, "*.edf")).name});
nFiles    = numel(filenames);
srate     = zeros(size(filenames));

for iFile = 1:nFiles
    edf = edfImportRaw(fullfile(pathData, filenames(iFile))); 
    srate(iFile) = mean(diff(edf.FSAMPLE.time));
    srate_media(iFile) = median(diff(edf.FSAMPLE.time));
end
figure; plot(srate);
figure; plot(srate_media);
filenames(srate_media > 2)

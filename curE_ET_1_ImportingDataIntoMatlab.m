%% Import eyelink data into Matlab for Curiosity E (error) study
%
% Saves data into mat and csv files, and also defines the AOIs and whether
% gaze is in them; no preprocessing done on location data, a bit on pupil.
%
% At the end, save all participants' data into one big csv files
% /!\ can easily make your matlab crash or even your computer shut down --
% this is the most memory/energy consuming step.
% Pretty long if not using parelle processing
%


%% Define important variables
visit        = 1;        % 1/2/3
flagParallel = true;     % false/true


%% Define more things
addpath("src");
addpath(genpath(fullfile("src","libraries")));
% Paths (normally no need to change)
pathData           = [filesep, fullfile('Users',getenv('USER'),'Data','curE',sprintf('Visit%d',visit),'eyetracking')];
pathDataEdfIn      = fullfile(pathData, sprintf('0_edf-visit%d',visit));
pathDataMatOut     = fullfile(pathData, sprintf('1_mat-visit%d',visit));
pathDataCsvOut     = fullfile(pathData, sprintf('2_csv-visit%d',visit));
pathDataSummaryOut = fullfile(pathData, sprintf('3_whole-group-visit%d',visit));
% Parallel processing or not
fSetUpFieldtripAndParallelPool(flagParallel=flagParallel);
% For the outputs: make the folders or prompt to empty it if files are detected
util.fMkDirSafe(pathDataMatOut);
util.fMkDirSafe(pathDataCsvOut);
util.fMkDirSafe(pathDataSummaryOut);

%% Load data & preprocess the pupil data, save into mat files
% THIS IS AN IMPORTANT STEP USED FOR DETERMINING DATA QUALITY LATER ON
% (even if the analysis focused on non-pupil data)
% identify good pupil samples based on set min/max, interpolate between
% bad samples for gap smaller than max length & smooth
% --- To see what vars are in the edf files (just for checking)
% varlistFromEdf("data/eyetracking/edf-visit1/curE002a.edf")
% --- To read the edf data
getMatFromEdfBatch(pathDataEdfIn, pathDataMatOut, messageStart="attget start @",varinclude=[...
    "trialtype" "difficulty" "trialno" "objL" "objR" "objT" "result" "delayFirstFixT" "delayFirstFixB"...
    "trialID" "accuracy" "sideMatch" "sideChosen" "keyboardFlip"]) % for visit 1 data
preprocData = preprocessMatBatch(pathDataMatOut, export=false);
% Fix (upsample if needed and change the way some vars were stored) & save
% remove fixations to make space (& re-do better later)
gaze_remove_fixations(preprocData);
% append -processed after a pattern match looking for: any word characters
% (letters, digits, underscore: \w*) and, at the end ($),  either: 
% the end of the string ($) OR zero or more backslashes or forward slashes
% at the end (?:\\|/)*$ -- this thing ($1) then takes a suffix (-processed)
postMatFolder = regexprep(pathDataMatOut, "(\w*)($|(?:\\|/)*$)","$1-processed");
util.fMkDirSafe(postMatFolder, flagCleanDir='force_clean');
for iSubj = 1:numel(preprocData)
    thisData = preprocData(iSubj);
    try
        thisData = fET_upSampleIfNeeded(thisData,thisData.gaze.t_ms);
        util.fParsave(fullfile(postMatFolder, thisData.filename), thisData);
        fprintf("Saved preprocessed file %s\n", thisData.filename)
    catch err
        fprintf("Error processing %s\n", thisData.filename);
        rethrow(err);
    end
end
% Clear temp vars
fprintf("--- Clearing big variables from workspace before continuing.... \n");
preprocData.delete;
clear preprocData thisData iSubj

%% Create (padded) ROIs and say if the gaze is in them, then save to csv
ROI = fET_GetROIs;
% ROI.show % To check if the ROIs are good
% Save indiv csv files
fprintf("Now saving individual csv files (this takes a long while).... \n");
getCsvFromFolderMat(postMatFolder, csvfolder=pathDataCsvOut, ROI=ROI, roiFrom="raw", export_fixations=false, verbose=true)
clear postMatFolder

%% Load indiv CSVs into one big whole-group table
% /!\ Used to make Matlab crash, by far the most memory consuming step
% Ok with less workers; this might be computer-dependent, adapt if too much
delete(gcp("nocreate"));
if flagParallel
    p = parpool(4); % using less workers or the computer crashes -- ADAPT if still too much for you
end
fprintf("Now reading the individual csv files into one big table (this also takes a while).... \n");
T = readcsvBatch(pathDataCsvOut, "stringType", "string");        %import the data into one big table
% Reduce the size of the big whole-group table
fprintf("Now reducing the size of the big table (this also takes a while).... \n");
T = fET_ReduceSizeBigTable(T);
% Save it as a big csv file
fprintf("Now saving the big table (this also takes a while but it's the last step!).... \n");
save(fullfile(pathDataSummaryOut,sprintf('all-visit%d.mat',visit)),"T","-v7.3");    %save the big table
clear p ROI
fprintf("All done! \n");

beep
%% Convert mff files (EGI) to mat files (fieldtrip format) for analysis
%
% Requires FieldTrip toolbox (will throw an error and explain what to do)
% see https://www.fieldtriptoolbox.org
% Matlab's core parallel processing toolbox can be used for speed (not
% required)
% 
% /!\ Always set up the flags at the top of script before running:
%   - erptype: whether we're looking at the ERN or the FRN segments
%   - visit: whether we're looking at visit 1, 2 or 3
%   - flagParallel: whether we're using parallel processing for speed;
%   requires Matlab's parallel processing toolbox installed.
%   - flagFT: whether we start up FieldTrip or not (if you have already
%   done that elsewhere e.g., by running this script for another erptype in
%   the same Matlab session, then set to false; else, set tu True.
%
% If you already have run this script for the current visit and erptype
% and have data saved in your folder, this script will prompt you to
% confirm whether you want to proceed and overwrite the files (y), stop the
% process (q), save the new data in new files in the same folder as the old
% ones (n -- not recommended, several files for the same participant will
% coexist).
%
%
% Data for each erptype and visit need to be stored in a path as follows:
%    "~\Data\curE\Visit[x]\[erptype]\[analysisStep]"
%          e.g., cecile\Data\curE\Visit1\ERN\0_mffFiles
%
% Input .mff data from EGI are stored in the "0_mffFiles" folder.
% Outputs are stored in new folders with increasing numbers for each step.
%
% Note: the input mff data is not raw, it has already gone through several
% manual preprocessing steps in the EGI software:
%   - 1 Filtering: bandpass (1.5 to 30Hz), notch (50Hz)
%   - 2 Segmentation and manual flagging of bad channels/segments
%         ERN segments: -0.298/+0.548 around 'fixB' trigger
%         FRN segments: -0.098/+1.048 around 'bcfl' trigger
%   - 3 Interpolation of bad channels
%   - 4 Re-reference to the average (recorded with a Cz reference)
%
%
% Tested on Matlab 2024a (later versions compatibility possible but unknown)
%
% Written by Dimitrios Askitis & Cécile Gal
%

%% Define the main parameters
% (see fGetMatFilesFromMff function below for more options and details)
erpType      = "ERN";    % "ERN"/"FRN"
visit        = 1;        % 1/2/3
flagParallel = true;     % false/true

%% Set things up
addpath("src")
fSetUpFieldtripAndParallelPool(flagParallel=flagParallel,flagFT=true)

%% Do the thing
f_GetMatFilesFromMff(erpType, visit, flagParallel=flagParallel)

%% Play a beep sound when done
beep


function f_GetMatFilesFromMff(erptype, visit, opts)
% legacy: old name was save_mff_to_mat
arguments
    erptype (1,1) string {mustBeMember(erptype, ["ERN" "FRN" "ERNtest" "FRNtest"])} = "ERN";
    visit (1,1) double {mustBeMember(visit, [1 2 3])}           = 1
    opts.flagFT (1,1) logical                                   = false           % to start up fieldtrip when running this script (don't if you already started it up elsewhere)
    opts.flagParallel (1,1) logical                             = false           % true for parallel, needs parallel toolbox, runs faster
    opts.flagSave (1,1) logical                                 = true
    opts.dirDataMffIn (1,1) string                              = "0_mffFiles";   % use data from the s-drive folder "4-Rereferenced to average"
    opts.dirDataMatOut (1,1) string                             = "1_matFiles";
    opts.pathData (1,1) string {mustBeFolder}                   = filesep + fullfile('Users',getenv('USER'),'Data','curE',sprintf('Visit%d', visit), erptype);
end
%% Save FRN/ERN to .mat files with 
% Set the paths for inputs/outputs
pathDataMffIn  = fullfile(opts.pathData, opts.dirDataMffIn);
pathDataMatOut = fullfile(opts.pathData, opts.dirDataMatOut);
% For the output: make the folder or prompt to empty it if files are detected
util.fMkDirSafe(pathDataMatOut);
% Get the list of mff filenames (force the names to fit expected data: filtered and segmented
datetime_ = string(datetime('now', Format='_uuuuMMdd-HHmm_'));
visits_str = ["a" "b" "c"]; visit_str = visits_str(visit);
if erptype=="unsegmented_EEG"
    filenamesIn = string({dir(fullfile(pathDataMffIn, "curE*" + visit_str + "_*_fil.mff")).name});       % use filtered data
else
    filenamesIn = string({dir(fullfile(pathDataMffIn, "curE*" + visit_str + "_*_fil_seg_*.mff")).name}); % use filtered and segmented data
end
% Speed up with parallel processing
if opts.flagParallel
    flag_Save = opts.flagSave; % save up communication overhead by not broadcasting the whole opts in parallel
    parfor iFile = 1:numel(filenamesIn)
        % Get current dataset's path
        pathThisMffIn = fullfile(pathDataMffIn, filenamesIn(iFile));
        pathThisMatOut = fullfile(pathDataMatOut, regexprep(filenamesIn(iFile), ".mff", datetime_ + erptype + ".mat"));
        % Get the data from the mff file
        [data, tblMetadata] = fEEG_GetDataFromMff(pathThisMffIn, erptype);
        % Save it if we've set up the flag
        parsave(flag_Save, pathThisMatOut, struct('data',data,'tblMetadata',tblMetadata))
    end
% Or don't speed up in a normal loop
else
    for iFile = 1:numel(filenamesIn)
        % Get current dataset's path
        pathThisMffIn = fullfile(pathDataMffIn, filenamesIn(iFile));
        pathThisMatOut = fullfile(pathDataMatOut, regexprep(filenamesIn(iFile), ".mff", datetime_ + erptype + ".mat"));
        % Get the data from the mff file
        [data, tblMetadata] = fEEG_GetDataFromMff(pathThisMffIn, erptype);
        % Save it if we've set up the flag
        parsave(opts.flagSave, pathThisMatOut, struct('data',data,'tblMetadata',tblMetadata))
    end
end

end

function parsave(flagsave, filename, struct_, varargin)
    if flagsave
        fields_ = fieldnames(struct_);
        % Save the struct with -struct flag
        save(filename, '-struct', 'struct_', fields_{:}, varargin{:});
    end
end
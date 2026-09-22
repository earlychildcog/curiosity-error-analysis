function fSetUpFieldtripAndParallelPool(opts)
arguments
    opts.flagFT       (1,1) logical = false;
    opts.flagParallel (1,1) logical = false;
end


% add fieldtrip (you can also add an elseif condition for your own FT folder)
if opts.flagFT
    if strcmp(getenv('USER'), 'cecile')
        path_ft = "~/MatlabToolboxes/fieldtrip";
    else
        path_ft = fullfile(pwd,"src","fieldtrip");
    end
    assert(isfolder(path_ft), ...
        "FieldTrip toolbox required -- please download it and save your path above -- https://www.fieldtriptoolbox.org/download/")
    addpath(path_ft)
    ft_defaults;
end


% also set up whether we're using parallel processing
if opts.flagParallel
    if ~isempty(gcp('nocreate')) && isa(gcp('nocreate'), 'ThreadPool')       % only process pool works here
        gcp('nocreate').delete;
    elseif isempty(gcp('nocreate'))
        parpool('Processes');
    end
end


end

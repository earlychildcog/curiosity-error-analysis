% Find when we had a key press
% PROBLEM: Need to save a file with all the trials first (right now we save
% something else -- will change this another time)

visit   = 1;
erptype = 'ERN';

if visit == 1 % legacy file, need to update
    dataPath = fullfile(pwd,'data','EEG',sprintf('Visit%d',visit));
    filename = sprintf('mff-visit%d-events.csv',visit);    
elseif visit == 2
    dataPath = [filesep,fullfile('Users',getenv('USER'),'Data','curE',sprintf('Visit%d', visit), erptype)];
    filename = 'tblMetadata.csv';
end
T        = readtable(fullfile(dataPath,filename));
Tcode    = categorical(T.code);
if visit == 1
    Tkb      = T(Tcode == 'keyl' | Tcode == 'keyr' | Tcode == 'keyu',:);
elseif visit == 2
    Tkb      = T(Tcode == 'klef' | Tcode == 'krig' | Tcode == 'keup',:);
else
    disp('check what the keypress codes are for this visit and specify them before running the script')
    return;
end
writetable(Tkb,fullfile(pwd, 'data','EEG',sprintf('Visit%d', visit), 'trialsWithKeyPresses.csv'));

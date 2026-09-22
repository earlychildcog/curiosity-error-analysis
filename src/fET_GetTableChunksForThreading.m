%% Slash the big table into pieces that can go to different cpu threads and in general save computation (even with 1 thread)
% Get unique sessions (participants) and their corresponding numbers
function T_ = fET_GetTableChunksForThreading(T, visit)

T.rowNb = (1:size(T,1))';
[sessions,idxSessions,idx2] = unique(T.session);
idxSessions(end+1) = size(T,1)+1;
sessionsNums = char(sessions);
if visit < 3
    sessionsNums = str2num(sessionsNums(:,end-3:end-1));
else % somehow the data is saved with one extra space at the end for visit 3
    sessionsNums = str2num(sessionsNums(:,end-4:end-2));
end
nSessions = size(sessions,1);
T_ = cell(nSessions,1);
for iSession = 1:nSessions
    T.sessionNum(idx2 == iSession) = sessionsNums(iSession);
    T_{iSession} = T(T.session == sessions(iSession),:);
end

end
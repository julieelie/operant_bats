%%this function will run through all event and parameter files for 1 bat to
%%extract the behavioral data from many days from a single bat pair

function [behavData] = extract_behavData(taskType)
%% initialize the structure that will contain graph data
behavData = struct();
behavData.fileList = dir('*_events.txt');
behavData.batName = behavData.fileList(1).name(1:4);
%create vocId vector to sort and concatenate txt files with multiple sessions
idVect = zeros(1,length(behavData.fileList));
for id = 1:length(behavData.fileList)
    idString{id} = behavData.fileList(id).name(1:11);
    behavData.idList = unique(idString);
    idLog = strcmp(behavData.fileList(id).name(1:11),behavData.idList);
    idVect(id) = find(idLog);
end
behavData.sessionDate = cell(1,length(behavData.idList));
for ii = 1:length(behavData.idList)
    behavData.sessionDate{ii} = behavData.idList{ii}(6:11)
end
%initialize variables in behavData structure
behavData.vocId = cell(1,length(behavData.idList));
behavData.Events = cell(1,length(behavData.idList));
behavData.Params = cell(1,length(behavData.idList));
behavData.durationSession = cell(1,length(behavData.idList));
emptyDate = zeros(1,length(idString));
behavData.frontReward = cell(1,length(behavData.idList));
behavData.backReward = cell(1,length(behavData.idList));
behavData.delay2Reward = cell(1,length(behavData.idList));
behavData.WavFileStruc = zeros(1,length(idString));
behavData.numCalls =zeros(1,length(behavData.idList));
behavData.numFront = zeros(1,length(behavData.idList));
behavData.numBack = zeros(1,length(behavData.idList));
behavData.numRewards =zeros(1,length(behavData.idList));
behavData.rewardPercent =zeros(1,length(behavData.idList));
behavData.avgDelay2Reward =zeros(1,length(behavData.idList));
behavData.callRate = zeros(1,length(behavData.idList));

%set column header titles
dataFileStruc = dir(fullfile(behavData.fileList(1).folder, [behavData.fileList(1).name(1:16) '*events.txt']));
headerData = fopen(fullfile(dataFileStruc.folder,dataFileStruc.name));
if strcmp(taskType,'allRewarded') %query the task type
    eventsHeader = textscan(headerData, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n',1);
    for hh=1:length(eventsHeader)
        if strfind(eventsHeader{hh}{1}, 'DateTime')
            EventsDateCol = hh;
        elseif strfind(eventsHeader{hh}{1}, 'TimeStamp(s)')
            EventsTimeCol = hh;
        elseif strfind(eventsHeader{hh}{1}, 'SampleStamp')
            EventsStampCol = hh;
        elseif strfind(eventsHeader{hh}{1}, 'Type')
            EventsEventTypeCol = hh;
        elseif strfind(eventsHeader{hh}{1}, 'FoodPortFront')
            EventsFoodPortFrontCol = hh;
        elseif strfind(eventsHeader{hh}{1}, 'FoodPortBack')
            EventsFoodPortBackCol = hh;
        elseif strfind(eventsHeader{hh}{1}, 'Delay2Reward')
            EventsDelayCol = hh;
        end
    end
end
%% Pull in recording, snippit, and behavior data into structure
for ind = 1:length(behavData.fileList)
    % Get the recording data
    behavData.WavFileStruc = dir(fullfile(behavData.fileList(ind).folder, [behavData.fileList(ind).name(1:16) '*mic*.wav']));
    % Get the sound snippets from the sounds that triggered detection
    behavData.DataSnipStruc = dir(fullfile(behavData.fileList(ind).folder, [behavData.fileList(ind).name(1:16) '*snippets/*.wav']));
    
    %bring in parameter data
    paramFileStruc = dir(fullfile(behavData.fileList(ind).folder, [behavData.fileList(ind).name(1:16) '*param.txt']));
    paramData = fopen(fullfile(paramFileStruc.folder,paramFileStruc.name));
    behavData.Params{idVect(ind)} = [behavData.Params{idVect(ind)} textscan(paramData, '%s','Delimiter','\n')];
    % Open up the file and pull in events
    dataFileStruc = dir(fullfile(behavData.fileList(ind).folder, [behavData.fileList(ind).name(1:16) '*events.txt']));
    Fid_Data = fopen(fullfile(dataFileStruc.folder,dataFileStruc.name));
    eventsHeader = textscan(Fid_Data, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n',1);
    %get all events data and concatenate it if previous day already opened
    behavData.Events{idVect(ind)} = [behavData.Events{idVect(ind)}; textscan(Fid_Data, '%s\t%f\t%s\t%s\t%f\t%f\t%f')];
    %check if there's data in the file to perform duration timing later
    if isempty(behavData.Events{idVect(ind)}{end,1})
        emptyDate(ind) =1;
    else
        emptyDate(ind) = 0;
    end
    %concatenate the cells if more than one session in a single day
    behavData.Events{idVect(ind)} = arrayfun(@(col) vertcat(behavData.Events{idVect(ind)}{:, col}), 1:size(behavData.Events{idVect(ind)}, 2), 'UniformOutput', false);
    %find indices of each vocalization event
    behavData.vocId{idVect(ind)} = [behavData.vocId{idVect(ind)} find(strcmp('Vocalization', behavData.Events{idVect(ind)}{EventsEventTypeCol}))'];
    fclose(Fid_Data);
    fclose(paramData);
end

%% sum num rewards, call rate, and reward percentage
n = 0;
for counts = 1:length(behavData.idList)
    % # of calls and rewards on each food port
    behavData.numCalls(counts) = length(behavData.vocId{counts});
    behavData.numFront(counts) = nansum(behavData.Events{counts}{EventsFoodPortFrontCol});
    behavData.numBack(counts) = nansum(behavData.Events{counts}{EventsFoodPortBackCol});
    behavData.numRewards(counts) = behavData.numFront(counts) + behavData.numBack(counts);
    behavData.rewardPercent(counts) = behavData.numRewards(counts)/behavData.numCalls(counts) * 100;
    %calculate delay to reward average
    behavData.avgDelay2Reward(counts) = nanmean(behavData.Events{counts}{EventsDelayCol}(behavData.vocId{idVect(ind)}));
    
    %initialize session duration variable
    behavData.durationSession{counts} = nan(length(behavData.Params{counts}),1);
    %length of session
    for ss = 1:length(behavData.Params{counts})
        n = n + 1; %counter for emptyDate
        localData = behavData.Params{counts}{ss};
        indStop = find(contains(localData,'Task stops')); %find the words in line 22 of param file
        %get duration from param file
        if ~isempty(indStop)
            beforeTime = strfind(localData{indStop},'after ') + length('after ');
            afterTime = strfind(localData{indStop},' seconds') - 1;
            behavData.durationSession{counts}(ss) = str2num(localData{indStop}(beforeTime:afterTime))/60/60;
        elseif emptyDate(n) == 1 %duration is 0 if data is empty
            behavData.durationSession{counts}(ss) = 0;
        else %duration is approximated from last event on the event file (max 10 min discrepancy)
            behavData.durationSession{counts}(ss) = behavData.Events{idVect(ind)}{EventsTimeCol}(end)/60/60;
        end
    end
    %call rate
    behavData.callRate(counts) = behavData.numCalls(counts)/sum(behavData.durationSession{counts});
end

%save variable in mat file
save(fullfile(behavData.fileList(1).folder, ['\behavData_' behavData.fileList(1).name(1:11) '_to_' behavData.fileList(end).name(6:11) '.mat']),'-struct','behavData')
end



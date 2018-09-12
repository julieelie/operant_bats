function [behavData] = extract_behavDataSingle(taskType,fileName)
% initialize the structure that will contain graph data
behavData = struct();
behavData.Events = {};
behavData.vocId = [];
behavData.frontReward = [];
behavData.backReward = [];
behavData.delay2Reward = [];
behavData.WavFileStruc = [];
behavData.numCalls =[];
behavData.numFront =[];
behavData.numBack =[];
behavData.numRewards =[];
behavData.rewardPercent =[];
behavData.avgDelay2Reward =[];

% Get the recording data
fileName = [fileName '_VocTrigger_events.txt'];
[DataPath, DataFile ,~]=fileparts([pwd '\' fileName]); %maybe needs more
behavData.WavFileStruc = dir(fullfile(DataPath, [DataFile(1:16) '*mic*.wav']));
% Get the sound snippets from the sounds that triggered detection
behavData.DataSnipStruc = dir(fullfile(DataPath, [DataFile(1:16) '*snippets/*.wav']));

% Get the sample stamp of the detected vocalizations
DataFileStruc = dir(fullfile(DataPath, [DataFile(1:16) '*events.txt']));
Fid_Data = fopen(fullfile(DataFileStruc.folder,DataFileStruc.name));
if strcmp(taskType,'allRewarded')
    eventsHeader = textscan(Fid_Data, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n',1);
    for hh=1:length(eventsHeader)
        if strfind(eventsHeader{hh}{1}, 'DateTime')
            EventsDateCol = hh;
        elseif strfind(eventsHeader{hh}{1},'TimeStamp(s)')
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
    
    %get the events data
    behavData.Events = textscan(Fid_Data, '%s\t%f\t%s\t%s\t%f\t%f\t%f');
    fclose(Fid_Data);
    
    %find indices of each event
    behavData.vocId = find(strcmp('Vocalization', behavData.Events{EventsEventTypeCol}))';
    for bb = 1:length(behavData.vocId)
        behavData.frontReward(bb) = [behavData.Events{5}(behavData.vocId(bb))];
        behavData.backReward(bb) = [behavData.Events{6}(behavData.vocId(bb))];
        behavData.delay2Reward(bb) = [behavData.Events{7}(behavData.vocId(bb))];
    end
    %sum num rewards and percentage
    behavData.numCalls = length(behavData.vocId);
    behavData.numFront = sum(behavData.frontReward);
    behavData.numBack = sum(behavData.backReward);
    behavData.numRewards = behavData.numFront + behavData.numBack;
    behavData.rewardPercent = behavData.numRewards/behavData.numCalls * 100;
    %calculate delay to reward average
    behavData.avgDelay2Reward = nanmean(behavData.delay2Reward); 
    
    %length of session
    behavData.sessionLength = behavData.Events{2}(end)/60/60;
    %call rate
    behavData.callRate = behavData.numCalls/behavData.sessionLength;
end
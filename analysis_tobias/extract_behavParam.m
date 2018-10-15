%this function will extract all the parameters and event data from all bats
%and session types in the current directory. It saves as a large structure
%with each trial containing all data.

function [behavData] = extract_behavParam
% initialize the file lists and variables that will contain matrix data
paramList = dir('*_param.txt');
fileList = dir('*_events.txt');

batId = cell(1,length(fileList)); %bat names
taskType = cell(1,length(fileList)); %task type
sessionDate = zeros(1,length(fileList)); %dates
sessionStartTime = zeros(1,length(fileList)); %times
sessionNum = zeros(1,length(fileList)); %session # of each day
idString = cell(1,length(fileList)); %variable for collecting title without time
sessionDuration = zeros(1,length(fileList)); %length of session
highPass = zeros(1,length(fileList)); %high pass filter in each session
lowPass = zeros(1,length(fileList)); %low pass filter in each session
RMS = zeros(1,length(fileList)); %low pass filter in each session
vocId = cell(1,length(fileList)); %indices of vocalization events
inputBeamId = cell(1,length(fileList)); %indices of BB events
numCalls = zeros(1,length(fileList)); %total call numbers in each session
inputFront = zeros(1,length(fileList)); %number of input BB from front bb port
inputBack = zeros(1,length(fileList)); %number of input BB from back bb port
numBB = zeros(1,length(fileList)); %total number of input beam breaks
callRewardFront = zeros(1,length(fileList)); %number of rewards from front port
callRewardBack = zeros(1,length(fileList)); %number of rewards from back port
callNumRewards = zeros(1,length(fileList)); %total number of rewards in session
callRewardPercentage = zeros(1,length(fileList)); %numcalls/numrewards
callRate  = zeros(1,length(fileList)); %number of calls/hr
avgDelay2Reward = zeros(1,length(fileList)); %delay to reward after calling or BB
avgDelay2Voc = zeros(1,length(fileList)); %delay between BB and call for BBVocTrigger
pbFiles = cell(1,length(fileList)); %file names of each playback file
bbRate = zeros(1,length(fileList));
bbRewardPercentage = zeros(1,length(fileList));
bbRewardFront = zeros(1,length(fileList));
bbRewardBack = zeros(1,length(fileList));
bbNumRewards = zeros(1,length(fileList));


%extract param data into matrix
for id = 1:length(fileList)
    %get task types
    afterTask = strfind(fileList(id).name,'_events') - 1;
    taskType{id} = fileList(id).name(18:afterTask);
    %load events and param file
    paramOpen = fopen(fullfile(paramList(id).folder,paramList(id).name));
    localParams = textscan(paramOpen, '%s','Delimiter','\n');
    localParams = localParams{1};
    eventOpen = fopen(fullfile(fileList(id).folder,fileList(id).name));
    %query the task type & load events
    if strcmp(taskType{id},'VocTrigger') || strcmp(taskType{id},'RecOnly')
        %load headers
        headerEvents = textscan(eventOpen, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n',1);
        for hh=1:length(headerEvents)
            if strfind(headerEvents{hh}{1}, 'DateTime')
                EventsDateCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'TimeStamp(s)')
                EventsTimeCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'SampleStamp')
                EventsStampCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'Type')
                EventsEventTypeCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'FoodPortFront')
                EventsFoodPortFrontCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'FoodPortBack')
                EventsFoodPortBackCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'Delay2Reward')
                EventsDelay2RewardCol = hh;
            end
        end
        %read text file
        localEvents = textscan(eventOpen, '%s\t%f\t%s\t%s\t%f\t%f\t%f');
    elseif strcmp(taskType{id},'BBTrigger') || strcmp(taskType{id},'BBorVocTrigger')
        %load headers
        headerEvents = textscan(eventOpen, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',1);
        for hh=1:length(headerEvents)
            if strfind(headerEvents{hh}{1}, 'DateTime')
                EventsDateCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'TimeStamp(s)')
                EventsTimeCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'SampleStamp')
                EventsStampCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'Type')
                EventsEventTypeCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'InputBeamFront')
                EventsInputBeamFrontCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'InputBeamBack')
                EventsInputBeamBackCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'FoodPortFront')
                EventsFoodPortFrontCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'FoodPortBack')
                EventsFoodPortBackCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'Delay2Reward')
                EventsDelay2RewardCol = hh;
            end
        end
        %read text file
        localEvents = textscan(eventOpen, '%s\t%f\t%s\t%s\t%f\t%f\t%f\t%f\t%f');
    elseif strcmp(taskType{id},'BBVocTrigger') 
        %load headers
        headerEvents = textscan(eventOpen, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',1);
        for hh=1:length(headerEvents)
            if strfind(headerEvents{hh}{1}, 'BeamDateTime')
                EventsBeamDateCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'BeamTimeStamp(s)')
                EventsBeamTimeCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'VocDateTime')
                EventsDateCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'VocTimeStamp(s)')
                EventsTimeCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'SampleStamp')
                EventsStampCol = hh;    
            elseif strfind(headerEvents{hh}{1}, 'Type')
                EventsEventTypeCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'InputBeamFront')
                EventsInputBeamFrontCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'InputBeamBack')
                EventsInputBeamBackCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'FoodPortFront')
                EventsFoodPortFrontCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'FoodPortBack')
                EventsFoodPortBackCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'Delay2Voc')
                EventsDelay2VocCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'Delay2Reward')
                EventsDelay2RewardCol = hh;
            end
        end
        %read text file
        localEvents = textscan(eventOpen, '%s\t%f\t%s\t%f\t%s\t%s\t%f\t%f\t%f\t%f\t%f\t%f');
    elseif strcmp(taskType{id},'PBOnly')
        %load headers
        headerEvents = textscan(eventOpen, '%s\t%s\t%s\t%s\n',1);
        for hh=1:length(headerEvents)
            if strfind(headerEvents{hh}{1}, 'DateTime')
                EventsDateCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'TimeStamp(s)')
                EventsTimeCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'StimFile')
                EventsStimFileCol = hh;
            elseif strfind(headerEvents{hh}{1}, 'Type')
                EventsEventTypeCol = hh;
            end
        end
        %read text file
        localEvents = textscan(eventOpen, '%s\t%f\t%s\t%s');
    end
    
    %get bat names
    batId{id} = fileList(id).name(1:4);
    %get session date
    sessionDate(id) = str2num(fileList(id).name(6:11));
    %get session time
    sessionStartTime(id) = str2num(fileList(id).name(13:16));
    %get session numbers
    idString{id} = [fileList(id).name(1:11) fileList(id).name(17:afterTask)];
    idList = strcmp(idString{id}, idString(1:id));
    sessionNum(id) = sum(idList);
    
    %get session duration
    indStop = find(contains(localParams,'Task stops')); %find the words in line 22 of param file
    %get duration from param file
    if ~isempty(indStop)
        beforeTime = strfind(localParams{indStop}, 'after ') + length('after ');
        afterTime = strfind(localParams{indStop}, ' seconds') - 1;
        sessionDuration(id) = str2double(localParams{indStop}(beforeTime:afterTime))/60/60;
    elseif isempty(localEvents{1})    %check if there's data in the file to perform duration timing later
        sessionDuration(id) = 0;
    else %duration is approximated from last event on the event file (max 10 min discrepancy)
        sessionDuration(id) = localEvents{EventsTimeCol}(end)/60/60;
    end
    
    %get low and high pass filter settings
    indHigh = find(contains(localParams,'Sound detection high'));
    beforeHigh = strfind(localParams{indHigh}, 'threshold: ') + length('threshold: ');
    afterHigh = strfind(localParams{indHigh}, ' Hz') - 1;
    highPass(id) = str2double(localParams{indHigh}(beforeHigh:afterHigh));
    indLow = find(contains(localParams,'Sound detection low'));
    beforeLow = strfind(localParams{indLow}, 'threshold: ') + length('threshold: ');
    if strcmp(localParams{indLow}(beforeLow:end),'None')
        lowPass(id) = nan;
    else
        afterLow = strfind(localParams{indLow}, ' Hz') - 1;
        lowPass(id) = str2double(localParams{indLow}(beforeLow:afterLow));
    end
    %get RMS settings
    indRMS = find(contains(localParams,'Sound detection RMS'));
    beforeRMS = strfind(localParams{indRMS}, 'threshold: ') + length('threshold: ');
    RMS(id) = str2double(localParams{indRMS}(beforeRMS:end));
    
    %get indices of vocalization events
    vocId{id} = find(strcmp('Vocalization', localEvents{EventsEventTypeCol}));
    inputBeamId{id} = find(strcmp('InputBeam', localEvents{EventsEventTypeCol}));
    
    %find total number of BB and rewards after BB
    numBB(id) = length(inputBeamId{id});
    if exist('EventsInputBeamFrontCol','var')
        inputFront(id) = nansum(localEvents{EventsInputBeamFrontCol});
        inputBack(id) = nansum(localEvents{EventsInputBeamBackCol});
        bbRewardFront(id) = nansum(localEvents{EventsFoodPortFrontCol}(inputBeamId{id}));
        bbRewardBack(id) = nansum(localEvents{EventsFoodPortBackCol}(inputBeamId{id}));
        bbNumRewards(id)= bbRewardFront(id) + bbRewardBack(id);
    end
    %calculate number of calls, and rewards after call
    numCalls(id) = length(vocId{id});
    callRewardFront(id) = nansum(localEvents{EventsFoodPortFrontCol}(vocId{id}));
    callRewardBack(id) = nansum(localEvents{EventsFoodPortBackCol}(vocId{id}));
    callNumRewards(id)= callRewardFront(id) + callRewardBack(id);
    %calculate delays to vocalize and to reward
    
    avgDelay2Reward(id) = nanmean(localEvents{EventsDelay2RewardCol}(find(~isinf(localEvents{EventsDelay2RewardCol}))));
    if exist('EventsDelay2VocCol','var')
        avgDelay2Voc(id) = nanmean(localEvents{EventsDelay2VocCol}(find(~isinf(localEvents{EventsDelay2VocCol}))));
    end
    clear 'EventsInputBeamFrontCol';
    clear 'EventsDelay2VocCol';
    %calculate call rate and rewards percentage
    callRate(id) = numCalls(id)/sessionDuration(id);
    bbRate(id) = numBB(id)/sessionDuration(id);
    callRewardPercentage(id) = 100*callNumRewards(id)/numCalls(id);
    bbRewardPercentage(id) = 100*bbNumRewards(id)/numBB(id);
    
    %get playback file names
    if exist('EventsStimFileCol','var')
        pbFiles(id) = localEvents{EventsStimFileCol};
    end
    
    %close the event and param files
    fclose(eventOpen);
    fclose(paramOpen);
end
%organize variables into structure and save mat file
behavData = struct('idString',idString,'batId',batId,'taskType',taskType,'sessionDate',num2cell(sessionDate),'sessionStartTime',num2cell(sessionStartTime),...
    'sessionNum',num2cell(sessionNum),'sessionDuration',num2cell(sessionDuration),'highPass',num2cell(highPass),'RMS',num2cell(RMS),'vocId',vocId,'inputBeamId',inputBeamId,...
    'numCalls',num2cell(numCalls),'numBB',num2cell(numBB),'inputFront',num2cell(inputFront),'inputBack',num2cell(inputBack),'callRewardFront',num2cell(callRewardFront),...
    'callRewardBack',num2cell(callRewardBack),'callNumRewards',num2cell(callNumRewards),'callRewardPercentage',num2cell(callRewardPercentage),'callRate',...
    num2cell(callRate),'bbRewardFront',num2cell(bbRewardFront),'bbRewardBack',num2cell(bbRewardBack),'bbNumRewards',num2cell(bbNumRewards),'bbRate',num2cell(bbRate),...
    'bbRewardPercentage',num2cell(bbRewardPercentage),'avgDelay2Reward',num2cell(avgDelay2Reward),'avgDelay2Voc',num2cell(avgDelay2Voc),'pbFiles',pbFiles);
save(fullfile(fileList(1).folder, ['\behavData_' fileList(1).name(6:11) '_to_' fileList(end).name(6:11) '.mat']),'behavData')
end

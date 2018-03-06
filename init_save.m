function init_save(boxNum)

global debugButton sessionType sessionID batName;
global logFileId formatSpec EventStartSession;
global motorS motorT ledCue maxDelay minInt maxInt ledTimeOut maxTimeOut dunceCap;
global fs motuGain recDur ampThresh durThresh comments minWait channel rmsThresh;

date = datestr(now, 'yymmdd');

% save parameters
paramPath = 'C:\Users\tobias\Desktop\behavior\autoTrain\parameters\';
if boxNum == 5
    paramFile = strcat('autoTrain_parameters_log_box5_170103_ts.csv');
elseif boxNum == 7
    paramFile = strcat('autoTrain_parameters_log_box7_170103_ts.csv');
elseif boxNum == 1
    paramFile = strcat('autoTrain_parameters_log_box1_170103_ts.csv');
elseif boxNum == 2
    paramFile = strcat('autoTrain_parameters_log_box2_170103_ts.csv');
end

if debugButton == 0
    fprintf('Log Saved\n');
    logFileId2 = fopen(strcat(paramPath,paramFile),'a');
    formatSpec2 = '%s,%s,%s,%s,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%s\n'; 
     %Headers: only do on first time making new file
%       fprintf(logFileId2, '%s\n',['date, sessionType, sessionID, batName,'...
%          'motorSpeed, rewardTime, cueLED, maxDelay, minWait, minInt, maxInt, timeOutLED, max#TimeOut, dunceCapTime,'...
%          'sampling, channel, motuGain, recDur, ampThresh, durThresh, rmsThresh, comments']);  
    fprintf(logFileId2, formatSpec2, datestr(now,30), sessionType, sessionID, batName,...
        motorS, motorT, ledCue, maxDelay, minWait, minInt, maxInt, ledTimeOut, maxTimeOut, dunceCap,...
        fs, channel, motuGain, recDur, ampThresh, durThresh, rmsThresh, comments);
%     fclose(logFileId2);
elseif debugButton == 1
    fprintf('Log Not Saved: %s\n', datestr(now, 'HH:MM:SS'));
end

% save events
logPath = 'C:\Users\tobias\Desktop\behavior\autoTrain\events\';
fileName = strcat('autoTrain_events_log_',batName,'_ts.csv');
%logPath = '/Users/tobiasschmid/matlabtest/'; %for macs
if debugButton == 0
    logFileId = fopen(strcat(logPath,fileName),'a');
    formatSpec = '%s,%s,%s,%s,%s,%f,%f,%f,%f,%s\n'; %date, sessionType, session#, batname, comments eventType, trialNum, callNum, rewardNum, callOnly, comments
    %Headers: only do on first time making new file
%     fprintf(logFileId, '%s\n','Date,SessionType,SessionId,BatName,Event,TrialNumber,CallNumber,RewardNumber,CallOnly,Comments');  %Headers
    fprintf(logFileId, formatSpec, datestr(now,30),...
        sessionType, sessionID, batName, EventStartSession,'','','','',comments);
    fprintf('Begin Session: %s\n', datestr(now,21));
end
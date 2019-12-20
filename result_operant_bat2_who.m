function [WhoDataYN]=result_operant_bat2_who(Path2ParamFile, Logger_dir)
%% !!! CHANGE TO ADAPT TO COMPUTER
OutputDataPath = 'Z:\users\tobias\vocOperant\Results';
PathToGithubFolder = 'C:\Users\Eva\Documents\GitHub';
FileBatList = fullfile(OutputDataPath,'BatList.txt');
Path2LocalDocuments = 'C:\Users\Eva\Documents';
WorkDir = fullfile(Path2LocalDocuments, 'WorkingDirectoryWho');
%% !!!

addpath(genpath(fullfile(PathToGithubFolder,'operant_bats')))
addpath(genpath(fullfile(PathToGithubFolder,'LoggerDataProcessing')))
addpath(genpath(fullfile(PathToGithubFolder,'SoundAnalysisBats')))
addpath(genpath(fullfile(PathToGithubFolder,'LMC')))
ForceWhoID = 0; % In case the identification of bats was already done but you want to re-do it again
% ForceWhat = 1; % In case running biosound was already done but you want to re-do it
UseOld = 0; % Set to 1 if you want to use old data in Who calls
close all
% Get the recording data
[AudioDataPath, DataFile ,~]=fileparts(Path2ParamFile);
Date = DataFile(6:11);
ExpStartTime = DataFile(13:16);

% Starting a diary
Now=clock;
Diary_filename = fullfile(OutputDataPath, sprintf('%s_DiaryWhocalls%s_%d%d%d.txt', DataFile(1:end-6),date,Now(4),Now(5),round(Now(6))));
diary(Diary_filename)
diary on

if nargin<2
    % Set the path to logger data
    Logger_dir = fullfile(AudioDataPath(1:(strfind(AudioDataPath, 'bataudio')-1)), 'piezo',Date,'audiologgers');
end

%% Getting the info from the bat list
fid = fopen(FileBatList);
Header = textscan(fid,'%s\t%s\t%s\t%s\t%s\n',1);
Data = textscan(fid,'%s\t%s\t%s\t%s\t%s');
fclose(fid);

%% Getting info from the param file for that day
[dataParam] = extractParam(Path2ParamFile);

%% Finding the ID of the bat wearing the collar
% Find all the logger directories
All_loggers_dir = dir(fullfile(Logger_dir, '*ogger*'));
fprintf(1,'*** Finding the ID of the bat wearing the piezo collar ***\n');


DirFlags = [All_loggers_dir.isdir];
% Extract only those that are directories.
All_loggers_dir = All_loggers_dir(DirFlags);
LoggerName = cell(length(All_loggers_dir),1);

% This will contain the ID of the bat wearing the logger/piezo
BatID = cell(length(All_loggers_dir),1);

for ll=1:length(All_loggers_dir)
    % Find the logger ID
    Ind = strfind(All_loggers_dir(ll).name, 'r');
    Logger_num = str2double(All_loggers_dir(ll).name((Ind+1):end));
    LoggerName{ll} = ['AL' num2str(Logger_num)];
    % Looking if only front bat wore a collar, if only back bat wore a
    % collar, then if both wore a collar then compare date ranges
    if strcmp(Data{3}{find(contains(Data{1},dataParam.batFront(1:2)))},'Y') == 1 && strcmp(Data{3}{find(contains(Data{1},dataParam.batBack(1:2)))},'N') == 1
        BATID = dataParam.batFront;
    elseif strcmp(Data{3}{find(contains(Data{1},dataParam.batFront(1:2)))},'N') == 1 && strcmp(Data{3}{find(contains(Data{1},dataParam.batBack(1:2)))},'Y') == 1
        BATID = dataParam.batBack;
    elseif strcmp(Data{3}{find(contains(Data{1},dataParam.batFront(1:2)))},'Y') == 1 && strcmp(Data{3}{find(contains(Data{1},dataParam.batBack(1:2)))},'Y') == 1
        if str2num(Data{4}{find(contains(Data{1},dataParam.batFront(1:2)))}) <= str2num(Date) && str2num(Data{5}{find(contains(Data{1},dataParam.batFront(1:2)))}) >= str2num(Date)
            BATID = dataParam.batFront;
        else
            BATID = dataParam.batBack;
        end
    end
    BatID{ll} = BATID;
end


%% Identify who is calling
Delay2MergeCalls = 10;% in ms
fprintf(' IDENTIFY WHO IS CALLING\n')
WhoCall_dir = dir(fullfile(Logger_dir, sprintf('*%s_%s*whocalls*', Date, ExpStartTime)));
if ~isempty(WhoCall_dir)
    ForceWhoID = input('Data already fully or half processed do you want to resume? (yes->1 no->0)\n');
    if ForceWhoID
        UseOld = input('Do you want to use old data (or start from scratch)? (yes use old data->1 no->0)\n');
    end
end
if isempty(WhoCall_dir) || ForceWhoID
    who_calls(AudioDataPath, Logger_dir,Date, ExpStartTime,Delay2MergeCalls,1,UseOld,1, 'Factor_RMS_Mic',3,'Working_dir',WorkDir);
else
    fprintf(1,'Using already processed data\n')
end
% Save the ID of the bat for each logger
save(fullfile(Logger_dir, sprintf('%s_%s_VocExtractData_%d.mat', Date, ExpStartTime, Delay2MergeCalls)), 'BatID','LoggerName','-append')

%      %% Explore what is said
%     fprintf('\n*** Identify what is said ***\n')
%     WhatCall_dir = dir(fullfile(Logger_dir, sprintf('*%s_%s*whatcalls*', Date, ExpStartTime)));
%     if isempty(WhatCall_dir) || ForceVocExt1 || ForceWhoID || ForceVocExt2 || ForceWhat
%         what_calls(Logger_dir,Date, ExpStartTime);
%     else
%         fprintf('\n*** ALREADY DONE: Identify what is said ***\n')
%     end
WhoCall_dir = dir(fullfile(Logger_dir, sprintf('*%s_%s*whocalls*', Date, ExpStartTime)));
WhoDataYN = ~isempty(WhoCall_dir);


diary off


end

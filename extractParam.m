function [dataParam] = extractParam(filepath)
fid = fopen(filepath);
data = textscan(fid,'%s','Delimiter', '\t');
fclose(fid);

% Bat in the front:
% FIND THE LINE of your data
IndexLine = find(contains(data{1}, 'front'));
IndexChar = strfind(data{1}{IndexLine},':');

% find the data into that line
Temp = (data{1}{IndexLine}(IndexChar + 2:end-1));
if length(Temp)>5
    dataParam.batFront = Temp(1:5);
elseif length(Temp)<5
    dataParam.batFront = strrep([Temp num2str(zeros(1,2))],' ','');
else
    dataParam.batFront = Temp;
end

% Bat in the back:
IndexLine = find(contains(data{1}, 'the back'));
IndexChar = strfind(data{1}{IndexLine},':');
Temp = (data{1}{IndexLine}(IndexChar + 2:end-1));
if length(Temp)>5
    dataParam.batBack = Temp(1:5);
elseif length(Temp)<5
    dataParam.batBack = strrep([Temp num2str(zeros(1,2))],' ','');
else
    dataParam.batBack = Temp;
end

% Session type:
IndexLine = find(contains(data{1}, 'Session type'));
IndexChar = strfind(data{1}{IndexLine},':');
dataParam.sessionType = (data{1}{IndexLine}(IndexChar + 2:end-1));

% Session #:
IndexLine = find(contains(data{1}, 'Session #'));
IndexChar = strfind(data{1}{IndexLine},':');
dataParam.sessionNumber = (data{1}{IndexLine}(IndexChar + 2:end-1));

% Motu gain:
IndexLine = find(contains(data{1}, 'Motu gain'));
IndexChar = strfind(data{1}{IndexLine},':');
dataParam.motuGain = (data{1}{IndexLine}(IndexChar + 2:end));

% Sound detection amplitude threshold:
IndexLine = find(contains(data{1}, 'amplitude threshold'));
IndexChar = strfind(data{1}{IndexLine},':');
dataParam.amplitudeThresh = (data{1}{IndexLine}(IndexChar + 2:end));

% Sound detection duration threshold:
IndexLine = find(contains(data{1}, 'duration threshold'));
IndexChar = strfind(data{1}{IndexLine},':');
dataParam.durationThresh = (data{1}{IndexLine}(IndexChar + 2:end));

% Sound detection high-pass filter frequency threshold:
IndexLine = find(contains(data{1}, 'high-pass filter'));
IndexChar = strfind(data{1}{IndexLine},':');
dataParam.hpFilterThresh = (data{1}{IndexLine}(IndexChar + 2:end));

% Sound detection low-pass filter frequency threshold
IndexLine = find(contains(data{1}, 'low-pass filter'));
IndexChar = strfind(data{1}{IndexLine},':');
dataParam.lpFilterThresh = (data{1}{IndexLine}(IndexChar + 2:end));

% Sound detection RMS threshold:
IndexLine = find(contains(data{1}, 'RMS threshold'));
IndexChar = strfind(data{1}{IndexLine},':');
dataParam.RMSthresh = (data{1}{IndexLine}(IndexChar + 2:end));

% Time delay to get reward:
IndexLine = find(contains(data{1}, 'Time delay'));
IndexChar = strfind(data{1}{IndexLine},':');
dataParam.rewardTimeDelay = (data{1}{IndexLine}(IndexChar + 2:end));

% Reward duration:
IndexLine = find(contains(data{1}, 'Reward duration'));
IndexChar = strfind(data{1}{IndexLine},':');
dataParam.rewardDuration = (data{1}{IndexLine}(IndexChar + 2:end));

% Rewarding playback:
IndexLine = find(contains(data{1}, 'Rewarding playback'));
IndexChar = strfind(data{1}{IndexLine},':');
dataParam.rewardingPlayback = (data{1}{IndexLine}(IndexChar + 2:end));
end



%load the sound files
function [call] = load_recData(behavParamData)
load(behavParamData);
recList = dir('*_mic*.wav');

for recId = 1:length(recList)
   [recData,Fs] = audioread(fullfile(recList(recId).folder,recList(recId).name)); 
end

end
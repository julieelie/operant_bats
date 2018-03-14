function [Box]=init_soundmex(Box)
%% Initialize recording and playback channels, audio saving paths, AmpTracks and audio buffer filename
% When channels are set up as vectors, soundmexPro will pick which ever
% from those has signal
if Box.ID == 1
    Box.Channels.Rec = 0; % or (0:1)
    Box.Channels.Play = 2; %change this back when get all output hardware 
elseif Box.ID == 2
    Box.Channels.Rec = 0; % or (0:1)
    Box.Channels.Play = 2; 
elseif Box.ID == 5
    Box.Channels.Rec = (0:2); % or (0:1) 
    Box.Channels.Play = 2; 
    %Box.Channels.Trigger=1;
elseif Box.ID == 7
    Box.Channels.Rec = 1; % or (0:1)
    Box.Channels.Play = 3;
    %Box.Channels.Trigger=2;
elseif Box.ID == 9
    Box.Channels.Rec = 0; % or (0:1)
    Box.Channels.Play = 1;
end
Curr_path = pwd;
filepartitions=strfind(Curr_path, '\');
Box.RecPath=sprintf('%s\\Desktop\\bataudio\\autoTrain\\box_%d\\', Curr_path(1:(filepartitions(3)-1)), Box.ID);
Box.SoundCard.Track=0;
Box.SoundCard.BufferFile=sprintf('rec_box%d.wav', Box.ID);

%% set default parameters for audio input filtering (Will get from gui)
Box.SoundCard.fs=192000;
Box.SoundCard.feedback_threshold_output=-35; %keep high and gain with the cuemix
Box.SoundCard.feedback_min_dur=0.005;
Box.SoundCard.pre_trg=0.1;

%% trigger video onset
%vt = load('C:\Users\tobias\Desktop\code\initiation\Trigger_Pulse.mat');
%video_trigger = vt.trigger;

%% initiate soundmexpro
ID='MOTU Audio ASIO';
nbufs=2; %Set the # of buffers?
soundmexpro('init','driver',ID,'samplerate',Box.SoundCard.fs,'input',Box.Channels.Rec,...
    'output',Box.Channels.Play,'track',length(Box.Channels.Play),'numbufs',nbufs); %[playchan5 triggerchan5]
soundmexpro('show')

%% get asio properties
[~,fsq,Box.SoundCard.bufsiz]=soundmexpro('getproperties');
Box.SoundCard.feedbbuf=round(Box.SoundCard.feedback_min_dur*fsq/Box.SoundCard.bufsiz);


%% map tracks to output channels
[success, trackmapcheck] = soundmexpro('trackmap', ...
    'track', Box.SoundCard.Track...        % new mapping
);

%% check clipthreshold
if 1 ~= soundmexpro('clipthreshold','type','input','value',...
        10^(Box.SoundCard.feedback_threshold_output/20))
    error('error setting clipthreshold %s\n', datestr(now,30));
end
if 1 ~= soundmexpro('recpause','value', ones(1,1),...
        'channel',0)
    error('error setting recpause %s\n', datestr(now,30));
end

%% Set buffer filename
soundmexpro('recfilename', 'filename', Box.SoundCard.BufferFile, 'channel', 0);

end

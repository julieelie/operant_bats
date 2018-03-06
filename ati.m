function ati(boxNum)
%clear all;
close all;

global fh starth nameh quith reconlyh thrdh thrah recdh thrfh thrrh motugh;
global dateh sessionth sessionidh commenth batnameh recbuttonh;
global recShift recCont ignoreTime maxrewardh minwaith instaReward;
global motorSh motorTh cueledh rewardledh timeoutledh trainonh debugbuttonh;
global maxdelayh minbreakh mininth maxinth traintimeh maxtimeouth duncecaph;
global EventTrialStart EventOnly EventReward EventStartTrialFront EventStartTrialBack EventReward2 EventSleep EventComment EventCue EventCall2;
global EventStartSession EventResetSession EventNoGo EventCall EventSessionDone EventRecsOnly;
global startOnBeamTime ledTime1 ledTime2 ledTime3 loopTime beamActiveTime EventDunceCap recchan;
global callNum trialNum rewardNum callOnly recchanh playchan playbackfileh;
global playbackbuttonh responseth EventPlayback minbwh playh sleeptimeh sleeponh;
global trigChan1 trigChan2;
% global triggerchan
% global boxNum

%boxNum = boxNum;
startup % Sending a message when syring are low

% Initiate a structure for the box
Box.ID = boxNum;

%% initiate arduino
[Box]=init_arduino(Box);

%% initiate SoundMex
[Box]=init_soundmex(Box);

%% initiate gui
fh=autoTraingui(Box.ID);
%set(fh,'Position',[ 0.6000   37.5385  103.4000   39.7692]);
starth=findobj(fh,'tag','start');
set(starth,'enable','off');
nameh=findobj(fh,'tag','name');
quith=findobj(fh,'tag','quit');
reconlyh=findobj(fh,'tag','reconly');
thrdh=findobj(fh,'tag','thrdur');
thrah=findobj(fh,'tag','thramp');
thrfh=findobj(fh,'tag','thrfreq');
thrrh=findobj(fh,'tag','thrrms');
recdh=findobj(fh,'tag','recd');
motugh=findobj(fh,'tag','motuGain');
dateh=findobj(fh,'tag','dateTime');
sessionth=findobj(fh,'tag','sessionType');
sessionidh=findobj(fh,'tag','sessionID');
batnameh=findobj(fh,'tag','batName');
commenth=findobj(fh,'tag','comments');
motorSh=findobj(fh,'tag','motorS');
motorTh=findobj(fh,'tag','motorT');
cueledh=findobj(fh,'tag','ledCue');
rewardledh=findobj(fh,'tag','ledReward');
timeoutledh=findobj(fh,'tag','ledTimeOut');
maxdelayh=findobj(fh,'tag','maxDelay');
minbreakh=findobj(fh,'tag','minBreak');
mininth=findobj(fh,'tag','minInt');
maxinth=findobj(fh,'tag','maxInt');
minbwh=findobj(fh,'tag','minBW');
traintimeh=findobj(fh,'tag','trainT');
trainonh=findobj(fh,'tag','trainOn');
maxtimeouth=findobj(fh,'tag','maxTimeOut');
duncecaph=findobj(fh,'tag','dunceCap');
recbuttonh=findobj(fh,'tag','recButton');
debugbuttonh=findobj(fh,'tag','debugButton');
maxrewardh=findobj(fh,'tag','maxReward');
minwaith=findobj(fh,'tag','minWait');
recchanh=findobj(fh,'tag','recChan');
playbackfileh=findobj(fh,'tag','playbackFile');
playbackbuttonh=findobj(fh,'tag','playbackButton');
responseth=findobj(fh,'tag','responseT');
playh = findobj(fh,'tag','play');
sleeptimeh=findobj(fh,'tag','sleepT');
sleeponh=findobj(fh,'tag','sleepOn');
boxnh=findobj(fh,'tag','boxN');
boxn = set(boxnh,'string',boxNum); %set the gui with the boxNum

%Events
EventTrialStart='TRIAL_START';
EventCall='CALL_REC';
EventReward='REWARD';
EventCue='CUE';
EventStartSession='START_SESSION';
EventResetSession='RESET_SESSION';
EventStartTrialFront='TRIAL_BEAM_BREAK_Front';
EventStartTrialBack='TRIAL_BEAM_BREAK_Back';
EventNoGo='TIME_OUT';
EventSessionDone='SESSION_OVER';
EventRecsOnly='RECS_ONLY';
EventDunceCap='DUNCE_CAP_ON';
EventReward2='REWARD_GIFTED';
EventComment='COMMENT';
EventSleep='AUTO_OFF';
EventCall2='CALL_CONT';
EventOnly='CALL_ONLY';
EventPlayback = 'PLAYBACK';

%Timers
startOnBeamTime = tic; %start counting when bat broke beam
ledTime1 = tic; %timer for timeout LED
ledTime2 = tic; %timer for active LED
ledTime3 = tic; %timer for reward LED
loopTime = tic; %measures time for each loop to process
beamActiveTime = tic; %measures time since beam loop has become active after button pushed


%variable parameters
recShift=0.6; %adjusts timing for grabbing audio from buffer
recCont=0.1; %threshold for triggering cont set of recordings after initial trigger
ignoreTime=300; % min for when to reset timeout counter if not paying attention
instaReward=0.3; %min amt of time (sec) that must wait til saving call so don't cut off call if instantly get reward

trialNum = 1; %sets trial counter (+1 for cue light on or call)
rewardNum=0; %sets reward counter (+1 for reward)
callNum=0; %sets call counter when start whole autoTrain (+1 for call)
callOnly=0; %sets call counter for recOnly calls

% set(starth,'enable','off');









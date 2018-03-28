function vocOperant2(action)

global Box Gui

% Set handles for main buttons
Gui.ActionButtons.starth=findobj(Gui.MainHandle,'tag','start');
set(starth,'enable','off');
Gui.ActionButtons.quith=findobj(Gui.MainHandle,'tag','quit');



Gui.Metadata.nameh=findobj(Gui.MainHandle,'tag','name');

Gui.SoundDetect.thrdurh=findobj(Gui.MainHandle,'tag','thrdur');
Gui.SoundDetect.thramph=findobj(Gui.MainHandle,'tag','thramp');
Gui.SoundDetect.thrfreqh=findobj(Gui.MainHandle,'tag','thrfreq');
Gui.SoundDetect.thrrmsh=findobj(Gui.MainHandle,'tag','thrrms');

reconlyh=findobj(Gui.MainHandle,'tag','reconly');
recbuttonh=findobj(Gui.MainHandle,'tag','recButton');
debugbuttonh=findobj(Gui.MainHandle,'tag','debugButton');




recdh=findobj(Gui.MainHandle,'tag','recd');
motugh=findobj(Gui.MainHandle,'tag','motuGain');

dateh=findobj(Gui.MainHandle,'tag','dateTime');
sessionth=findobj(Gui.MainHandle,'tag','sessionType');
sessionidh=findobj(Gui.MainHandle,'tag','sessionID');
batnameh=findobj(Gui.MainHandle,'tag','batName');
commenth=findobj(Gui.MainHandle,'tag','comments');

motorSh=findobj(Gui.MainHandle,'tag','motorS');
motorTh=findobj(Gui.MainHandle,'tag','motorT');
cueledh=findobj(Gui.MainHandle,'tag','ledCue');
rewardledh=findobj(Gui.MainHandle,'tag','ledReward');
timeoutledh=findobj(Gui.MainHandle,'tag','ledTimeOut');
maxdelayh=findobj(Gui.MainHandle,'tag','maxDelay');
minbreakh=findobj(Gui.MainHandle,'tag','minBreak');

mininth=findobj(Gui.MainHandle,'tag','minInt');
maxinth=findobj(Gui.MainHandle,'tag','maxInt');
minbwh=findobj(Gui.MainHandle,'tag','minBW');
traintimeh=findobj(Gui.MainHandle,'tag','trainT');
trainonh=findobj(Gui.MainHandle,'tag','trainOn');
maxtimeouth=findobj(Gui.MainHandle,'tag','maxTimeOut');
duncecaph=findobj(Gui.MainHandle,'tag','dunceCap');

maxrewardh=findobj(Gui.MainHandle,'tag','maxReward');
minwaith=findobj(Gui.MainHandle,'tag','minWait');

recchanh=findobj(Gui.MainHandle,'tag','recChan');
playbackfileh=findobj(Gui.MainHandle,'tag','playbackFile');
playbackbuttonh=findobj(Gui.MainHandle,'tag','playbackButton');
responseth=findobj(Gui.MainHandle,'tag','responseT');
playh = findobj(Gui.MainHandle,'tag','play');
sleeptimeh=findobj(Gui.MainHandle,'tag','sleepT');
sleeponh=findobj(Gui.MainHandle,'tag','sleepOn');
boxnh=findobj(Gui.MainHandle,'tag','boxN');
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

switch action
    %% START button pushed
    case 'START' %start button pushed
        %% Set values of parameters common to all protocols
        % Timeline of the experiment (limit on experiment duration, any break
        % requested...)



        % Sound detection parameters (detection thresholds and possible
        % acoustic properties requirements if requested)


        % Reward parameters (delay to go to the food port upon triger, duration
        % of reward, motor syringe speed)
    
    
        %% Get value of button handles and find which Protocol was chosen and run the corresponding loop!

        % ProductionReward: every vocalization of the bat is rewarded. If the
        % detected call reach thersholds and, if requested, hit any requirements in terms of
        % acoustic properties, then the LED cue turns on and the bat has xs
        % (MaxDelay) to come at the feedport and break the food beam to get a
        % reward
        ProtocolAll=get(Protocolh,'string'); %select all strings in dropdown menu
        Protocol=ProtocolAll{get(Protocolh,'value')}; %select the string you chose
        if strcmp(Protocol, 'ProductionReward')
            fprintf(1,'Starting ProductionReward protocol\n');
            ProdRe(Box)
        else
            fprintf(1,'It is time to make your choice of protocol and try hit Start again!\n');
        end
    


    %% stop the protocol session
    case 'Stop'
        
        fprintf('Stop the protocol\n')
      
        
        
    %% Buttons for checking motor actions    
    case 'Reward'
        fprintf('Deliver manually a reward\n')
        
    case 'Reset'
        fprintf('Reset the motor to initial position, seringe totally pulled out.\n')
        
    case '+'
        fprintf('Manually move the motor forward\n')
        
    case '-'
        fprintf('Manually move the motor backward\n')
        
        
        
        
     %% Buttons for Lighting up LEDs
    case 'Cue'
        fprintf('Manually light on the cue LED cue for 1s')
    
    case 'Time out'
        fprintf('Manually light on the time-out LED for 1s')
    
        
        
    %% Buttons for testing sound playback    
    case 'Play'
        fprintf('Play a file to check that sound is on.\nChoose from drop menu or the default one\n')
        
        %% Quit the program
    case 'Quit'
        fprintf('Quit the program and exit matlab\n')
        
        
end
end
    



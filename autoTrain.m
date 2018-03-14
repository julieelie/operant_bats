function autoTrain(action)

global fs pre_trg feedbbuf bufsiz recPath xrun recstart;
global a ledPin1 ledPin2 ledPin3 beamPin1 beamPin2 beamPin3 dunceCap;
global debugButton logFileId formatSpec trialNum callNum rewardNum callOnly;
global date sessionType sessionID comments batName offTime ignoreTime;
global dcm motorS motorT ledCue ledTimeOut maxDelay minInt maxInt maxTimeOut;
global motuGain recDur ampThresh durThresh traintimeh freqThresh B A;
global fh starth thrdh thrah recdh motugh thrrh thrfh rmsThresh minW maxR;
global dateh sessionth sessionidh commenth batnameh debugbuttonh minWait;
global motorSh motorTh cueledh timeoutledh recbuttonh trainonh recchanh;
global maxdelayh mininth maxinth maxtimeouth duncecaph minwaith maxrewardh;
global EventTrialStart EventDunceCap EventReward EventRecsOnly EventCue EventSleep;
global EventResetSession EventNoGo EventCall EventSessionDone EventReward2 EventCall2;
global ledTime1 beginSession beamVal1 beamVal2 beamVal3 stopped recShift recCont playh;
global EventComment lastReward EventStartSession DayNumberStop instaReward channel playback_i;
global playbackbuttonh playbackfileh responseth EventPlayback playbackFile responseTime;
global playbackF minbwh minBetween boxNum track timeOutCount beamBreakTrg playbackCountdown;
global filepn directory file_i fileseq playbackButton recOnlyButton responseTrg playbackTimer;
global timelapse callOnlyTrigger n micType callTrigger autoOff maxReward responseTimer playbackTrg;
global beamBreak sleeponh sleeptimeh sleepTime recchan resetTrg offTrg; 

switch action
    %% START button pushed
    case 'START' %start button pushed
        %% Set a bunch of parameters
        % Start the timer that keeps track of session duration
        beginSession=tic;
        
        % Make sure that all LEDs are turned off
        writeDigitalPin(Box.Arduino,Box.LEDPin1,0); %turn off time out led
        writeDigitalPin(Box.Arduino,Box.LEDPin2,0); %turn off green led
        writeDigitalPin(Box.Arduino,Box.LEDPin3,0); %turn off blue led
        
                                                                                % Keep track of the day of the week
                                                                                Dstart=datetime;
                                                                                DayNumberStart=weekday(Dstart);
        
        % Turn unaccessible all the parameters buttons
        set([thrah thrdh thrfh thrrh recdh sessionth sessionidh batnameh ...
            motorSh motorTh cueledh timeoutledh debugbuttonh ...
            motugh maxdelayh recchanh mininth maxinth maxtimeouth ...
            duncecaph minwaith responseth minbwh],'enable','off'); %turn off
        
        %get parameters for recording !!! WHY SETTING THIS AGAIN WHEN IT
        %WAS DEFINE FOR SOUNDMEXPRO IN INIT_SOUNDMEX?
        recC=cellstr(get(recchanh,'string')); %set channel 1 or 2 recording
        chanC=recC{get(recchanh,'value')}; %should be 1 or 2
        channel=str2double(chanC);
        
                                                                                %set amplitude threshold
                                                                                thrsha=get(thrah,'string'); 
                                                                                ampThresh=str2double(thrsha);%-35;

                                                                                % set clipthreshold                         %%UNSURE ABOUT WHAT THIS LINE IS DOING
                                                                                if 1 ~= soundmexpro('clipthreshold','type','input','value',...
                                                                                        10^(ampThresh/20))
                                                                                    error('error setting clipthreshold');
                                                                                end
        
        %set freq trigger threshold
        thrshf=get(thrfh,'string');
        freqThresh=str2double(thrshf);
        % design a 4th order high pass Butterworth filter with cutoff
        % frequency at freqThresh
        [B,A]=butter(4,2*freqThresh*1000/fs,'high'); %increase freqthresh to make higher thresh
        
        % set RMS trigger threshold
        thrshr=get(thrrh,'string');
        rmsThresh=str2double(thrshr);
        
        % set recording duration from gui
        recd=get(recdh,'string');
        recDur=str2double(recd);
        
                                                                                % set record length for audio ring buffer
                                                                                if 1 ~= soundmexpro( 'recbufsize', 'value', recDur*fs)
                                                                                    error(['error calling ''loadfile''' error_loc(dbstack)]);
                                                                                end
        
        % set duration threshold from gui
        thrshd=get(thrdh,'string');
        durThresh=str2double(thrshd);%0.005;
        feedbbuf=round(durThresh*fs/bufsiz); %make proper buffer size (threshdur & fs dependent)
        
        %set motu gain from gui for saving purposes
        motug=get(motugh,'string');
        motuGain=str2double(motug); %ex 25
        
                                %load playback file
                                playbackF=get(playbackfileh,'string'); %select all strings in dropdown menu
                                playbackF2=playbackF{get(playbackfileh,'value')}; %select the string you chose
                                load(playbackF2); %load that file for playback
                                playbackFile = recbuf; %may need to change recbuf if it is a different variable
                                playbackButton = get(playbackbuttonh,'value');
                                responseT=get(responseth,'string'); %get value for timer for how long bat has to respond
                                responseTime=str2double(responseT);
                                fileseq = randperm(length(directory));
                                filepn='C:\Users\tobias\Desktop\bataudio\autoTrain\trills\Cooper\'; %can change file path to match specific bat
                                directory = dir([filepn '*.mat']);
                                file_i = 1;
        
        %get parameters for arduino/reward
        dcmS=get(motorSh,'string');
        dcm.Speed = str2num(dcmS); %speed must be between -1 and 1
        motorS = str2num(dcmS); %set variable for saving speed
        dcmT=get(motorTh,'string');
        motorT= str2num(dcmT);
        ledC =get(cueledh,'string');
        ledCue= str2num(ledC);
        ledTO =get(timeoutledh,'string');
        ledTimeOut = str2num(ledTO);
        maxTO =get(maxtimeouth,'string');
        maxTimeOut= str2num(maxTO);
        maxD =get(maxdelayh,'string');
        maxDelay = str2num(maxD);
        dunceC =get(duncecaph,'string');
        dunceCap= str2num(dunceC);
        minI=get(mininth,'string');
        minInt =str2num(minI);
        maxI=get(maxinth,'string');
        maxInt= str2num(maxI);
        maxR=get(maxrewardh,'string');
        maxReward=str2num(maxR);
        minW=get(minwaith,'string');
        minWait=str2num(minW);
        minBW=get(minbwh,'string');
        minBetween=str2num(minBW);
        
                                                                                %random playback interval generator
                                                                                mresponse = minInt;
                                                                                Mresponse = maxInt;
                                                                                reps = 500000;
                                                                                playbackCountdown=  mresponse +(Mresponse-mresponse).*rand(reps,1);
        
        %get training button & sleepTime parameters
        trainingButton=get(trainonh,'value');
        offTime=get(traintimeh,'string');
        autoOff=str2num(offTime);
        sleepButton=get(sleeponh,'value');
        sleepTime=get(sleeptimeh,'string');
        trainEnd=str2num(sleepTime(1:2));
        trainStart=str2num(sleepTime(4:5));
        
        %get recOnly training button
        recOnlyButton=get(recbuttonh,'value');
        
        %get debug button
        debugButton=get(debugbuttonh,'value');
        if debugButton == 1
            fprintf('Debug session begin >>>>> %s\n',datestr(now,21));
        end
        
                                                                                %optional trial interval control
                                                                                timeInt=minInt:1:maxInt; %trial initiation intervals from 1-5 min spaced 30sec
                                                                                seq=repmat(timeInt',1000,1); %generate matrix of random spaced numbers
                                                                                seqOrder=randperm(length(seq)); %scramble the order of the vectors
        
        %set save parameters
        date = datestr(now,0);
        dateTime = set(dateh,'string',date); %sets the date into the gui
        sessionType = get(sessionth,'string');
        sessionID = get(sessionidh,'string');
        batName = get(batnameh,'string');
        comments = get(commenth,'string');
        micType = ['EW ' boxNum];
        %recpath=['a' date '_'  sessionType '_' sessionID '_' batName '_ts']; %filename for saving calls
        
        
        %% Initialize output files
        init_save(boxNum) %saves parameter log and creates new event log
        
        
        
        %% control vals for button and beam
        beamBreak = 0; %beam is broken, bat is at port
        beamOpen = 1; %beam is open, bat is away
        beamTime1 = tic;
        beamTime2 = tic;
        timelapse = tic;
        responseTimer = tic;
        responseTrg = 0;
        timeOutCount=0; %sets timeout counter to start at 0
        beamBreakTrg=beamOpen;
        beamBreakCount=0;
        timeOutTrg=0;
        playbackTrg=0;
        resetTrg = 0;
        %         %autoreset of trial,call,and reward counts
        %         Dinit=datetime;
        %         DayNumberInit=weekday(Dinit);
        %         DayNumberStop=DayNumberInit-1;
                                                                            if DayNumberStart~=DayNumberStop
                                                                                trialNum = 0; %sets trial counter (+1 for cue light on or call)
                                                                                rewardNum=0; %sets reward counter (+1 for reward)
                                                                                callNum=0; %sets call counter when start whole autoTrain (+1 for call)
                                                                                callOnly=0; %sets call counter for recOnly calls
                                                                            end
        
        
        %% start the audio recording
        soundmexpro('start', ...    % command name
            'length', 0 ...
            );
        soundmexpro('show');
        %switch start button to stop format
        set(starth,'string','STOP','backgroundcolor',[255/255 51/255 51/255]);
                                                                            lastReward=tic; %start timer for last reward for DunceCap
                                                                            stopped=0;
        
        %start general recording audio loop
        playback_i=0;
        while strcmp(get(starth,'string'),'STOP')  %when start button is pushed (in stop format)
            drawnow;
            
            %starting parameters
            trg=0; %not recording state
            offTrg =0;
            responseTrg = 0;
            beamVal1 = readDigitalPin(a, beamPin1); %check init beam break
            beamVal3= beamOpen; %not reward beam state
            beamVal2 = beamOpen; %not reward beam state
                                                                            ledLoopTime=tic; %timer for cue LED loop
                                                                            playbackTimer=tic;%timer for playback countdown
            soundmexpro('resetclipcount'); %resets clip to 0 so don't accumulate clips when go back into waiting loop
            
            % get audio input information at all times
            [succ, clipout,clipin]=soundmexpro('clipcount');
            
                                                                            %max Num Reward tag remains open ALREADY DONE AT THE BEGINING OF THE FILE!
                                                                            maxR=get(maxrewardh,'string');
                                                                            maxReward=str2num(maxR);
            
            %rec only button option remains open
                                                                            recOnlyButton=get(recbuttonh,'value'); %THIS SHOULD GO HIGHER UP
            if recOnlyButton ==1 && playbackButton ==0
                fprintf('Recs Only >>>>> %s\n', datestr(now, 21));
                if debugButton == 0
                    fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                        sessionType, sessionID, batName, EventRecsOnly,trialNum,callNum,rewardNum,callOnly,comments);
                end
                while recOnlyButton ==1 && playbackButton == 0 && strcmp(get(starth,'string'),'STOP')
                    playbackButton = get(playbackbuttonh,'value'); %switch out if push playback
                    recOnlyButton=get(recbuttonh,'value'); %always check recOnly button
                    recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
                    if recOnlyButton == 0 && strcmp(get(starth,'string'),'STOP')
                        fprintf('Begin Session: %s\n', datestr(now,21));
                        if debugButton == 0
                            fprintf(logFileId, formatSpec, datestr(now,'yyyymmddTHHMMSSFFF'),...
                                sessionType, sessionID, batName, EventStartSession,'','','',comments);
                        end
                    end
                end
            end
            
            %option to shut off the training after x hrs
            trainingButton=get(trainonh,'value');
            if trainingButton==1 % gui button is pushed
                if toc(beginSession) >= autoOff*60*60
                    fprintf('Session Finished Auto Off %s\n', datestr(now,21));
                    if debugButton == 0
                        fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                            sessionType, sessionID, batName, EventSleep,trialNum,callNum,rewardNum,callOnly,comments);
                    end
                end
                while toc(beginSession) >= autoOff*60*60 && strcmp(get(starth,'string'),'STOP')
                    playbackTrg = 0;
                    recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %rec only post training time
                    writeDigitalPin(a,ledPin1,1); %turn on white light to indicate session over
                end
            end
            
            %playback button option remains open
            playbackButton = get(playbackbuttonh,'value');
            playbackTimer = tic;
            if playbackButton == 0
                playbackTrg = 0;
            elseif playbackButton ==1
                playbackTrg =1;
                if playback_i == 0
                    fprintf('PlayBack Mode Has Been On >>>>> %s\n', datestr(now, 21));
                    if debugButton == 0
                        fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                            sessionType, sessionID, batName, EventComment,trialNum,callNum,rewardNum,callOnly,'playback on');
                    end
                    playback_i = 0;
                end
            end
            %option to set sleep time on/off
            sleepButton = get(sleeponh,'value');
            if sleepButton==1 % gui button is pushed
                sleepn=0;
                while str2num(datestr(now,'HH'))>=trainEnd ||...
                        str2num(datestr(now,'HH'))<= trainStart && strcmp(get(starth,'string'),'STOP')
                    drawnow;
                    if sleepn==0
                        fprintf('Bats go to sleep!\n', datestr(now,21));
                        if strcmp(get(starth,'string'),'STOP') && debugButton == 0
                            fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                                sessionType, sessionID, batName, EventSleep,trialNum,callNum,rewardNum,callOnly,comments);
                        end
                        sleepn=sleepn+1;
                    end
                    % go into only rec mode during above hours
                    timeOut=tic;
                    playbackTrg = 0;
                    recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %rec only during sleep time
                end
            end
            
            %main rec loop
            while max(clipin(channel)) < feedbbuf && recOnlyButton == 0 ...
                  && beamBreakTrg==beamOpen && strcmp(get(starth,'string'),'STOP')     %&& toc(ledLoopTime)<seq(seqOrder(trialNum)) %waiting loop
                drawnow;
                %turn off cue LED
                if toc(beamTime1) > ledCue
                    writeDigitalPin(a,ledPin2,0);
                end
                %keep checking buttons
                recOnlyButton=get(recbuttonh,'value');
                playbackButton = get(playbackbuttonh,'value');
                %continue pulling in sound
                [succ, clipout,clipin]=soundmexpro('clipcount');
                soundmexpro('resetclipcount'); %continue reseting count to detect call
                %if toc(ledLoopTime)<seq(seqOrder(trialNum)) %only do pause for checking recording if cue time is up
                pause(durThresh);
                %end
                %high pass filter for audio before triggering cue/reward
                if max(clipin(channel))>=feedbbuf
                    callTrigger = datestr(now, 'yyyymmddTHHMMSSFFF');
                    [succ,rectrg,pos]=soundmexpro('recgetdata','channel',recchan);
                    filt_trg=filtfilt(B,A,rectrg(end-durThresh*fs:end,1));
                    %disp('trigger')
                    H=rms(filt_trg);
                    if H<rmsThresh %may need to increase if still get cage noise
                        clipin=clipin.*0;
                        %fprintf('low rms %i >>>>> %s\n', H, datestr(now,21));
                        %else
                        %soundmexpro('loadmem','data',video_trigger,'track',triggerchan,'loopcount',1);
                    %passes threshold, det. if front or back bat called
                    elseif length(recchan)>1
                        direc=max(abs(rectrg));
                        if direc(2)-direc(3)>=0
                            disp('Front bat calls')
                            if debugButton == 0
                                fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                                    sessionType, sessionID, batName, EventComment,trialNum,callNum,rewardNum,callOnly,'fcall');
                            end
                        else
                            disp('Back bat calls')
                            if debugButton == 0
                                fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                                    sessionType, sessionID, batName, EventComment,trialNum,callNum,rewardNum,callOnly,'bcall');
                            end
                        end
                    end
                    %fprintf('rms %i >>>> %s\n', H, datestr(now,21)); 
                end
                %check BB and filter if bat waits min wait time before triggering cue/reward
                beamVal1 = readDigitalPin(a, beamPin1); %keep checking trial BB
                if playbackTrg ~= 2 && beamVal1 == beamBreak
                    beamBreakCount=beamBreakCount + 1; %change to BB mode
                    if beamBreakCount==1
                        beamBreakWait=tic; %start timer
                    else
                        beamBreakLapse=toc(beamBreakWait);
                        if beamBreakLapse>=minWait %wait min time
                            beamBreakTrg=beamBreak;
                            beamBreakCount=0;
                        end
                    end
                else
                    beamBreakCount=0;
                end
                if playbackTrg == 1 && offTrg == 0
                    while responseTrg == 0
                        recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %rec only post training time
                        if strcmp(get(starth,'string'),'START')
                            drawnow;
                            break
                        end
                    end
                    timeOutTrg = 0;
                    %if trial beam broken
                    if debugButton == 0
                        trialNum=trialNum+1; %end of trial
                        fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                            sessionType, sessionID, batName, EventTrialStart,trialNum,callNum,rewardNum,callOnly,comments);
                    end
                    fprintf('Broke Beam, Trial #%i Initiated >>>>> %s\n', trialNum, datestr(now,21));
                    %manually playback a call from the selector
                    playbackF=get(playbackfileh,'string'); %select all strings in dropdown menu
                    playbackF2=playbackF{get(playbackfileh,'value')}; %select the string you chose
                    load(playbackF2); %load that file for playback
                    playbackFile = recbuf; %may need to change recbuf if it is a different variable
                    %             %randomly playback a call from the selector
                    %             fileNum = fileseq(file_i);
                    %             playbackFn = directory(fileNum).name;
                    %             load([filepn playbackFn]);
                    %             playbackFile = recbuf;
                    %             file_i = file_i + 1;
                    %             if file_i >= length(directory)
                    %                 file_i = 1;
                    %             end
                    % play call
                    soundmexpro('loadmem', ... %play call
                        'data', playbackFile, ...   % data vector
                        'track',track, ... %the virtual track
                        'loopcount',1);
                    writeDigitalPin(a,ledPin2,0); %turn off green cue LED
                    writeDigitalPin(a,ledPin3,1); %turn on blue cue LED
                    responseTimer = tic; %start timer for response from playback
                    if debugButton == 0
                        playback_i = playback_i + 1;
                        fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                            sessionType, sessionID, batName, EventPlayback,trialNum,callNum,rewardNum,callOnly,playbackF2);
                    else
                        fprintf('Playback Call #%i %s >>>>> %s\n', playback_i, playbackF2, datestr(now, 21));
                    end
                    soundmexpro('wait');
                    soundmexpro('cleardata');
                    %pause(0.3); %allow the sound to be played and light on before activating reward
                    %beamTime1 = tic;
                    playbackTimer = tic; %restart the playback
                    beamBreakCount=0;
                    timeOutTrg = 0;
                    playbackTrg = 2;
                    responseTrg = 1;
                elseif playbackTrg == 2 && responseTrg == 1 && toc(responseTimer) >= responseTime && offTrg ==0
                    beamBreakTrg = beamBreak;
                    playbackTrg = 3;
                end
            end
            %check for trial bb or call to start trial
            beamTime1 = tic; %keep timer for cue LED & trial
            beamVal2 = beamOpen; %open front reward beam
            beamVal3 = beamOpen; %open back reward beam
            if timeOutTrg == 0
                %trial beam is broken, trial initiated with no playback
                if beamVal1 == beamBreak && playbackTrg == 0
                    %if call detected or trial beam broken
                    if debugButton == 0
                        trialNum=trialNum+1;
                        fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                            sessionType, sessionID, batName, EventTrialStart,trialNum,callNum,rewardNum,callOnly,comments);
                    end
                    fprintf('Broke Beam, Trial #%i Initiated >>>>> %s\n', trialNum, datestr(now,21));
                    %manually playback a call from the selector
                    playbackF=get(playbackfileh,'string'); %select all strings in dropdown menu
                    playbackF2=playbackF{get(playbackfileh,'value')}; %select the string you chose
                    load(playbackF2); %load that file for playback
                    playbackFile = recbuf; %may need to change recbuf if it is a different variable
                    % play call
                    soundmexpro('loadmem', ... %play call
                        'data', playbackFile, ...   % data vector
                        'track',track, ... %the virtual track
                        'loopcount',1);
                    %writeDigitalPin(a,ledPin2,0); %turn off trial cue LED
                    %writeDigitalPin(a,ledPin3,1); %turn on reward LED
                    if debugButton == 0
                        playback_i = playback_i + 1;
                        fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                            sessionType, sessionID, batName, EventPlayback,trialNum,callNum,rewardNum,callOnly,playbackF2);
                    end
                    fprintf('Playback Call #%i %s >>>>> %s\n', playback_i, playbackF2, datestr(now, 21));
                    soundmexpro('wait');
                    soundmexpro('cleardata');
                    writeDigitalPin(a,ledPin2,1); %turn on green LED
                    writeDigitalPin(a,ledPin3,0); %turn off blue LED
                    responseTrg = 0;
                    %call is detected, trial initiated with or without
                    %playback
                    %bat calls without playback mode
                elseif max(clipin(channel))>=feedbbuf && playbackTrg == 0
                    trg=1; %state of recording 1=call occurred
                    timelapse=tic; %timer for recording b4 reward
                    if debugButton == 0
                        callNum = callNum +1;
                        trialNum = trialNum +1;
                        fprintf(logFileId, formatSpec, callTrigger,...
                            sessionType, sessionID, batName, EventCall,trialNum,callNum,rewardNum,callOnly,comments);
                    end
                    fprintf('1-Call occurred #%i >>>>> %s\n', callNum, datestr(now,21));
                    %manually playback a call from the selector
                    playbackF=get(playbackfileh,'string'); %select all strings in dropdown menu
                    playbackF2=playbackF{get(playbackfileh,'value')}; %select the string you chose
                    load(playbackF2); %load that file for playback
                    playbackFile = recbuf; %may need to change recbuf if it is a different variable
                    % play call
%                     soundmexpro('loadmem', ... %play call
%                         'data', playbackFile, ...   % data vector
%                         'track',track, ... %the virtual track
%                         'loopcount',1);
%                     if debugButton == 0
%                         playback_i = playback_i + 1;                   
%                         fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
%                             sessionType, sessionID, batName, EventPlayback,trialNum,callNum,rewardNum,callOnly,playbackF2);
%                     end
%                     fprintf('Playback Call #%i %s >>>>> %s\n', playback_i, playbackF2, datestr(now, 21));                  
%                     soundmexpro('wait');
%                     soundmexpro('cleardata');
                    responseTrg = 0;
                    writeDigitalPin(a,ledPin2,1); %turn on green LED
                    writeDigitalPin(a,ledPin3,0); %turn off blue LED
                    %bat calls back after playback
                elseif max(clipin(channel))>=feedbbuf && responseTrg == 1 && toc(responseTimer) <= responseTime
                    trg=1; %state of recording 1=call occurred
                    timelapse=tic; %timer for recording b4 reward
                    if debugButton == 0
                        %trialNum=trialNum+1;
                        callNum = callNum +1;
                        fprintf(logFileId, formatSpec, callTrigger,...
                            sessionType, sessionID, batName, EventCall,trialNum,callNum,rewardNum,callOnly,comments);
                    end
                    fprintf('1-Call in Response #%i >>>>> %s\n', callNum, datestr(now,21));
                    writeDigitalPin(a,ledPin2,1); %turn on green LED
                    writeDigitalPin(a,ledPin3,0); %turn off blue LED
                    responseTrg = 0;
                    %beamTime1 = tic;
                end
                
                %check for bat to go to reward port
                beamVal2 = readDigitalPin(a,beamPin2);
                beamVal3 = readDigitalPin(a,beamPin3);
                waitcount=0; %status for recording during waiting b4 reward
                n=2; %avoid overlap of aud recordings
                
                %restart trial if bat too slow to get reward
                while beamVal2 == beamOpen && beamVal3 == beamOpen && responseTrg == 0 ...
                        && toc(beamTime1) < maxDelay && strcmp(get(starth,'string'),'STOP') %beam not broken and not longer than delay
                    drawnow;
                    %get audio data for trigger call
                    if trg==1
                        if toc(timelapse)>=recShift && waitcount==0
                            [succ,recstart,pos]=soundmexpro('recgetdata','channel',recchan);
                            pause(durThresh);
                            waitcount=1;
                            if debugButton == 1
                                figure;plot(recstart)
                            end
                        end
                    end
                    %get audio data consecutively without overlapping
                    if toc(timelapse)>=recDur*n
                        if waitcount==0
                            recstart=[]; %start fresh variable for new rec
                        end
                        [succ,recbuf,pos]=soundmexpro('recgetdata','channel',recchan);
                        pause(durThresh);
                        n=n+1;
                        %get audio data if more calls during waiting period
                        if max(abs(recbuf))>recCont
                            callTrigger = datestr(now, 'yyyymmddTHHMMSSFFF');
                            callContTrigger = datestr(now, 'yyyymmddTHHMMSSFFF');
                            if waitcount==0
                                if debugButton == 0
                                    callNum=callNum+1;
                                    fprintf(logFileId, formatSpec, callContTrigger,...
                                        sessionType, sessionID, batName, EventCall2,trialNum,callNum,rewardNum,callOnly,comments);
                                end
                                fprintf('2-Call continuing >>>>> %s\n', datestr(now,21));
                                waitcount=1;
                            end
                            %determine if front or back bat balls
                            direc=max(abs(recbuf));
                            if direc(2)-direc(3)>=0
                                disp('Front bat calls')
                                if debugButton == 0
                                    fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                                        sessionType, sessionID, batName, EventComment,trialNum,callNum,rewardNum,callOnly,'front');
                                end
                            else
                                disp('Back bat calls')
                                if debugButton == 0
                                    fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                                        sessionType, sessionID, batName, EventComment,trialNum,callNum,rewardNum,callOnly,'back');
                                end
                            end
                            %beam is broken, then call is detected
                            trg=2;
                            recstart=[recstart;recbuf(end-durThresh*fs:end,:)];
                            if debugButton == 1
                                figure;plot(recstart)
                            end

                        end
                    end
                    beamVal2 = readDigitalPin(a,beamPin2); %check front reward beam
                    beamVal3 = readDigitalPin(a,beamPin3); %check back reward beam
                end
                
                %call triggers a trial
                if trg==1
                    if toc(timelapse)>=recDur*recShift && waitcount==0
                        [succ,recstart,pos]=soundmexpro('recgetdata','channel',recchan);
                        waitcount=1;
                    end
                    
                end
                
                %bat makes it to reward port
                if beamVal2 == beamBreak && playbackTrg ~= 3 && offTrg == 0  %front reward beam broken
                    writeDigitalPin(a,ledPin3,0); %turn off reward LED
                    writeDigitalPin(a,ledPin2,0); %turn off trial beam break
                    beamTime2 = tic; %start reward timer
                    if debugButton == 0
                        rewardNum = rewardNum + 1;
                        fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                            sessionType, sessionID, batName, EventReward,trialNum,callNum,rewardNum,callOnly,'Front');
                    end
                    fprintf('Reward Front #%i >>>>> %s\n', rewardNum, datestr(now,21));
                    
                    %deliver reward with servo
                    dcm.Speed = motorS; %1=full
                    start(dcm);
                    if playbackButton == 0
                        pause(motorT); %0.32 = 1/100 reward
                    else
                        pause(motorT*2);
                    end
                    stop(dcm);
                    writeDigitalPin(a,ledPin3,0); %turn off reward LED
                    timeOutCount = 0; %reset timeout counter to 0
                    lastReward=tic; %timer for timeOutReset
                    beamBreakTrg=beamOpen;
                    %save the call after reward given
                    if trg~=0
                        if debugButton == 1
                            fprintf('Getting recording\n');
                        end
                        if waitcount==0  %audio record again?????
                            if toc(timelapse) < instaReward %bat gets reward quickly so dont cut off call
                                pause(instaReward-toc(timelapse));
                            end
                            [succ,recstart,pos]=soundmexpro('recgetdata','channel',recchan);
                        end
                        recbuf=recstart; %reset recording buffer variable
                        
                        [succ,xrun,xruncpu,xrundata]=soundmexpro('xrun'); %count any dropped samples
                        if debugButton == 0
                            save([recPath callTrigger(1:end-3) '_' batName '_' num2str(callNum) '.mat'],'recbuf','fs','xrun','sessionType','sessionID','batName','micType','callNum','callTrigger',...
                                'motorS', 'motorT', 'ledCue','maxDelay','minWait','minInt','maxInt','ledTimeOut','maxTimeOut','dunceCap',...
                                'channel','motuGain','recDur','ampThresh','durThresh','rmsThresh','comments','EventStartSession'); %save
                        end
                        soundmexpro('resetclipcount'); %reset recording trigger
                        pause(durThresh);
                        if debugButton == 1
                            fprintf('Calls saved\n');
                        end
                        trg=0; %reset recording state
                    end
                    while toc(lastReward)<minBetween %delay before allowing next trial
                        playbackTrg = 0;
                        %aud record only during interval period
                        recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
                    end
                    beamVal2 = beamOpen;
                    % use this when the bats are split into 2 compartments
                elseif beamVal3 == beamBreak && playbackTrg ~= 3 && offTrg == 0%back reward beam broken
                    writeDigitalPin(a,ledPin3,0); %turn off blue LED
                    writeDigitalPin(a,ledPin2,0); %turn off green LED
                    beamTime2 = tic; %start reward timer
                    if debugButton == 0
                        rewardNum = rewardNum + 1;
                        fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                            sessionType, sessionID, batName, EventReward,trialNum,callNum,rewardNum,callOnly,'Back');
                    end
                    fprintf('Reward Back #%i >>>>> %s\n', rewardNum, datestr(now,21));
                    %deliver reward with servo
                    dcm.Speed = motorS; %1=full
                    start(dcm);
                    if playbackButton == 0
                        pause(motorT); %0.32 = 1/100 reward
                    else
                        pause(motorT*2);
                    end
                    stop(dcm);
                    writeDigitalPin(a,ledPin3,0); %turn off reward LED
                    timeOutCount = 0; %reset timeout counter to 0
                    lastReward=tic; %timer for timeOutReset
                    beamBreakTrg=beamOpen;
                    %save the call after reward given
                    if trg~=0
                        if debugButton == 1
                            fprintf('Getting recording\n');
                        end
                        if waitcount==0 %audio record again?????
                            [succ,recstart,pos]=soundmexpro('recgetdata','channel',recchan);
                        end
                        recbuf=recstart; %reset recording buffer variable
                        
                        [succ,xrun,xruncpu,xrundata]=soundmexpro('xrun'); %count any dropped samples
                        if debugButton == 0
                            save([recPath callTrigger(1:end-3) '_' batName '_' num2str(callNum) '.mat'],'recbuf','fs','xrun','sessionType','sessionID','batName','micType','callNum','callTrigger',...
                                'motorS', 'motorT', 'ledCue','maxDelay','minWait','minInt','maxInt','ledTimeOut','maxTimeOut','dunceCap',...
                                'channel','motuGain','recDur','ampThresh','durThresh','rmsThresh','comments','EventStartSession'); %save
                        end
                        soundmexpro('resetclipcount'); %reset recording trigger
                        if debugButton == 1
                            fprintf('Calls saved\n');
                        end
                        trg=0; %reset recording state
                    end
                    while toc(lastReward)<minBetween %delay before allowing next trial
                        playbackTrg = 0;
                        %aud record only during interval period
                        recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
                    end
                    beamVal3 = beamOpen;
                elseif toc(responseTimer) > responseTime && responseTrg == 1 && offTrg == 0
                    beamBreakTrg = beamOpen;
                    ledTime1 = tic; %timer for LED timeout
                    lastReward=tic; %timer for timeOutReset
                    if debugButton == 0
                        timeOutCount=timeOutCount+1; %start adding how many fail/ignores took place
                        fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                            sessionType, sessionID, batName, EventNoGo,trialNum,callNum,rewardNum,callOnly,comments);
                    end
                    fprintf('Time Out -No call back >>>>> %s\n', datestr(now,21));
                    writeDigitalPin(a,ledPin1,1); %light timeout LED
                    writeDigitalPin(a,ledPin2,0); %turn off green led
                    writeDigitalPin(a,ledPin3,0); %turn off blue led
                    responseTrg = 0;
                    beamTime1 = tic;
                    %bat didn't go to port, illuminate timeout led
                elseif toc(beamTime1) >= maxDelay && timeOutTrg ==0 && strcmp(get(starth,'string'),'STOP')
                    beamBreakTrg = beamOpen;
                    ledTime1 = tic; %timer for LED timeout
                    lastReward=tic; %timer for timeOutReset
                    if debugButton == 0
                    timeOutCount=timeOutCount+1; %start adding how many fail/ignores took place                      
                        fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                            sessionType, sessionID, batName, EventNoGo,trialNum,callNum,rewardNum,callOnly,comments);
                    end
                    fprintf('Time Out -No reward >>>>> %s\n', datestr(now,21));
                    writeDigitalPin(a,ledPin1,1); %light timeout LED
                    writeDigitalPin(a,ledPin2,0); %turn off green led
                    writeDigitalPin(a,ledPin3,0); %turn off blue led
                    responseTrg = 0;
                    %save the call after timeout
                    if trg~=0
                        if debugButton == 1
                            fprintf('Getting recording\n');
                        end
                        if waitcount==0 %get audio recording
                            [succ,recstart,pos]=soundmexpro('recgetdata','channel',recchan);
                        end
                        recbuf=recstart; %reset recording buffer variable
                        [succ,xrun,xruncpu,xrundata]=soundmexpro('xrun'); %count any dropped samples
                        if debugButton == 0
                            save([recPath callTrigger(1:end-3) '_' batName '_' num2str(callNum) '.mat'],'recbuf','fs','xrun','sessionType','sessionID','batName','micType','callNum','callTrigger',...
                                'motorS', 'motorT', 'ledCue','maxDelay','minWait','minInt','maxInt','ledTimeOut','maxTimeOut','dunceCap',...
                                'channel','motuGain','recDur','ampThresh','durThresh','rmsThresh','comments','EventStartSession'); %save
                        end
                        soundmexpro('resetclipcount'); %reset recording trigger
                        if debugButton == 1
                            fprintf('Calls saved\n')
                        end
                        trg=0; %reset recording state
                    end
                    while toc(ledTime1)<ledTimeOut %during toLED on
                        playbackTrg = 0;
                        %aud record during delay
                        recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
                        
                    end
                    %end the timeoutLED
                    writeDigitalPin(a,ledPin1,0); %turn off timeout led
                end
                
                %save the call after reward given
                if trg~=0
                    if debugButton == 1
                        fprintf('Getting recording\n');
                    end
                    if waitcount==0 %audio record again?????
                        [succ,recstart,pos]=soundmexpro('recgetdata','channel',recchan);
                    end
                    recbuf=recstart; %reset recording buffer variable
                    
                    [succ,xrun,xruncpu,xrundata]=soundmexpro('xrun'); %count any dropped samples
                    if debugButton == 0
                        save([recPath callTrigger(1:end-3) '_' batName '_' num2str(callNum) '.mat'],'recbuf','fs','xrun','sessionType','sessionID','batName','micType','callNum','callTrigger',...
                            'motorS', 'motorT', 'ledCue','maxDelay','minWait','minInt','maxInt','ledTimeOut','maxTimeOut','dunceCap',...
                            'channel','motuGain','recDur','ampThresh','durThresh','rmsThresh','comments','EventStartSession'); %save
                    end
                    soundmexpro('resetclipcount'); %reset recording trigger
                    if debugButton == 1
                        fprintf('Calls saved\n');
                    end
                    trg=0; %reset recording state
                end
            end
            
            
            %bat ignored cue signal for 3+ times & now goes to 10 min time out
            if toc(lastReward)>= ignoreTime %5min
                timeOutCount=0; %reset timeout counter if not paying attention for 5 min
                fprintf('reset timeout count %s\n', datestr(now,21));
            end
            if timeOutCount>=maxTimeOut %ex: 3
                timeOut=tic; %timer for long time out
                dunceCapMin = dunceCap/60; %ex: 10 min
                fprintf('No response lock out - %i min >>>>> %s\n', dunceCapMin, datestr(now,21));
                if debugButton == 0
                    fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                        sessionType, sessionID, batName, EventDunceCap,trialNum,callNum,rewardNum,callOnly,comments);
                end
                
                
                %go to rec only for 10 min
                while toc(timeOut)<dunceCap && strcmp(get(starth,'string'),'STOP')
                    drawnow;
                    playbackTrg = 0;
                    recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
                end
                timeOutCount=0; %reset timeout count to 0 after reaching 3
            end
            %move on to next trial
            if stopped~=1 %if not in middle of rec
                if debugButton == 1
                    fprintf('***Back to waiting >>>>> %s\n',datestr(now,21));
                end
                %trialNum=trialNum+1; %end of trial
                
                % reset servo
                if rewardNum >= maxReward %83 for full 60ml syringe with 0.32 reward time
                    %70 for full 150ml syringe @0.32 time
                    %110 for full 150ml syringe @0.16 time
                    % 158 for full 150ml syringe @0.08 time
                    % 190 for full 150ml syringe @0.05 time
                    fprintf('Reset Session >>>>> %s\n', datestr(now, 21));
                    if debugButton == 0
                        fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                            sessionType, sessionID, batName, EventResetSession,trialNum,callNum,rewardNum,callOnly,comments);
                    end
                    dcm.Speed = -1;
                    start(dcm);
                    pause(29); %amount of time to push servo back to restart position
                    stop(dcm);
                    sessionID = sessionID + 1; %start labeling as new session
                    dcm.Speed=motorS; %reset motor back to forward
                    try
                        sendmail({'tschmid7489@gmail.com'},['Box ' num2str(boxNum) ' be Hungry'],'ya scallywag :)')
                    catch exception
                        continue
                    end
                    while strcmp(get(starth,'string'),'STOP')
                        resetTrg = 1;
                        writeDigitalPin(a,ledPin1,1); %light timeout LED
                        playbackTrg = 0;
                        recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
                    end
                    rewardNum = 0;
                    resetTrg = 0;
                end
            end
            ledLoopTime=tic; %reset led loop timer for pause
        end
        
        
%% stop the recording session
    case 'STOP'
        drawnow;
        Dstop=datetime;
        DayNumberStop=weekday(Dstop);
        set([thrah thrdh recdh thrah thrdh thrrh thrfh recdh dateh sessionth sessionidh batnameh ...
            motorSh motorTh cueledh timeoutledh recchanh debugbuttonh...
            starth motugh maxdelayh mininth maxinth maxtimeouth...
            duncecaph minwaith responseth minbwh],'enable','on');
        writeDigitalPin(a,ledPin1,0);
        writeDigitalPin(a,ledPin2,0);
        writeDigitalPin(a,ledPin3,0);
        playbackTrg = 0;
        responseTrg = 0;
        beamBreakTrg = 0;
        responseTime = 0;
        set(starth,'string','START','backgroundcolor',...
            [193/255 221/225 198/255]);
        drawnow;
        fprintf(['End on: ' datestr(now,21) '>>>>> ' 'Session time: ' num2str(toc(beginSession)/60) ' (min)\n']);
        if debugButton == 0
            fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                sessionType, sessionID, batName, EventSessionDone,trialNum,callNum,rewardNum,callOnly,comments);
        end
        soundmexpro('stop');
        [succ,xrun,xruncpu,xrundata]=soundmexpro('xrun');
        disp(['Session run with ' num2str(xrun) ' XRUNS']);
        offTrg = 1;
        %fclose('all'); %close out of log files
        %quit the program
    
%% Case Quit
    case 'Quit'
        soundmexpro('exit');
        close(fh)
        clear all;
        responseTrg = 5;
        %save comments whenever push button
    case 'Comments'
        commenth=findobj(fh,'tag','comments');
        commentstr=get(commenth,'string');
        fprintf(['Comment: ' commentstr ' >>>>> ' datestr(now,21) '\n']);
        if debugButton ==0
            fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                sessionType, sessionID, batName, EventComment,trialNum,callNum,rewardNum,callOnly,commentstr);
        end
    case 'Reward'
        %deliver reward with servo
        writeDigitalPin(a,ledPin2,1); %green led
        dcm.Speed = motorS; %1=full
        start(dcm);
        pause(motorT); %0.32 = 1/100 reward
        stop(dcm);
        writeDigitalPin(a,ledPin2,0); %green led
        timeOutCount = 0; %reset timeout counter to 0
        lastReward=tic; %timer for timeOutReset
        if strcmp(get(starth,'string'),'STOP') && debugButton == 0
            rewardNum = rewardNum + 1;
            fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                sessionType, sessionID, batName, EventReward2,trialNum,callNum,rewardNum,callOnly,comments);
        end
        fprintf('Reward #%i Given >>>>> %s\n', rewardNum, datestr(now,21));
    case 'Cue'
        %manually initiate cue LED
        writeDigitalPin(a,ledPin2,1);
        fprintf('Manual Cue >>>>> %s\n', datestr(now,21));
        if strcmp(get(starth,'string'),'STOP') && debugButton == 0
            fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                sessionType, sessionID, batName, EventCue,trialNum,callNum,rewardNum,callOnly,'Manual Cue');
        end
        %turn off cue LED
        pause(1);
        writeDigitalPin(a,ledPin2,0);
    case 'Reset'
        %reset servo manually
        fprintf('Reset Session >>>>> %s\n', datestr(now,21));
        if strcmp(get(starth,'string'),'STOP') && debugButton == 0
            fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                sessionType, sessionID, batName, EventResetSession,trialNum,callNum,rewardNum,callOnly,comments);
        end
        trialNum = 0; %sets trial counter (+1 for cue light on or call)
        rewardNum=0; %sets reward counter (+1 for reward)
        callNum=0; %sets call counter when start whole autoTrain (+1 for call)
        callOnly=0; %sets call counter for recOnly calls
        dcm.Speed = -1;
        start(dcm);
        pause(29); %amount of time to push servo back to restart position
        stop(dcm);
        rewardNum = 0;
        dcm.Speed=motorS; %reset motor back to forward
    case '+'
        %move servo forward +1
        dcm.Speed = 1; %1=full forward
        start(dcm);
        pause(1); % 1sec
        stop(dcm);
    case '-'
        %move servo backwards -1
        dcm.Speed = -1; %1=full forward
        start(dcm);
        pause(1); % 1sec
        stop(dcm);
    case 'Play'
        set(playh,'enable','off'); %turn off
        drawnow;
        %manually playback a call from the selector
        playbackF=get(playbackfileh,'string'); %select all strings in dropdown menu
        playbackF2=playbackF{get(playbackfileh,'value')}; %select the string you chose
        load(playbackF2); %load that file for playback
        playbackFile = recbuf; %may need to change recbuf if it is a different variable
        soundmexpro('loadmem', ... %play call
            'data', playbackFile, ...   % data vector
            'track',track, ... %the virtual track
            'loopcount',1);
        writeDigitalPin(a,ledPin2,1); %turn on trial cue LED
        if debugButton == 0
            trialNum=trialNum+1;
            playback_i=playback_i + 1;
            fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                sessionType, sessionID, batName, EventPlayback,trialNum,callNum,rewardNum,callOnly,playbackF2);
        end
        fprintf('Playback Call #%i %s >>>>> %s\n', playback_i, playbackF2, datestr(now, 21));
        pause(0.3); %allow the sound to be played and light on before activating reward
        responseTimer2 = tic;
        beamTime1 = tic; %start timer to turn off cue LED
        beamOpen = 1;
        beamBreak = 0;
        beamVal2 = beamOpen;
        beamVal3 = beamOpen;
        responseT=get(responseth,'string'); %get value for timer for how long bat has to respond
        responseTime=str2num(responseT);
        while toc(responseTimer2) < responseTime && beamVal2 == beamOpen && beamVal3 == beamOpen
            %check for bat to go to reward port
            beamVal2 = readDigitalPin(a,beamPin2);
            beamVal3 = readDigitalPin(a,beamPin3);
            playbackTrg = 0;
            recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
            if toc(beamTime1) > ledCue %turn off cue LED
                writeDigitalPin(a,ledPin2,0);
            end
        end
        %bat makes it to reward port
        if beamVal2 == beamBreak %front reward beam broken
            writeDigitalPin(a,ledPin3,1); %turn on reward LED
            writeDigitalPin(a,ledPin2,0); %turn off trial beam break
            if debugButton == 0
                rewardNum = rewardNum + 1;
                fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                    sessionType, sessionID, batName, EventReward,trialNum,callNum,rewardNum,callOnly,'Front');
            end
            fprintf('Reward Front #%i >>>>> %s\n', rewardNum, datestr(now,21));
            
            %deliver reward with servo
            dcm.Speed = motorS; %1=full
            start(dcm);
            pause(motorT); %0.32 = 1/100 reward
            stop(dcm);
            writeDigitalPin(a,ledPin3,0); %turn off reward LED
            timeOutCount = 0; %reset timeout counter to 0
            lastReward=tic; %timer for timeOutReset
            beamVal2 = beamOpen;
        elseif beamVal3 == beamBreak %back reward beam broken
            writeDigitalPin(a,ledPin3,1); %turn on reward LED
            writeDigitalPin(a,ledPin2,0); %turn off trial beam break
            if debugButton == 0
                rewardNum = rewardNum + 1;
                fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                    sessionType, sessionID, batName, EventReward,trialNum,callNum,rewardNum,callOnly,'Back');
            end
            fprintf('Reward Back #%i >>>>> %s\n', rewardNum, datestr(now,21));
            %deliver reward with servo
            dcm.Speed = motorS; %1=full
            start(dcm);
            pause(motorT); %0.32 = 1/100 reward
            stop(dcm);
            writeDigitalPin(a,ledPin3,0); %turn off reward LED
            timeOutCount = 0; %reset timeout counter to 0
            lastReward=tic; %timer for timeOutReset
            beamVal3 = beamOpen;
            %bat didn't go to port, illuminate timeout led
        elseif toc(responseTimer2) > responseTime
            beamBreakTrg = beamOpen;
            ledTime1 = tic; %timer for LED timeout
            lastReward=tic; %timer for timeOutReset
            if debugButton == 0
            timeOutCount=timeOutCount+1; %start adding how many fail/ignores took place              
                fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                    sessionType, sessionID, batName, EventNoGo,trialNum,callNum,rewardNum,callOnly,comments);
            end
            fprintf('Time Out 3 >>>>> %s\n', datestr(now,21));
            writeDigitalPin(a,ledPin1,1); %light timeout LED
            while toc(ledTime1)<ledTimeOut %during toLED on
                playbackTrg = 0;
                %aud record during delay
                recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
            end
            %end the timeoutLED
            writeDigitalPin(a,ledPin1,0); %turn off timeout led
            responseTimer2 = tic;
        end
        set(playh,'enable','on'); %turn on button again
end
end





function playback_func
global fs pre_trg feedbbuf recPath xrun recstart;
global a ledPin1 ledPin2 ledPin3 beamPin1 beamPin2 beamPin3;
global debugButton logFileId formatSpec trialNum callNum rewardNum callOnly;
global sessionType sessionID comments batName;
global dcm motorS motorT ledCue ledTimeOut maxDelay responseTime;
global recDur durThresh B A starth rmsThresh minWait recbuttonh;
global EventTrialStart EventReward EventRecsOnly beamOpen beamBreak;
global EventNoGo EventCall EventCall2 minBetween track timeOutCount beamBreakTrg timeOutTrg;
global ledTime1 beamVal1 beamVal2 beamVal3 stopped recShift recCont playbackFilen;
global lastReward instaReward channel playback_i playbackbuttonh EventPlayback;
global filepn directory file_i fileseq playbackButton recOnlyButton timelapse;
global n beamTime1 playbackfileh beamBreakCount beamBreakWait micType maxReward EventResetSession;
global EventStartSession minInt maxInt maxTimeOut beginSession trainonh playbackTrg;
global dunceCap motuGain ampThresh playbackCountdown autoOff ignoreTime EventDunceCap;


while playbackButton == 1 && recOnlyButton == 0 && strcmp(get(starth,'string'),'STOP')
    drawnow;
    %starting parameters
    trg=0; %not recording state
    playbackTrg = 0; %start in playback off mode
    timeOutTrg = 0; %not time out state
    beamOpen = 1;
    beamBreak = 0;
    beamBreakTrg=beamOpen;
    beamVal1 = readDigitalPin(a, beamPin1); %check init beam break
    beamVal3= beamOpen; %not reward beam state
    beamVal2 = beamOpen; %not reward beam state
    ledLoopTime=tic; %timer for cue LED loop
    playbackTimer=tic;%timer for playback countdown
    responseTimer = tic; %timer for calling after beam break initiate
    timelapse = tic; %timer for consecutive call adding
    soundmexpro('resetclipcount'); %resets clip to 0 so don't accumulate clips when go back into waiting loop
    % get audio input information at all times
    [succ, clipout,clipin]=soundmexpro('clipcount');
    %rec only button option remains open
    recOnlyButton=get(recbuttonh,'value');
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
            recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %rec only post training time
            writeDigitalPin(a,ledPin1,0); %turn off white light to indicate session over
        end
    end
    
    %keep checking buttons
    playbackButton = get(playbackbuttonh,'value');
    while max(clipin(channel))<feedbbuf && timeOutTrg == 0 && strcmp(get(starth,'string'),'STOP')
        beamVal1 = readDigitalPin(a, beamPin1); %check init beam break
        if beamBreakTrg==beamOpen && playbackTrg == 0
            recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %rec only post training
            %check BB if bat waits min wait time before triggering cue/reward
            if beamVal1 == beamBreak
                beamBreakCount=beamBreakCount + 1; %change to BB mode
                if beamBreakCount==1
                    beamBreakWait=tic; %start timer
                    %                 elseif beamBreakCount>1
                    %                     fprintf('Broke Beam, No Trial #%i >>>>> %s\n', trialNum, datestr(now,21));
                    %                     beamBreakCount=0;
                    %                     beamVal1 = beamOpen;
                end
                beamBreakLapse=toc(beamBreakWait);
                if beamBreakLapse>=minWait %wait min time
                    beamBreakTrg=beamBreak;
                    beamBreakCount=0;
                end
            else
                beamBreakCount=0;
            end
        end
        
        %check for call to start trial
        beamVal2 = beamOpen; %open front reward beam
        beamVal3 = beamOpen; %open back reward beam
        %trial beam is broken, trial initiated
        if  playbackTrg == 0
            if toc(playbackTimer) >= minInt && beamVal1 == beamBreak || toc(playbackTimer) >= maxInt %playbackCountdown(playback_i)
                timeOutTrg = 0;
                %if trial beam broken
                trialNum=trialNum+1; %end of trial
                fprintf('Broke Beam, Trial #%i Initiated >>>>> %s\n', trialNum, datestr(now,21));
                if debugButton == 0
                    fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                        sessionType, sessionID, batName, EventTrialStart,trialNum,callNum,rewardNum,callOnly,comments);
                end
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
                writeDigitalPin(a,ledPin2,0); %turn off trial cue LED
                writeDigitalPin(a,ledPin3,1); %turn on reward LED
                fprintf('Playback Call #%i %s >>>>> %s\n', playback_i, playbackF2, datestr(now, 21));
                if debugButton == 0
                    fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                        sessionType, sessionID, batName, EventPlayback,trialNum,callNum,rewardNum,callOnly,playbackF2);
                end
                soundmexpro('wait');
                soundmexpro('cleardata');
                %pause(0.3); %allow the sound to be played and light on before activating reward
                %beamTime1 = tic;
                responseTimer = tic; %start timer for response from playback
                beamBreakCount=0;
                timeOutTrg = 0;
                playbackTrg = 1;
                %beamVal1 = beamOpen;
            end
        end
        %continue pulling in sound
        [succ, clipout,clipin]=soundmexpro('clipcount');
        soundmexpro('resetclipcount'); %continue reseting count to detect call
        %if toc(ledLoopTime)<seq(seqOrder(trialNum)) %only do pause for checking recording if cue time is up
        pause(durThresh);
        %end
        %high pass filter for audio before triggering cue/reward
        if max(clipin(channel))>=feedbbuf && playbackTrg == 1
            callTrigger = datestr(now, 'yyyymmddTHHMMSSFFF');
            [succ,rectrg,pos]=soundmexpro('recgetdata','channel',0);
            filt_trg=filter(B,A,rectrg(end-durThresh*fs:end));
            H=rms(filt_trg);
            if H<rmsThresh %may need to increase if still get cage noise
                clipin=clipin.*0;
                %else
                %soundmexpro('loadmem','data',video_trigger,'track',triggerchan,'loopcount',1);
            end
        end
        if toc(responseTimer) >= responseTime && playbackTrg == 1
            timeOutTrg = 1;
        end
    end
    if toc(responseTimer) >= responseTime && playbackTrg == 1
        writeDigitalPin(a,ledPin2,0); %turn off trial cue LED
        writeDigitalPin(a,ledPin3,0); %turn off reward LED
        
        timeOutCount=timeOutCount+1; %start adding how many fail/ignores took place
        ledTime1 = tic; %timer for LED timeout
        lastReward=tic; %timer for timeOutReset
        fprintf('Time Out 4 >>>>> %s\n', datestr(now,21));
        if debugButton == 0
            fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                sessionType, sessionID, batName, EventNoGo,trialNum,callNum,rewardNum,callOnly,comments);
        end
        writeDigitalPin(a,ledPin1,1); %light timeout LED
        while toc(ledTime1)<ledTimeOut %during toLED on
            %aud record during delay
            recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
        end
        %end the timeoutLED
        writeDigitalPin(a,ledPin1,0); %turn off timeout led
        beamBreakTrg = beamOpen;
        timeOutTrg = 1;
        playbackTrg = 0;
        playbackTimer = tic;
    elseif timeOutTrg == 0 && playbackTrg == 1 && max(clipin(channel))>=feedbbuf
        %if call detected
        writeDigitalPin(a,ledPin2,1); %turn on trial cue LED
        writeDigitalPin(a,ledPin3,0); %turn off reward LED
        trg=1; %state of recording 1=call occurred
        timelapse=tic; %timer for recording b4 reward
        if debugButton == 0
            callNum = callNum +1;
            fprintf(logFileId, formatSpec, callTrigger,...
                sessionType, sessionID, batName, EventCall,trialNum,callNum,rewardNum,callOnly,comments);
        end
        fprintf('1-Call occurred #%i >>>>> %s\n', callNum, datestr(now,21));
        beamVal2 = beamOpen;
        beamVal3 = beamOpen;
        playbackTimer = tic;
    else
        timeOutCount=0; %timeout mode still off
        stopped=1; %back
    end
    
    %check for bat to go to reward port
    beamTime1 = tic;
    beamVal2 = readDigitalPin(a,beamPin2);
    beamVal3 = readDigitalPin(a,beamPin3);
    waitcount=0; %status for recording during waiting b4 reward
    n=2; %avoid overlap of aud recordings
    
    
    %restart trial if bat too slow to get reward
    while beamVal2 == beamOpen && beamVal3 == beamOpen && playbackTrg == 1 ...
            && toc(beamTime1) < maxDelay && strcmp(get(starth,'string'),'STOP') %beam not broken and not longer than delay
        drawnow;
        beamVal2 = readDigitalPin(a,beamPin2);
        beamVal3 = readDigitalPin(a,beamPin3);
        %turn off cue LED
        if toc(beamTime1) > ledCue
            writeDigitalPin(a,ledPin2,0);
        end
        %get audio data for trigger call
        if trg==1
            if toc(timelapse)>=recDur*recShift && waitcount==0
                [succ,recstart,pos]=soundmexpro('recgetdata','channel',0);
                waitcount=1;
                if debugButton == 1
                    figure;plot(recstart)
                end
            end
        end
        %get audio data consecutively without overlapping
        if toc(timelapse)>=recDur*n
            if waitcount==0,
                recstart=[]; %start fresh variable for new rec
            end
            [succ,recbuf,pos]=soundmexpro('recgetdata','channel',0);
            n=n+1;
            %get audio data if more calls during waiting period
            if max(abs(recbuf))>recCont
                callTrigger = datestr(now, 'yyyymmddTHHMMSSFFF');
                callContTrigger = datestr(now, 'yyyymmddTHHMMSSFFF');
                if waitcount==0,
                    callNum=callNum+1;
                    waitcount=1;
                end
                %beam is broken, then call is detected
                trg=2;
                recstart=[recstart;recbuf];
                if debugButton == 1
                    figure;plot(recstart)
                end
                fprintf('2-Call continuing >>>>> %s\n', datestr(now,21));
                if debugButton == 0
                    fprintf(logFileId, formatSpec, callContTrigger,...
                        sessionType, sessionID, batName, EventCall2,trialNum,callNum,rewardNum,callOnly,comments);
                end
            end
        end
    end
    
    %bat makes it to reward port
    if beamVal2 == beamBreak && playbackTrg == 1 %front reward beam broken
        writeDigitalPin(a,ledPin3,0); %turn on reward LED
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
        pause(motorT*2); %0.32 = 1/100 reward
        stop(dcm);
        writeDigitalPin(a,ledPin3,0); %turn off reward LED
        timeOutCount = 0; %reset timeout counter to 0
        lastReward=tic; %timer for timeOutReset
        %save the call after reward given
        if trg~=0
            if debugButton == 1
                fprintf('Getting recording\n');
            end
            if waitcount==0  %audio record again?????
                if toc(timelapse) < instaReward %bat gets reward quickly so dont cut off call
                    pause(instaReward-toc(timelapse));
                end
                [succ,recstart,pos]=soundmexpro('recgetdata','channel',0);
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
            %aud record only during interval period
            recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
        end
        trg = 0;
        beamVal2 = beamOpen;
        beamBreakTrg=beamOpen;
        playbackTrg = 0;
        
        % use this when the bats are split into 2 compartments
    elseif beamVal3 == beamBreak && playbackTrg == 1 %back reward beam broken
        writeDigitalPin(a,ledPin3,0); %turn on reward LED
        writeDigitalPin(a,ledPin2,0); %turn off trial beam break
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
        pause(motorT*2); %0.32 = 1/100 reward
        stop(dcm);
        writeDigitalPin(a,ledPin3,0); %turn off reward LED
        timeOutCount = 0; %reset timeout counter to 0
        lastReward=tic; %timer for timeOutReset
        %save the call after reward given
        if trg~=0
            if debugButton == 1
                fprintf('Getting recording\n');
            end
            if waitcount==0 %audio record again?????
                [succ,recstart,pos]=soundmexpro('recgetdata','channel',0);
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
            %aud record only during interval period
            recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
        end
        trg = 0;
        beamVal3 = beamOpen;
        beamBreakTrg=beamOpen;
        playbackTrg = 0;
        %bat didn't go to port, illuminate timeout led
    elseif toc(beamTime1) > maxDelay && playbackTrg == 1 && timeOutTrg ==0
        beamBreakTrg = beamOpen;
        timeOutCount=timeOutCount+1; %start adding how many fail/ignores took place
        ledTime1 = tic; %timer for LED timeout
        lastReward=tic; %timer for timeOutReset
        fprintf('Time Out 2 >>>>> %s\n', datestr(now,21));
        if debugButton == 0
            fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                sessionType, sessionID, batName, EventNoGo,trialNum,callNum,rewardNum,callOnly,comments);
        end
        writeDigitalPin(a,ledPin2,0); %turn off cue/reward led
        writeDigitalPin(a,ledPin3,0); % turn off cue/reward led
        writeDigitalPin(a,ledPin1,1); %light timeout LED
        %save the call after timeout
        if trg~=0
            if debugButton == 1
                fprintf('Getting recording\n');
            end
            if waitcount==0 %get audio recording
                [succ,recstart,pos]=soundmexpro('recgetdata','channel',0);
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
            %aud record during delay
            recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
            
        end
        %end the timeoutLED
        writeDigitalPin(a,ledPin1,0); %turn off timeout led
    else
        %timeOutCount=0; %reset timeout counter
        stopped=1;
    end
    %save the call after reward given
    if trg~=0
        if debugButton == 1
            fprintf('Getting recording\n');
        end
        if waitcount==0 %audio record again?????
            [succ,recstart,pos]=soundmexpro('recgetdata','channel',0);
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
    
    
    %bat ignored cue signal for 3+ times & now goes to 10 min time out
    if toc(lastReward)>= ignoreTime && timeOutCount ~= 0 %5min
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
            recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
        end
        timeOutCount=0; %reset timeout count to 0 after reaching 3
    end
    %move on to next trial
    if stopped~=1, %if not in middle of rec
        if debugButton == 1
            fprintf('***Back to waiting >>>>> %s\n',datestr(now,21));
        end
        trialNum=trialNum+1; %end of trial
        
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
            rewardNum = 0;
            dcm.Speed=motorS; %reset motor back to forward
            try
                sendmail({'tschmid7489@gmail.com'},['Box ' num2str(boxNum) ' be Hungry'],'ya scallywag :)')
            catch exception
                continue
            end
            while strcmp(get(starth,'string'),'STOP')
                writeDigitalPin(a,ledPin1,0); %light timeout LED
                recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
            end
        end
    end
end
if strcmp(get(starth,'string'),'START')
    writeDigitalPin(a,ledPin2,0); %turn off cue/reward led
    writeDigitalPin(a,ledPin3,0); % turn off cue/reward led
    writeDigitalPin(a,ledPin1,0); %light timeout LED
    return
end
end
%%
% %while trg == 0
% %keep checking button
% playbackButton = get(playbackbuttonh,'value');
% if playbackButton == 0
%     fprintf('Begin Session: %s\n', datestr(now,21));
%     if debugButton == 0
%         fprintf(logFileId, formatSpec, datestr(now,'yyyymmddTHHMMSSFFF'),...
%             sessionType, sessionID, batName, EventStartSession,'','','',comments);
%     end
%     playbackTrg =0;
% end
% %turn off cue LED
% if toc(beamTime1) > ledCue
%     writeDigitalPin(a,ledPin2,0);
% end
% %continue pulling in sound
% [succ, clipout,clipin]=soundmexpro('clipcount');
% soundmexpro('resetclipcount'); %continue reseting count to detect call
% %if toc(ledLoopTime)<seq(seqOrder(trialNum)) %only do pause for checking recording if cue time is up
% pause(durThresh);
% %end
% %high pass filter for audio before triggering cue/reward
% if max(clipin(channel))>=feedbbuf
%     callTrigger = datestr(now, 'yyyymmddTHHMMSSFFF');
%     [succ,rectrg,pos]=soundmexpro('recgetdata','channel',0);
%     filt_trg=filter(B,A,rectrg(end-durThresh*fs:end));
%     H=rms(filt_trg);
%     if H<rmsThresh %may need to increase if still get cage noise
%         clipin=clipin.*0;
%         %else
%         %soundmexpro('loadmem','data',video_trigger,'track',triggerchan,'loopcount',1);
%     else
%         trg=1; %state of recording 1=call occurred
%         timelapse=tic; %timer for recording b4 reward
%         if debugButton == 0
%             callOnly = callOnly +1;
%             fprintf(logFileId, formatSpec, callTrigger,...
%                 sessionType, sessionID, batName, EventRecsOnly,trialNum,callNum,rewardNum,callOnly,comments);
%         end
%         fprintf('4-Call occurred #%i >>>>> %s\n', callOnly, datestr(now,21));
%         waitcount = 0;
%     end
%     %get audio data for trigger call
%     if trg==1
%         if toc(timelapse)>=recDur*recShift && waitcount==0
%             [succ,recstart,pos]=soundmexpro('recgetdata','channel',0);
%             waitcount=1;
%             if debugButton == 1
%                 figure;plot(recstart)
%             end
%         end
%         if debugButton == 1
%             fprintf('Getting recording\n');
%         end
%         if waitcount==0  %audio record again?????
%             if toc(timelapse) < instaReward %bat gets reward quickly so dont cut off call
%                 pause(instaReward-toc(timelapse));
%             end
%             [succ,recstart,pos]=soundmexpro('recgetdata','channel',0);
%         end
%         recbuf=recstart; %reset recording buffer variable
%
%         [succ,xrun,xruncpu,xrundata]=soundmexpro('xrun'); %count any dropped samples
%         if debugButton == 0
%             save([recPath callTrigger(1:end-3) '_' batName '_' num2str(callNum) '.mat'],'recbuf','fs','xrun','sessionType','sessionID','batName','micType','callNum','callTrigger',...
%                                'motorS', 'motorT', 'ledCue','maxDelay','minWait','minInt','maxInt','ledTimeOut','maxTimeOut','dunceCap',...
%                                'channel','motuGain','recDur','ampThresh','durThresh','rmsThresh','comments','EventStartSession'); %save
%         end
%         soundmexpro('resetclipcount'); %reset recording trigger
%         if debugButton == 1
%             fprintf('Calls saved\n');
%         end
%         trg=0; %reset recording state
%     end
% end
%
% %check BB and filter if bat waits min wait time before triggering cue/reward
% beamVal1 = readDigitalPin(a, beamPin1); %keep checking trial BB
% if beamVal1 == beamBreak && playbackButton == 1
%     beamBreakCount=beamBreakCount + 1; %change to BB mode
%     if beamBreakCount==1
%         beamBreakWait=tic; %start timer
%     else
%         beamBreakLapse=toc(beamBreakWait);
%         if beamBreakLapse>=minWait %wait min time
%             beamBreakTrg=beamBreak;
%             %if call detected or trial beam broken
%             writeDigitalPin(a,ledPin2,1); %turn on trial cue LED
%             writeDigitalPin(a,ledPin3,0); %turn off reward LED
%             fprintf('Broke Beam, Trial #%i Initiated >>>>> %s\n', trialNum, datestr(now,21));
%             if debugButton == 0
%                 fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
%                     sessionType, sessionID, batName, EventTrialStart,trialNum,callNum,rewardNum,callOnly,comments);
%             end
%             %playback a call from the selector
%             fileNum = fileseq(file_i);
%             playbackFn = directory(fileNum).name;
%             load([filepn playbackFn]);
%             playbackFilen = recbuf;
%             file_i = file_i + 1;
%             if file_i >= length(directory)
%                 file_i = 1;
%             end
%             % play call
%             soundmexpro('loadmem', ... %play call
%                 'data', playbackFilen, ...   % data vector
%                 'track',track, ... %the virtual track
%                 'loopcount',1);
%             soundmexpro('wait');
%             soundmexpro('cleardata');
%             fprintf('Playback Call #%i %s >>>>> %s\n', playback_i, playbackFn, datestr(now, 21));
%             if debugButton == 0
%                 fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
%                     sessionType, sessionID, batName, EventPlayback,trialNum,callNum,rewardNum,callOnly,playbackFn);
%             end
%             %pause(0.3); %allow the sound to be played and light on before activating reward
%             responseTimer = tic; %start timer for response from playback
%             playBackTrg = 1;
%             beamBreakCount=0;
%         end
%     end
% end
% %end
% % check whether bat calls back
% while toc(responseTimer) < responseTime && playbackTrg == 1 ...
%         && beamBreakTrg == beamBreak && max(clipin(channel)) < feedbbuf ...
%         && playbackButton == 1 && strcmp(get(starth,'string'),'STOP')
%     %turn off cue LED
%     if toc(responseTimer) > ledCue
%         writeDigitalPin(a,ledPin2,0);
%     end
%     %continue pulling in sound
%     [succ, clipout,clipin]=soundmexpro('clipcount');
%     soundmexpro('resetclipcount'); %continue reseting count to detect call
%     %if toc(ledLoopTime)<seq(seqOrder(trialNum)) %only do pause for checking recording if cue time is up
%     pause(durThresh);
%     %end
%     %high pass filter for audio before triggering cue/reward
%     if max(clipin(channel))>=feedbbuf
%         callTrigger = datestr(now, 'yyyymmddTHHMMSSFFF');
%         [succ,rectrg,pos]=soundmexpro('recgetdata','channel',0);
%         filt_trg=filter(B,A,rectrg(end-durThresh*fs:end));
%         H=rms(filt_trg);
%         if H<rmsThresh %may need to increase if still get cage noise
%             clipin=clipin.*0;
%             %else
%             %soundmexpro('loadmem','data',video_trigger,'track',triggerchan,'loopcount',1);
%         end
%         writeDigitalPin(a,ledPin2,1); %turn on trial cue LED
%         writeDigitalPin(a,ledPin3,0); %turn off reward LED
%         trg=1; %state of recording 1=call occurred
%         timelapse=tic; %timer for recording b4 reward
%         if debugButton == 0
%             callNum = callNum +1;
%             fprintf(logFileId, formatSpec, callTrigger,...
%                 sessionType, sessionID, batName, EventCall,trialNum,callNum,rewardNum,callOnly,comments);
%         end
%         fprintf('1-Call occurred #%i >>>>> %s\n', callNum, datestr(now,21))
%         waitcount = 0;
%         if trg==1
%             if toc(timelapse)>=recDur*recShift && waitcount==0
%                 [succ,recstart,pos]=soundmexpro('recgetdata','channel',0);
%                 waitcount=1;
%                 if debugButton == 1
%                     figure;plot(recstart)
%                 end
%             end
%             if debugButton == 1
%                 fprintf('Getting recording\n');
%             end
%             if waitcount==0  %audio record again?????
%                 if toc(timelapse) < instaReward %bat gets reward quickly so dont cut off call
%                     pause(instaReward-toc(timelapse));
%                 end
%                 [succ,recstart,pos]=soundmexpro('recgetdata','channel',0);
%             end
%             recbuf=recstart; %reset recording buffer variable
%
%             [succ,xrun,xruncpu,xrundata]=soundmexpro('xrun'); %count any dropped samples
%             if debugButton == 0
%                 save([recPath callTrigger(1:end-3) '_' batName '_' num2str(callNum) '.mat'],'recbuf','fs','xrun','sessionType','sessionID','batName','micType','callNum','callTrigger',...
%                                'motorS', 'motorT', 'ledCue','maxDelay','minWait','minInt','maxInt','ledTimeOut','maxTimeOut','dunceCap',...
%                                'channel','motuGain','recDur','ampThresh','durThresh','rmsThresh','comments','EventStartSession'); %save
%             end
%             soundmexpro('resetclipcount'); %reset recording trigger
%             if debugButton == 1
%                 fprintf('Calls saved\n');
%             end
%             rewardTimer
%             playbackTrg = 0; %reset playback state
%             beamBreakTrg = beamOpen; %reset beambreak state
%             beamTime1 = tic;
%         end
%     end
% end
%
% while trg==1 && playbackButton == 1 && toc(beamTime1) < maxDelay
%     %check for bat to go to reward port
%     beamVal2 = readDigitalPin(a,beamPin2);
%     beamVal3 = readDigitalPin(a,beamPin3);
%     if beamVal2 == beamBreak
%         trg = 0;
%     elseif beamVal3 == beamBreak
%         trg = 0;
%     end
% end
% %bat makes it to reward port
% if beamVal2 == beamBreak %front reward beam broken
%     %writeDigitalPin(a,ledPin3,1); %turn on reward LED
%     %writeDigitalPin(a,ledPin2,0); %turn off trial beam break
%     if debugButton == 0
%         rewardNum = rewardNum + 1;
%         fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
%             sessionType, sessionID, batName, EventReward,trialNum,callNum,rewardNum,callOnly,'Front');
%     end
%     fprintf('Reward Front #%i >>>>> %s\n', rewardNum, datestr(now,21));
%
%     %deliver reward with servo
%     %dcm.Speed = motorS; %1=full
%     %start(dcm);
%     %pause(motorT); %0.32 = 1/100 reward
%     %stop(dcm);
%     %writeDigitalPin(a,ledPin3,0); %turn off reward LED
%     %timeOutCount = 0; %reset timeout counter to 0
%     %lastReward=tic; %timer for timeOutReset
%     beamVal2 = beamOpen;
%     %playbackTimer = tic;
%     %playbackTrg = 0;
%     %playback_i = playback_i + 1;
% elseif beamVal3 == beamBreak %back reward beam broken
%     writeDigitalPin(a,ledPin3,1); %turn on reward LED
%     writeDigitalPin(a,ledPin2,0); %turn off trial beam break
%     if debugButton == 0
%         rewardNum = rewardNum + 1;
%         fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
%             sessionType, sessionID, batName, EventReward,trialNum,callNum,rewardNum,callOnly,'Back');
%     end
%     fprintf('Reward Back #%i >>>>> %s\n', rewardNum, datestr(now,21));
%     %deliver reward with servo
%     dcm.Speed = motorS; %1=full
%     start(dcm);
%     pause(motorT); %0.32 = 1/100 reward
%     stop(dcm);
%     writeDigitalPin(a,ledPin3,0); %turn off reward LED
%     timeOutCount = 0; %reset timeout counter to 0
%     lastReward=tic; %timer for timeOutReset
%     beamVal3 = beamOpen;
%     playbackTimer = tic;
%     playbackTrg = 0;
%     playback_i = playback_i + 1;
%     %bat didn't go to port, illuminate timeout led
% elseif toc(beamTime1) > maxDelay
%     beamBreakTrg = beamOpen;
%     timeOutCount=timeOutCount+1; %start adding how many fail/ignores took place
%     ledTime1 = tic; %timer for LED timeout
%     lastReward=tic; %timer for timeOutReset
%     fprintf('Time Out 3 >>>>> %s\n', datestr(now,21));
%     if debugButton == 0
%         fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
%             sessionType, sessionID, batName, EventNoGo,trialNum,callNum,rewardNum,callOnly,comments);
%     end
%     writeDigitalPin(a,ledPin1,1); %light timeout LED
%     while toc(ledTime1)<ledTimeOut %during toLED on
%         %aud record during delay
%         recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
%     end
%     %end the timeoutLED
%     writeDigitalPin(a,ledPin1,0); %turn off timeout led
%     responseTimer = tic;
%     playbackTimer = tic;
%     playbackTrg = 0;
%     playback_i = playback_i + 1;
% else
%     timeOutCount=0; %reset timeout counter
%     stopped=1;
% end
%
% %bat ignored cue signal for 3+ times & now goes to 10 min time out
% if toc(lastReward)>= ignoreTime %5min
%     timeOutCount=0; %reset timeout counter if not paying attention for 5 min
%     fprintf('reset timeout count %s\n', datestr(now,21));
% end
% if timeOutCount==maxTimeOut %ex: 3
%     timeOut=tic; %timer for long time out
%     dunceCapMin = dunceCap/60; %ex: 10 min
%     fprintf('No response lock out - %i min >>>>> %s\n', dunceCapMin, datestr(now,21));
%     if debugButton == 0
%         fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
%             sessionType, sessionID, batName, EventDunceCap,trialNum,callNum,rewardNum,callOnly,comments);
%     end
%
%
%     %go to rec only for dunceCap min
%     while toc(timeOut)<dunceCap && strcmp(get(starth,'string'),'STOP')
%         drawnow;
%         recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
%     end
%     timeOutCount=0; %reset timeout count to 0 after reaching 3
% end\

%%
% %continue pulling in sound
%             [succ, clipout,clipin]=soundmexpro('clipcount');
%             soundmexpro('resetclipcount'); %continue reseting count to detect call
%             %if toc(ledLoopTime)<seq(seqOrder(trialNum)) %only do pause for checking recording if cue time is up
%             pause(durThresh);
%             %end
%             %high pass filter for audio before triggering cue/reward
%             if max(clipin(channel))>=feedbbuf
%                 callTrigger = datestr(now, 'yyyymmddTHHMMSSFFF');
%                 [succ,rectrg,pos]=soundmexpro('recgetdata','channel',0);
%                 filt_trg=filter(B,A,rectrg(end-durThresh*fs:end));
%                 H=rms(filt_trg);
%                 if H<rmsThresh %may need to increase if still get cage noise
%                     clipin=clipin.*0;
%                     %else
%                     %soundmexpro('loadmem','data',video_trigger,'track',triggerchan,'loopcount',1);
%                 else
%                     %soundmexpro('loadmem','data',video_trigger,'track',0,'loopcount',1);
%                     pause(rec_t-pre_trg)
%                     [succ,recbuf,pos]=soundmexpro('recgetdata','channel',0); % record sound data
%                     callOnly = callOnly +1;
%                     fprintf('4-Call occurred #%i >>>>> %s\n', callOnly, datestr(now,'HH:MM:SS'));
%                     if debugButton == 1
%                         figure;plot(recbuf)
%                     end
%                     if debugButton == 0
%                         fprintf(logFileId, formatSpec, callOnlyTrigger,...
%                             sessionType, sessionID, batName, EventOnly,trialNum,callNum,rewardNum,callOnly,comments);
%                     end
%                     %get audio data consecutively without overlapping
%                     if toc(timelapse)>=recDur*n
%                         if waitcount==0,
%                             recstart=[]; %start fresh variable for new rec
%                         end
%                         [succ,recbuf,pos]=soundmexpro('recgetdata','channel',0);
%                         n=n+1;
%                         %get audio data if more calls during waiting period
%                         if max(abs(recbuf))>recCont
%                             callTrigger = datestr(now, 'yyyymmddTHHMMSSFFF');
%                             callContTrigger = datestr(now, 'yyyymmddTHHMMSSFFF');
%                             if waitcount==0,
%                                 callNum=callNum+1;
%                                 waitcount=1;
%                             end
%                             %beam is broken, then call is detected
%                             trg=2;
%                             recstart=[recstart;recbuf];
%                             if debugButton == 1
%                                 figure;plot(recstart)
%                             end
%                             fprintf('2-Call continuing >>>>> %s\n', datestr(now,21));
%                             if debugButton == 0
%                                 fprintf(logFileId, formatSpec, callContTrigger,...
%                                     sessionType, sessionID, batName, EventCall2,trialNum,callNum,rewardNum,callOnly,comments);
%                             end
%                         end
%                     end
%                     % save lost sample data
%                     [succ,xrun,xruncpu,xrundata]=soundmexpro('xrun');
%                     %save recordings
%                     if debugButton == 0
%                         save([recPath 'callOnly_' callOnlyTrigger(1:end-3) '_' batName '_' num2str(callOnly) '.mat'],'recbuf','fs','xrun','sessionType','sessionID','batName','micType','callNum','callTrigger',...
%                                'motorS', 'motorT', 'ledCue','maxDelay','minWait','minInt','maxInt','ledTimeOut','maxTimeOut','dunceCap',...
%                                'channel','motuGain','recDur','ampThresh','durThresh','rmsThresh','comments','EventStartSession'); %save
%                     end
%                     if debugButton ==1
%                         fprintf('Calls saved in reconly \n');
%                     end
%                     soundmexpro('resetclipcount'); %reset recording trigger
%                     pause(durThresh); %check feedback_min_dur that its right
%                 end
%             end
function playbackAT(boxNum)

global fs pre_trg feedbbuf bufsiz recPath xrun recstart;
global a ledPin1 ledPin2 ledPin3 beamPin1 beamPin2 beamPin3 dunceCap;
global debugButton logFileId formatSpec trialNum callNum rewardNum callOnly;
global date sessionType sessionID comments batName sleepTime ignoreTime;
global dcm motorS motorT ledCue ledTimeOut maxDelay minInt maxInt maxTimeOut;
global motuGain recDur ampThresh durThresh traintimeh freqThresh B A;
global fh starth thrdh thrah recdh motugh thrrh thrfh rmsThresh minW maxR;
global dateh sessionth sessionidh commenth batnameh debugbuttonh minWait;
global motorSh motorTh cueledh timeoutledh recbuttonh trainonh recchanh;
global maxdelayh mininth maxinth maxtimeouth duncecaph minwaith maxrewardh;
global EventTrialStart EventDunceCap EventReward EventRecsOnly EventCue EventSleep;
global EventResetSession EventNoGo EventCall EventSessionDone EventReward2 EventCall2;
global ledTime1 beginSession beamVal1 beamVal2 beamVal3 stopped recShift recCont;
global EventComment lastReward EventStartSession DayNumberStop instaReward channel;
global video_trigger playbackbuttonh playbackfileh responseth EventPlayback playbackFile playchan;
global triggerchan playbackF minbwh minBetween boxNum track playback_i;

playbackTimer = tic;
trg=0; %not recording state
beamVal1 = readDigitalPin(a, beamPin1); %check init beam break
beamVal3= beamOpen; %not reward beam state
beamVal2 = beamOpen; %not reward beam state
ledLoopTime=tic; %timer for cue LED loop
soundmexpro('resetclipcount'); %resets clip to 0 so don't accumulate clips when go back into waiting loop
% get audio input information at all times
[succ, clipout,clipin]=soundmexpro('clipcount');

%check for call or trialStart beam break or playback
while max(clipin(channel)) < feedbbuf && toc(playbackTimer) < playbackCountdown(playback_i) ...
        && beamBreakTrg==beamOpen && strcmp(get(starth,'string'),'STOP')     %&& toc(ledLoopTime)<seq(seqOrder(trialNum)) %waiting loop
    drawnow;
    if toc(beamTime1) > ledCue %turn off cue LED
        writeDigitalPin(a,ledPin2,0);
    end
    
    [succ, clipout,clipin]=soundmexpro('clipcount'); %continue pulling in sound
    soundmexpro('resetclipcount'); %continue reseting count to detect call
    %if toc(ledLoopTime)<seq(seqOrder(trialNum)) %only do pause for checking recording if cue time is up
    pause(durThresh);
    %end
    %high pass filter for audio before triggering cue/reward
    if max(clipin(channel))>=feedbbuf
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
    
    %check BB if bat waits min wait time before triggering cue/reward
    beamVal1 = readDigitalPin(a, beamPin1); %keep checking trial BB
    if beamVal1 == beamBreak
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

    %max Num Reward tag remains open
    maxR=get(maxrewardh,'string');
    maxReward=str2num(maxR);
    
    %load playback file tag remains open
    playbackButton = get(playbackbuttonh,'value');
    if playbackButton == 1
        playbackF=get(playbackfileh,'string'); %select all strings in dropdown menu
        playbackF2=playbackF{get(playbackfileh,'value')}; %select the string you chose
        load(playbackF2); %load that file for playback
        playbackFile = recbuf; %may need to change recbuf if it is a different variable
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
        end
    end
end

%playback call
if toc(playbackTimer) >=  playbackCountdown(playback_i)
    soundmexpro('loadmem', ... %play call
        'data', playbackFile, ...   % data vector
        'track',track, ... %the virtual track
        'loopcount',1);
    writeDigitalPin(a,ledPin2,1); %turn on trial cue LED
    beamTime1 = tic; %start timer to turn off cue LED
    fprintf('Playback Call #%i >>>>> %s\n', playback_i, datestr(now, 21));
    if debugButton == 0
        fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
            sessionType, sessionID, batName, EventPlayback,trialNum,callNum,rewardNum,callOnly,playbackF2);
    end
    playback_i = playback_i + 1; %add to playback_i
    timeOutTrg = 0;
end

beamTime1 = tic; %keep timer for cue LED & trial
beamVal2 = beamOpen; %open front reward beam
beamVal3 = beamOpen; %open back reward beam
%trial beam is broken, trial initiated
if timeOutTrg == 0
    if beamVal1 == beamBreak
        %if call detected or trial beam broken
        writeDigitalPin(a,ledPin2,1); %turn on trial cue LED
        writeDigitalPin(a,ledPin3,0); %turn off reward LED
        fprintf('Broke Beam, Trial #%i Initiated >>>>> %s\n', trialNum, datestr(now,21));
        if debugButton == 0
            fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                sessionType, sessionID, batName, EventTrialStart,trialNum,callNum,rewardNum,callOnly,comments);
        end
        %call is detected, trial initiated
    elseif  max(clipin(channel))>=feedbbuf
        %if call detected or trial beam broken
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
    else
        timeOutCount=0; %timeout mode still off
        stopped=1; %back
    end
    
    
    %check for bat to go to reward port
    beamVal2 = readDigitalPin(a,beamPin2);
    beamVal3 = readDigitalPin(a,beamPin3);
    waitcount=0; %status for recording during waiting b4 reward
    n=2; %avoid overlap of aud recordings
    
    %restart trial if bat too slow to get reward
    while beamVal2 == beamOpen && beamVal3 == beamOpen ...
            && toc(beamTime1) < maxDelay && strcmp(get(starth,'string'),'STOP') %beam not broken and not longer than delay
        drawnow;
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
        beamVal2 = readDigitalPin(a,beamPin2); %check front reward beam
        beamVal3 = readDigitalPin(a,beamPin3); %check back reward beam
    end
    
    %call triggers a trial
    if trg==1
        if toc(timelapse)>=recDur*recShift && waitcount==0
            [succ,recstart,pos]=soundmexpro('recgetdata','channel',0);
            waitcount=1;
        end
        
    end
    
    %bat makes it to reward port
    if beamVal2 == beamBreak %front reward beam broken
        writeDigitalPin(a,ledPin3,1); %turn on reward LED
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
        pause(motorT); %0.32 = 1/100 reward
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
                [succ,recstart,pos]=soundmexpro('recgetdata','channel',0);
            end
            recbuf=recstart; %reset recording buffer variable
            
            [succ,xrun,xruncpu,xrundata]=soundmexpro('xrun'); %count any dropped samples
            if debugButton == 0
                save([recPath callTrigger(1:end-3) '_' batName '_' num2str(callNum) '.mat'],'recbuf','fs','xrun'); %save
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
        % use this when the bats are split into 2 compartments
    elseif beamVal3 == beamBreak %back reward beam broken
        writeDigitalPin(a,ledPin3,1); %turn on reward LED
        writeDigitalPin(a,ledPin2,0); %turn off trial beam break
        beamTime2 = tic; %start reward timer
        if debugButton == 0
            rewardNum = rewardNum + 1;
            fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                sessionType, sessionID, batName, EventReward,trialNum,callNum,rewardNum,'Back');
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
        beamBreakTrg=beamOpen;
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
                save([recPath callTrigger(1:end-3) '_' batName '_' num2str(callNum) '.mat'],'recbuf','fs','xrun'); %save
            end
            soundmexpro('resetclipcount'); %reset recording trigger
            if debugButton == 1
                fprintf('Calls saved\n');
            end
            trg=0; %reset recording state
        end
        while toc(lastReward)<ledTimeOut %delay before allowing next trial
            %aud record only during interval period
            recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
        end
        
        %bat didn't go to port, illuminate timeout led
    elseif toc(beamTime1) > maxDelay && timeOutTrg ==0
        beamBreakTrg = beamOpen;
        timeOutCount=timeOutCount+1; %start adding how many fail/ignores took place
        ledTime1 = tic; %timer for LED timeout
        lastReward=tic; %timer for timeOutReset
        fprintf('Time Out 2 >>>>> %s\n', datestr(now,21));
        if debugButton == 0
            fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                sessionType, sessionID, batName, EventNoGo,trialNum,callNum,rewardNum,callOnly,comments);
        end
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
                save([recPath callTrigger(1:end-3) '_' batName '_' num2str(callNum) '.mat'],'recbuf','fs','xrun'); %save
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
            save([recPath callTrigger(1:end-3) '_' batName '_' num2str(callNum) '.mat'],'recbuf','fs','xrun'); %save
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
if timeOutCount==maxTimeOut %ex: 3
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
            recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
        end
    end
end

ledLoopTime=tic; %reset led loop timer for pause
% % option to control reward LED independently
%             if toc(beamTime2) > ledReward
%                 writeDigitalPin(a,ledPin3,0);
%             end
end





    %go into timeout if bat doesn't respond within time
    if toc(responseTimer) >= responseTime
        timeOutCount=timeOutCount+1; %start adding how many fail/ignores took place
        ledTime1 = tic; %timer for LED timeout
        lastReward=tic; %timer for timeOutReset
        fprintf('Time Out 1 >>>>> %s\n', datestr(now,21));
        if debugButton == 0
            fprintf(logFileId, formatSpec, datestr(now, 'yyyymmddTHHMMSSFFF'),...
                sessionType, sessionID, batName, EventNoGo,trialNum,callNum,rewardNum,callOnly,comments);
        end
        %writeDigitalPin(a,ledPin1,1); %light timeout LED
        while toc(ledTime1)<ledTimeOut %during toLED on
            %aud record during delay
            recOnly(fs,feedbbuf,durThresh,recDur,pre_trg,channel) %function to record only
            
        end
        %end the timeoutLED
        writeDigitalPin(a,ledPin1,0); %turn off timeout led
        timeOutTrg = 1;
        break
    end
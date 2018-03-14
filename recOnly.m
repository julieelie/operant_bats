function recOnly(fs,feedbbuf,feedback_min_dur,rec_t,pre_trg,channel)
global recPath callNum debugButton logFileId formatSpec B A durThresh rmsThresh;
global sessionType sessionID batName trialNum rewardNum comments callOnly EventOnly;
global video_trigger micType motorS motorT ledCue maxDelay minWait; 
global minInt maxInt ledTimeOut maxTimeOut beamBreakCount beamBreakWait;
global dunceCap motuGain recDur ampThresh EventStartSession responseTimer starth;
global playbackTimer playbackTrg responseTrg beamVal1 beamBreak a beamPin4 recbuf recchan;
global EventComment resetTrg recShift;

[succ, clipout,clipin]=soundmexpro('clipcount');

%collect nonrewarded call    
if max(clipin(channel))>=feedbbuf,
    callOnlyTrigger = datestr(now, 'yyyymmddTHHMMSSFFF');
    [succ,rectrg,pos]=soundmexpro('recgetdata','channel',recchan); % record sound data
    filt_trg=filtfilt(B,A,rectrg(end-durThresh*fs:end,1));
    H=rms(filt_trg);
    if H<rmsThresh %may need to increase if still get cage noise
        clipin=clipin.*0;
    fprintf('low rms %i >>>>> %s\n', H, datestr(now,'HH:MM:SS'));
    else
        %soundmexpro('loadmem','data',video_trigger,'track',0,'loopcount',1);
        fprintf('rms %i >>>> %s\n', H, datestr(now,21)); 
        pause(recShift)
                                                                                % WHY GETTING THE SOUND DATA AGAIN, HOW IS RECBUF ANYDIFFERENT FROM RECTRG?
                                                                                [succ,recbuf,pos]=soundmexpro('recgetdata','channel',recchan); % record sound data
        callOnly = callOnly +1;
        fprintf('4-Call occurred #%i >>>>> %s\n', callOnly, datestr(now,'HH:MM:SS'));
        if debugButton == 1
            figure;plot(recbuf)
        end
        if debugButton == 0
            fprintf(logFileId, formatSpec, callOnlyTrigger,...
                sessionType, sessionID, batName, EventOnly,trialNum,callNum,rewardNum,callOnly,comments);
        end
        
        %determine if front or back bat called
        direc=max(abs(rectrg));
        if length(recchan)>1
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
                                                                            % save lost sample data UNUSED
                                                                            [succ,xrun,xruncpu,xrundata]=soundmexpro('xrun');
                                                                            %recbuf = recbuf(:,1);
        %save recordings
        if debugButton == 0
            save([recPath 'callOnly_' callOnlyTrigger(1:end-3) '_' batName '_' num2str(callOnly) '.mat'],'recbuf','fs','xrun','sessionType','sessionID','batName','micType','callNum','callOnlyTrigger',...
                'motorS', 'motorT', 'ledCue','maxDelay','minWait','minInt','maxInt','ledTimeOut','maxTimeOut','dunceCap',...
                'channel','motuGain','recDur','ampThresh','durThresh','rmsThresh','comments','EventStartSession'); %save
        end
        if debugButton ==1
            fprintf('Calls saved in reconly \n');
        end
    end
end
%playbackTimer during recOnly period if beamBreak or longer than maxInt
if playbackTrg ==1 && responseTrg ==0 && resetTrg == 0
    beamVal1 = readDigitalPin(a,beamPin4);
    if toc(playbackTimer) >= minInt && beamVal1 == beamBreak || toc(playbackTimer) >= maxInt %playbackCountdown(playback_i)
        beamBreakCount=beamBreakCount + 1; %change to BB mode
        if beamBreakCount==1
            beamBreakWait=tic; %start timer
        else
            beamBreakLapse=toc(beamBreakWait);
            if beamBreakLapse>=minWait %wait min time
                beamBreakTrg=beamBreak;
                beamBreakCount=0;
                responseTrg = 1;
                responseTimer = tic;
            end
        end
    else
        beamBreakCount=0;
        %responseTrg = 1;
    end
end
if strcmp(get(starth,'string'),'START')
    drawnow;
    return
end
soundmexpro('resetclipcount'); %reset recording trigger
pause(durThresh); %check feedback_min_dur that its right
end
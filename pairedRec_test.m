clear all;
close all;

fs=192e3;
ID='MOTU Audio ASIO';
input_chan=0:2;
recDur=5;
feedback_threshold_output=-20; %keep high and gain with the cuemix
feedback_min_dur=0.005;
durThresh = 0.01;
rmsThresh = 0.005;
freqThresh = 20;
[B,A]=butter(8,2*freqThresh*1000/fs,'high'); %increase freqthresh to make higher thresh

% initiate soundmexpro
soundmexpro('init','driver',ID,'samplerate',fs,'input',input_chan); %[playchan5 triggerchan5]
soundmexpro('show')

% set record length for audio ring buffer
if 1 ~= soundmexpro( 'recbufsize', 'value', recDur*fs);
    error(['error calling ''loadfile''' error_loc(dbstack)]);
end

%set clipthreshold
if 1 ~= soundmexpro('clipthreshold','type','input','value',...
        10^(feedback_threshold_output/20));
    error('error setting clipthreshold %s\n', datestr(now,30));
end

if 1 ~= soundmexpro('recpause','value', ones(1,length(input_chan)),...
        'channel',input_chan);
    error('error setting recpause %s\n', datestr(now,30));
end
disp('Start recording')
pause;

soundmexpro('start', ...    % command name
    'length', 0 ...
    );
t0=tic;
while toc(t0)<10
    
 [succ, clipout,clipin]=soundmexpro('clipcount');
 if sum(clipin)>0
     disp('Trigger')
     [succ,recbuf,pos]=soundmexpro('recgetdata','channel',input_chan); % record sound data
     filt_trg=filter(B,A,recbuf(end-durThresh*fs:end));
        H=rms(recbuf(:,1));
if H>rmsThresh
     direc=max(abs(recbuf));
            %direc=rms(recbuf);
             if diff(direc)<0
                 disp('Mic 1')
             else
                 disp('Mic 2')
             end
end
 end
 
     soundmexpro('resetclipcount'); %resets clip to 0 so don't accumulate clips when go back into waiting loop

 pause(feedback_min_dur)
 end

disp('Done');
soundmexpro('stop')
[succ,recbuf,pos]=soundmexpro('recgetdata','channel',0); % record sound data
plot(recbuf)
soundmexpro('exit')

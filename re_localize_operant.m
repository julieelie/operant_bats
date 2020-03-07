function [Voc_samp_idx] = re_localize_operant(RawWav_dir, Subj, Date, ExpStartTime, varargin)
%% RE_LOCALIZE_OPERANT a function to retrieve the position of detected reward by vocOperant in continuous recordings
% These activation of the food port is calculated from the vocalization detection
% and the delay2 reward for each vocalization and saved as
% indices values in the corresponding continuous mic recording file
% (Re_samp_idx), and as time values relative to transciever clock (if
% requested, Re_transc_time).
% Note that this function was written as a patch to voc_localize_operant to
% retrieve the times of reward.

% Inputs
% Voc_dir is the folder containing the vocalization extracts to identify

% RawWav_dir is the folder containing the continuous recordings and the
% file *TTLPulseTimes.mat generated by align_soundmexAudio_2_logger.m
% in case calculating transceiver time is requested


% 'TransceiverTime' (optional input): set by default to 1 to calculate the
% onset anf offset of sound extracts in transceiver time

% Ouputs
% Re_samp_idx is a 1 column vector that gives the event indices
% of each reward in the original recordings, same number of lines as
% Voc_filename

% Re_transc_time is a 1 column vector that gives the expected
% time of each reward in transceiver time,
% in ms
% same number of lines as Voc_filename.

%% Load data and initialize output variables
% Get input arguments
Pnames = {'TransceiverTime'};
TranscTime = 1; % Logical to indicate if transceiver time should be calculated for these extracts.
Dflts  = {TranscTime};
[TranscTime] = internal.stats.parseArgs(Pnames,Dflts,varargin{:});


if TranscTime
    % Load the pulse times and samples
    TTL_dir = dir(fullfile(RawWav_dir,sprintf( '%s_%s_TTLPulseTimes.mat', Date, ExpStartTime)));
    TTL = load(fullfile(TTL_dir.folder, TTL_dir.name));
end

% Hard coded input for finding the microphone envelope noise threshold
Dur_RMS = 0.5; % duration of the silence sample in min for the calculation of average running RMS
Fhigh_power = 20; %Hz
Fs_env = 1000; %Hz Sample frequency of the enveloppe
MicThreshNoise = 15*10^-3;

% List of first sample of detected vocalizations
% Get the sample stamp of the detected vocalizations
DataFileStruc = dir(fullfile(RawWav_dir, sprintf('%s_%s_%s*events.txt', Subj, Date, ExpStartTime)));
Fid_Data = fopen(fullfile(DataFileStruc.folder,DataFileStruc.name));
EventsHeader = textscan(Fid_Data, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n',1);
for hh=1:length(EventsHeader)
    if strfind(EventsHeader{hh}{1}, 'SampleStamp')
        EventsStampCol = hh;
    elseif strfind(EventsHeader{hh}{1}, 'Type')
        EventsEventTypeCol = hh;
    elseif strfind(EventsHeader{hh}{1}, 'Delay2Reward')
        EventsRewardCol = hh;
    end
end
Events = textscan(Fid_Data, '%s\t%f\t%s\t%s\t%f\t%f\t%f');
fclose(Fid_Data);
VocId = find(strcmp('Vocalization', Events{EventsEventTypeCol}));
FullStamps = Events{EventsStampCol}(VocId);
Time2Reward = Events{EventsRewardCol}(VocId);

% initialize variables
NVoc = length(VocId);
Voc_samp_idx = nan(NVoc,2);
Re_samp_idx = nan(NVoc,1);
Re_transc_time = nan(NVoc,1);
Time2re = nan(NVoc,1);


% Get the duration of all raw recordings
Length_Y = get_raw_file_length(RawWav_dir, Subj, Date, ExpStartTime);

% We choose to have 2s of recording before and after sound detection
% onset/offset
% to better localize the vocalization
Buffer_s = 2;

% design filters of raw ambient recording, bandpass and low pass which was
% used for the cross correlation
FS = 192000;
[z,p,k] = butter(6,[1000 90000]/(FS/2),'bandpass');
sos_raw_band = zp2sos(z,p,k);

% We choose to have Buffer_cut s of recording before and after the vocalization
% onset/offset
% to better isolate the vocalization
Buffer_cut = 0.2;
Fhigh_power =50; % Frequency upper bound for calculating the envelope (time running RMS)
Fs_env = 50; % Sample freqency of the enveloppe Hz
AmpThreshPerc = 10/100; % Threshold of amplitude used to cut the extract around the vocalization (10% max)
Ind_ = strfind(FullStamps{end}, '_');
LastFile_Idx = str2double(FullStamps{end}(1:(Ind_-1)));
MeanStdAmpRawFile = nan(LastFile_Idx,2);%Threshold on amplitude used to localize peaks of amplitude
MeanStdAmpRawExtract = nan(NVoc,2);
File_Idx = nan(NVoc,1);

%% Loop through time stamps of detected vocalizations
for ss=1:NVoc
    fprintf('-> Trigger %d/%d\n', ss, NVoc)
    Ind_ = strfind(FullStamps{ss}, '_');
    File_Idx(ss) = str2double(FullStamps{ss}(1:(Ind_-1)));
    Stamp_or = str2double(FullStamps{ss}((Ind_+1):end));
    if Stamp_or<0
        Stamp = 2*2147483647 + Stamp_or; % Correction of soundmexpro bug that coded numbers in 32 bits instead of 64bits
    else
        Stamp = Stamp_or;
    end
    
    % Make sure that stamp does not correspond to a call already saved
    Idx_Stamp_Y = Stamp - sum(Length_Y(1:(File_Idx(ss)-1)));
    Done = 0;
    for ii=1:(ss-1)
        if (Idx_Stamp_Y>Voc_samp_idx(ii,1)) && (Idx_Stamp_Y<Voc_samp_idx(ii,2)) 
            if ~(File_Idx(ss)==File_Idx(ii))
                keyboard
            else
                fprintf('Call already extracted!\n')
                if isnan(Re_samp_idx(ii)) && ~isnan(Time2Reward(ss)) % this is the first call of the sequence that got rewarded
                    % saving the time to get the reward for that vocalization
                    Re_samp_idx(ii) = Stamp - sum(Length_Y(1:(File_Idx(ss)-1))) + Time2Reward(ss)*FS;
                    Time2re(ii) = Time2Reward(ss);
                    if TranscTime
                        % Extract the transceiver time
                        % zscore the sample stamps
                        TTL_idx = find(unique(TTL.File_number) == File_Idx(ss));
                        if isempty(TTL_idx)
                            fprintf('Transceiver time calculations not possible for that vocalization\n')
                            Re_transc_time(ii) = NaN;
                        else
                            Re_samp_idx_zs = (Re_samp_idx(ii) - TTL.Mean_std_Pulse_samp_audio(TTL_idx,1))/TTL.Mean_std_Pulse_samp_audio(TTL_idx,2);
                            % calculate the transceiver times
                            Re_transc_time(ii) = TTL.Mean_std_Pulse_TimeStamp_Transc(TTL_idx,2) .* polyval(TTL.Slope_and_intercept{TTL_idx},Re_samp_idx_zs,[], TTL.Mean_std_x{TTL_idx}) + TTL.Mean_std_Pulse_TimeStamp_Transc(TTL_idx,1);
                        end
                        
                    end
                end
                
                Done = 1;
                break
            end
         end
     end
            

        
    

    
    if ~Done
        % Get the recording data for the corresponding sequence
        WavFileStruc_local = dir(fullfile(RawWav_dir, sprintf('%s_%s_%s*mic*_%d.wav',Subj, Date, ExpStartTime, File_Idx(ss))));
        try
            Wavefile_local = fullfile(WavFileStruc_local.folder, WavFileStruc_local.name);
            [Y,FS] = audioread(Wavefile_local);
            Buffer = Buffer_s*FS;
        catch
            fprintf(1,'Warning: the audiofile %s cannot be read properly!!\n', fullfile(RawWav_dir, sprintf('%s_%s_%s*mic*_%d.wav',Subj, Date, ExpStartTime, File_Idx(ss))));
            fprintf(1,'Data will not be retrieved\n')
            continue
        end
        
        if isnan(MeanStdAmpRawFile(File_Idx(ss),1)) % calculate the amplitude threshold for that file
            % Calculate the amplitude threshold as the average amplitude on the
            % first 30 seconds of that 10 min recording file from which that file
            % come from
            % Get the average running rms in a Dur_RMS min extract in the middle of
            % the recording
            fprintf(1, 'Calculating average RMS values on a %.1f min sample of silence\n',Dur_RMS);
            SampleDur = round(Dur_RMS*60*FS);
            StartSamp = round(length(Y)/2);
            fprintf(1,'Calculating the amplitude threshold for file %d  ',File_Idx(ss))
            BadSection = 1;
            while BadSection
                Filt_RawVoc = filtfilt(sos_raw_band,1,Y(StartSamp + (1:round(SampleDur))));
                Amp_env_Mic = running_rms(Filt_RawVoc, FS, Fhigh_power, Fs_env);
                if any(Amp_env_Mic>MicThreshNoise) % there is most likely a vocalization in this sequence look somewhere else!
                    StartSamp = StartSamp + SampleDur +1;
                else
                    BadSection = 0;
                end
            end
            MeanStdAmpRawFile(File_Idx(ss),1) = mean(Amp_env_Mic);
            MeanStdAmpRawFile(File_Idx(ss),2) = std(Amp_env_Mic);
            fprintf('-> Done\n')
        end
        MeanStdAmpRawExtract(ss,1)= MeanStdAmpRawFile(File_Idx(ss),1);
        MeanStdAmpRawExtract(ss,2)= MeanStdAmpRawFile(File_Idx(ss),2);
        
        
        
        
            
        Y_section_beg = max(1,Stamp - sum(Length_Y(1:(File_Idx(ss)-1))) - Buffer); % Make sure we don't request before the beginning of the raw wave file
        Y_section_end = min(length(Y), Stamp - sum(Length_Y(1:(File_Idx(ss)-1))) + Buffer); % Make sure we don't request after the end of the raw wave file
        Y_section = Y(Y_section_beg:Y_section_end);
        

        % calculate the envelpe of that extract and cut it Buffer_cut before/after points when the
        % enveloppe gets lower than AmpThreshPerc of the max
        % bandpass filter the ambient mic recording

        Filt_RawVoc = filtfilt(sos_raw_band,1,Y_section);
        Amp_env_Mic = running_rms(Filt_RawVoc, FS, Fhigh_power, Fs_env);
        InitialAmpFact = 50;
        PKs=[];
        while isempty(PKs) % try with a lower threshold
            [PKs,~] = findpeaks(Amp_env_Mic,Fs_env, 'MinPeakHeight', InitialAmpFact*MeanStdAmpRawFile(File_Idx(ss),1));% detect all the peaks in the amplitude envelope that are higher than twice the mean of the enveloppe
            InitialAmpFact = InitialAmpFact/2;
        end
        ThreshAmp = min(AmpThreshPerc*PKs); % Use for the threshold calculation the lowest of the peaks, ensuring that soft vocalizations are detected even if they are close to loud ones
        OnsetSamp = find(Amp_env_Mic>ThreshAmp,1, 'first');
        OffsetSamp = find(Amp_env_Mic>ThreshAmp,1, 'last');
        OnsetSamp_Ysection = max(1,round(OnsetSamp/Fs_env*FS - Buffer_cut*FS));
        OffsetSamp_Ysection = min(length(Y_section),round(OffsetSamp/Fs_env*FS + Buffer_cut*FS));

        Voc_samp_idx(ss,1) = Y_section_beg -1  + OnsetSamp_Ysection;
        Voc_samp_idx(ss,2) = Y_section_beg -1 + OffsetSamp_Ysection;
        
        
        % saving the time to get the reward for that vocalization
        Re_samp_idx(ss) = Stamp - sum(Length_Y(1:(File_Idx(ss)-1))) + Time2Reward(ss)*FS;
        Time2re(ss) = Time2Reward(ss);

        if TranscTime
            % Extract the transceiver time
            % zscore the sample stamps
            TTL_idx = find(unique(TTL.File_number) == File_Idx(ss));
            if isempty(TTL_idx)
                fprintf('Transceiver time calculations not possible for that vocalization\n')
                Re_transc_time(ss) = NaN;
            else
                Re_samp_idx_zs = (Re_samp_idx(ss) - TTL.Mean_std_Pulse_samp_audio(TTL_idx,1))/TTL.Mean_std_Pulse_samp_audio(TTL_idx,2);
                % calculate the transceiver times
                Re_transc_time(ss) = TTL.Mean_std_Pulse_TimeStamp_Transc(TTL_idx,2) .* polyval(TTL.Slope_and_intercept{TTL_idx},Re_samp_idx_zs,[], TTL.Mean_std_x{TTL_idx}) + TTL.Mean_std_Pulse_TimeStamp_Transc(TTL_idx,1);
            end
        end
    end
end

ExtractedSoundDetection = find(~isnan(Voc_samp_idx(:,1)));
Re_samp_idx = Re_samp_idx(ExtractedSoundDetection);
Re_transc_time = Re_transc_time(ExtractedSoundDetection);
Time2re =Time2re(ExtractedSoundDetection);
% OLD = load(fullfile(RawWav_dir, sprintf('%s_%s_VocExtractTimes.mat', Date, ExpStartTime)),'ExtractedSoundDetection');
 

%% save the calculation results
save(fullfile(RawWav_dir, sprintf('%s_%s_VocExtractTimes.mat', Date, ExpStartTime)),'Re_samp_idx', 'Time2re','-append')
if TranscTime
    save(fullfile(RawWav_dir, sprintf('%s_%s_VocExtractTimes.mat', Date, ExpStartTime)), 'Re_transc_time','-append')
end

end


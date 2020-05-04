% Converts vocal extraction data in .mat files into relevant .wav files,
% separating the audio by type. Writes into folder Z:\tobias\vocOperant\error_clips
% Files are saved in the format Date_Time_VocExtractData_RecordingIndex_Type(Log or Mic)_VocOrNoise_LogorMicStartIndex.wav

OutputDataPath = 'Z:\tobias\vocOperant\error_clips';
BaseDir = 'Z:\tobias\vocOperant';
BoxOfInterest = [3 4 6 8];

% Iterates through dates and audio recordings for hard-coded boxes
for bb=1:length(BoxOfInterest)
    fprintf(1,'**** Processing Box %d ****\n',BoxOfInterest(bb));
    DatesDir = dir(fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'piezo', '1*'));
    for dd=1:length(DatesDir)
        fprintf('    ** Date: %s **\n',DatesDir(dd).folder)
        wavsrc = dir(fullfile(DatesDir(dd).folder, DatesDir(dd).name,'audiologgers', '*_VocExtractData.mat'));
        fprintf(1,'%d experiments were found\n',length(wavsrc))
%         if (length(wavsrc) == length(indsrc)) && (~isempty(wavsrc))
            for ff=1:length(wavsrc)
                % find the corresponding file extracted by who_calls
                Date_ExpTime = wavsrc(ff).name(1:11);
                fprintf(1,'-> Processing experiment %s (%d/%d)\n',Date_ExpTime, ff,length(wavsrc))
                indsrc = dir(fullfile(DatesDir(dd).folder, DatesDir(dd).name,'audiologgers', sprintf('%s_VocExtractData_*',Date_ExpTime)));
                if isempty(indsrc)
                    % data not processed by who_calls
                    fprintf(1,'Data not processed by who_calls\n')
                    continue
                elseif length(indsrc)>1
                    error('expecting exactly one file!')
                end
                
                % Structure of Raw_wave: cell array, where each cell is one recording, and that
                % recording is a cell array of the signals. FS is signal frequency.
                load(fullfile(wavsrc(ff).folder,wavsrc(ff).name), 'Raw_wave','FS');

                % Each cell of IndVocStartRaw corresponds to a recording. For each recording, there
                % is a 2-cell array (1=logger; 2=mic), and the logger/mic each contain another cell
                % array with all of the start indices to be used on Raw_wave.
                load(fullfile(indsrc.folder,indsrc.name),  'IndVocStartRaw', 'IndVocStopRaw', 'IndNoiseStartRaw', 'IndNoiseStopRaw');

                % Create filter for mic signal
                [z,p,k] = butter(3,100/(FS/2),'high');
                sos_high_raw = zp2sos(z,p,k);

                % Extracts snippets specified by loaded-in variables (above) & saves as .WAV
                if isempty(Raw_wave)
                    fprintf(1,'Raw data not made available by who_calls\n')
                    continue
                else
                    fprintf(1, 'Found %d sequences\n',length(Raw_wave))
                    for vv=1:length(Raw_wave)
                        fprintf('treating sequence %d/%d\n', vv, length(Raw_wave))
                        WL = Raw_wave{vv};
                        if vv <= length(IndVocStartRaw) && ~isempty(IndVocStartRaw{vv})% && length(IndVocStartRaw{vv}) == length(IndNoiseStartRaw{vv})
                            type_list = ["log", "mic"];
                            v_n = ["voc", "noise"];
                            for Channeli=1:length(IndVocStartRaw{vv}) % for each channel (logger or microphone)
                                if isempty(IndVocStartRaw{vv}{Channeli}) && isempty(IndNoiseStartRaw{vv}{Channeli})
                                    % No sound detected on this channel for
                                    % this sequence
                                    continue
                                end
                                % convert with / 1000 * FS ??
                                starts_list = [IndVocStartRaw{vv}{Channeli}, IndNoiseStartRaw{vv}{Channeli}]; % This is a vector of all the onsets of sound extracts in the sequence vv
                                stops_list = [IndVocStopRaw{vv}{Channeli}, IndNoiseStopRaw{vv}{Channeli}];% This is a vector of all the offsets of sound extracts in the sequence vv
                                v_n_list = v_n([ones(length(IndVocStopRaw{vv}{Channeli}),1), 2*ones(length(IndNoiseStopRaw{vv}{Channeli}),1)]); % This is a string array indicating which of the soudns are vocalizations or noise
                                
                                % Get audio snippet, filter + center data, then write to file
                                for ii=1:length(v_n_list) % for each detected sound element
                                    snippet = WL(starts_list(ii):stops_list(ii));
                                    FiltWL = filtfilt(sos_high_raw, 1, snippet);
                                    FiltWL = FiltWL - mean(FiltWL);
                                    file_name = sprintf('%s__%d_%s_%s_%d.wav', wavsrc(ff).name(1:end-4), vv, type_list(Channeli), v_n_list(ii));
                                    audiowrite(fullfile(OutputDataPath, file_name), FiltWL, FS)
                                    
                                end
                            end
                        end
                    end
                end
            end
%         end
    end
end

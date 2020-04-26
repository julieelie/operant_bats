% Converts vocal extraction data in .mat files into relevant .wav files,
% separating the audio by type. Writes into folder Z:\tobias\vocOperant\error_clips

OutputDataPath = 'Z:\tobias\vocOperant\error_clips';
BaseDir = 'Z:\tobias\vocOperant';
BoxOfInterest = [3 4 6 8];
                
for bb=1:length(BoxOfInterest)
    DatesDir = dir(fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'piezo', '1*'));
    for dd=1:length(DatesDir)
        indsrc = dir(fullfile(DatesDir(dd).folder, DatesDir(dd).name,'audiologgers', '*_VocExtractData_*'));
        wavsrc = dir(fullfile(DatesDir(dd).folder, DatesDir(dd).name,'audiologgers', '*_VocExtractData.mat'));
        if (length(wavsrc) == length(indsrc))
        for ff=1:length(wavsrc)
            if (~isempty(wavsrc)) && (~isempty(indsrc))
                load(fullfile(wavsrc(ff).folder,wavsrc(ff).name), 'Raw_wave','FS');
                load(fullfile(indsrc(ff).folder,indsrc(ff).name),  'IndVocStartRaw', 'IndVocStopRaw', 'IndNoiseStartRaw', 'IndNoiseStopRaw');
                % Do we even need to save the clip names? Use this if yes:
                % clip_names = cell(sum(cellfun(@length,IndVocStartRaw)));
                % clip_names(vv * (length(IndVocStartRaw(vv)) - 1) + logger) = ...
                
                % Filter for the Mic signal
                [z,p,k] = butter(3,100/(FS/2),'high');
                sos_high_raw = zp2sos(z,p,k);
                
                for vv=1:length(Raw_wave)
                    WL = Raw_wave{vv};
                    
                    for log=1:length(IndVocStartRaw{vv})
                        % convert with / 1000 * FS ??
                        log_mic_starts = IndVocStartRaw{vv}{log};
                        log_mic_stops = IndVocStopRaw{vv}{log};
                        log_mic_starts_noise = IndNoiseStartRaw{vv}{log};
                        log_mic_stops_noise = IndNoiseStopRaw{vv}{log};
                        if (length(log_mic_starts) == length(log_mic_stops))
                            for ll=1:(length(log_mic_starts) - 1)
                                vocSnippet = WL(log_mic_starts(ll):log_mic_stops(ll));
                                % filter and center the data
                                vocFiltWL = filtfilt(sos_high_raw, 1, vocSnippet);
                                vocFiltWL = vocFiltWL - mean(vocFiltWL);
                                % get name and write to file
                                voc_name = sprintf('%s__%d_%d_%d.wav', wavsrc(ff).name(1:end-4), vv, log, ll);
                                audiowrite(fullfile(OutputDataPath, voc_name), vocSnippet, FS)
                            end
                        end
                        %repeat for IndNoiseStart/Stop
                        if (length(log_mic_starts_noise) == length(log_mic_stops_noise)) && ~isempty(log_mic_starts_noise)
                            for ll=1:(length(log_mic_starts_noise) - 1)
                                noiseSnippet = WL(log_mic_starts_noise(logger):log_mic_stops_noise(logger));
                                noiseFiltWL = filtfilt(sos_high_raw, 1, noiseSnippet);
                                noiseFiltWL = noiseFiltWL - mean(noiseFiltWL);
                                noise_name = sprintf('%s__%d_%d_%d.wav', wavsrc(ff).name(1:end-4), vv, log, ll);
                                audiowrite(fullfile(OutputDataPath, noise_name), noiseSnippet, FS)
                            end
                        end
                    end
                end
            end
        end
        end
    end
end

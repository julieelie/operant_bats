% Converts vocal extraction data in .mat files into relevant .wav files,
% separating the audio by type. Writes into folder Z:\tobias\vocOperant\error_clips
% Files are saved in the format Date_Time_VocExtractData_RecordingIndex_Type(Log or Mic)_LogorMicStartIndex.wav

OutputDataPath = 'Z:\tobias\vocOperant\error_clips';
BaseDir = 'Z:\tobias\vocOperant';
BoxOfInterest = [3 4 6 8];

% Iterates through dates and audio recordings for hard-coded boxes
for bb=1:length(BoxOfInterest)
    DatesDir = dir(fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'piezo', '1*'));
    for dd=1:length(DatesDir)
        indsrc = dir(fullfile(DatesDir(dd).folder, DatesDir(dd).name,'audiologgers', '*_VocExtractData_*'));
        wavsrc = dir(fullfile(DatesDir(dd).folder, DatesDir(dd).name,'audiologgers', '*_VocExtractData.mat'));
        if (length(wavsrc) == length(indsrc)) && (~isempty(wavsrc))
            for ff=1:length(wavsrc)
                % Structure of Raw_wave: cell array, where each cell is one recording, and that
                % recording is a cell array of the signals. FS is signal frequency.
                load(fullfile(wavsrc(ff).folder,wavsrc(ff).name), 'Raw_wave','FS');

                % Each cell of IndVocStartRaw corresponds to a recording. For each recording, there
                % is a 2-cell array (1=logger; 2=mic), and the logger/mic each contain another cell
                % array with all of the start indices to be used on Raw_wave.
                load(fullfile(indsrc(ff).folder,indsrc(ff).name),  'IndVocStartRaw', 'IndVocStopRaw', 'IndNoiseStartRaw', 'IndNoiseStopRaw');

                % Create filter for mic signal
                [z,p,k] = butter(3,100/(FS/2),'high');
                sos_high_raw = zp2sos(z,p,k);

                % Extracts snippets specified by loaded-in variables (above) & saves as .WAV
                if ~isempty(Raw_wave)
                    for vv=1:length(Raw_wave)
                        WL = Raw_wave{vv};
                        if (~isempty(IndVocStartRaw)) && length(IndVocStartRaw{vv}) == length(IndNoiseStartRaw{vv})
                            for log=1:length(IndVocStartRaw{vv}) % for each vocalization
                                % convert with / 1000 * FS ??
                                starts_list = [IndVocStartRaw{vv}{log}, IndNoiseStartRaw{vv}{log}];
                                stops_list = [IndVocStopRaw{vv}{log}, IndNoiseStopRaw{vv}{log}];
                                type_list = ["mic", "log"];
                                v_n = ["noise", "voc"];

                                % Get audio snippet, filter + center data, then write to file
                                for ii=1:length(type) % for both inputs (logger and mic)
                                    if (length(starts) == length(stops)) && ~isempty(starts):
                                        for ss=1:length(starts): % for noise and voc indices
                                        starts = starts_list{ss};
                                        stops = stops_list{ss};
                                            for ll=1:length(starts) % for indices in noise and voc lists
                                                snippet = WL(starts(ll):stops(ll));
                                                FiltWL = filtfilt(sos_high_raw, 1, snippet);
                                                FiltWL = vocFiltWL - mean(FiltWL);
                                                file_name = sprintf('%s__%d_%s_%s_%d.wav', wavsrc(ff).name(1:end-4), vv, type_list(ii), v_n(ss), ll);
                                                audiowrite(fullfile(OutputDataPath, file_name), snippet, FS)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

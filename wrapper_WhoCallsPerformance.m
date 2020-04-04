% Copies all vocal extraction data from labelled recordings into new folder.
OutputDataPath = 'Z:\tobias\vocOperant\VocCorrections';
BaseDir = 'Z:\tobias\vocOperant';
BoxOfInterest = [3 4 6 8];

MicErrors = cell(1000,1);
MicErrorTypes = cell(1000,1);
PiezoErrors = cell(1000,1);
PiezoErrorTypes = cell(1000,1);
ii = 1;
for bb=1:length(BoxOfInterest)
    DatesDir = dir(fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'piezo', '1*'));
    for dd=1:length(DatesDir)
        filesrc = dir(fullfile(DatesDir(dd).folder, DatesDir(dd).name,'audiologgers', '*_VocExtractData_*'));
        for ff=1:length(filesrc)
            if ~isempty(filesrc)
                load(fullfile(filesrc(ff).folder,filesrc(ff).name), 'MicError', ...
                    'MicErrorType', 'PiezoError', 'PiezoErrorType')
                if exist('MicError', 'var') && exist('MicErrorType', 'var') && ...
                        exist('PiezoError', 'var') && exist('PiezoErrorType', 'var')
                    MicErrors{ii} = MicError;
                    MicErrorTypes{ii} = MicErrorType;
                    PiezoErrors{ii} = PiezoError;
                    PiezoErrorTypes{ii} = PiezoErrorType;
                    ii = ii + 1;
                    clear MicError;
                    clear MicErrorType;
                    clear PiezoError;
                    clear PiezoErrorType;
                end
            end
        end
    end
end

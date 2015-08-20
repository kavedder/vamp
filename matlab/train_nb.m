clear;

% format of the .lab files
fspec = '%f %*d %s';
% initials of all the speakers, used in paths
names = ['awb'; 'bdl'; 'clb'; 'jmk'; 'ksp'; 'rms'; 'slt'];
% current index of FEATURES and LABELS
idx = 1;
% splay is the area around the current point in time
% that we'll look at the formants of
% if current_seconds = 1.2 and splay = .03, then
% start = 1.17 and end = 1.23
splay = .06;
% a list of what I assume to be vowel sounds
% since all we're doing is finding formants, this is really
% only a valid vowel detector :-(
% TODO: someday maybe work on recognizing consonants?
vowels = {'aa' 'ae' 'ah' 'ao' 'aw' 'ay' 'ey' 'iy' 'ow' 'oy' 'uh' 'uw'};

for name_i = 1:length(names)
    % start a timer
    tic
    name = names(name_i, :);
    disp(name);
    % get a path to the wav files and corresponding label files
    % for this particular person
    wavfipath = sprintf('../cmu_data/cmu_us_%s_arctic/wav/', name);
    labfipath = sprintf('../cmu_data/cmu_us_%s_arctic/lab/', name);

    % get a list of all the files in the wav directory
    wavfiles = dir(wavfipath);
    for file = wavfiles'
        % . and .. are current directory and prev directory
        if strcmp(file.name, '.')
            continue
        elseif strcmp(file.name, '..')
            continue
        end
        wavfile = file.name;
        labfile = strrep(wavfile, 'wav', 'lab');
        fileID = fopen([labfipath labfile], 'r');
        % read in the .lab file, skipping the first line
        [vl, len] = textscan(fileID,fspec,'HeaderLines',1);
        vals = vl{1};
        labels = vl{2};
        fclose(fileID);
        % read in the wav file
        [dat, Fs] = audioread([wavfipath wavfile]);
        for i = 1:length(vals)
            phon = labels(i);
            % if this isn't a vowel, move to the next item in the list
            if ~any(ismember(vowels, phon))
                continue
            end
            
            % now work on the audio data
            secs = vals(i);
            % use LPC to get formants
            [formants, audio] = find_formants(dat, Fs, secs, splay);
            % limit to F1 and F2
            formants = formants(1:2);
            % real vowel measurements have some limits...
            if (formants(2) > 0) && (formants(2) < 2500) && (formants(1) < 1000)
                FEATURES(idx, :) = formants;
                % add to the list of labels
                LABELS(idx, :) = phon;
                idx = idx + 1;
            end
        end
    end
    % stop timer
    toc
end

% save feats and labels to files
save('features.mat', 'FEATURES');
save('labels.mat', 'LABELS');

% create a Naive Bayes model
NBModel = fitNaiveBayes(FEATURES, LABELS);
% save the model to a .mat file so we can just load it later
save('nb_model.mat', 'NBModel');
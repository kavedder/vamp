% reseed the random number generator
rng('shuffle')
% read in the labels and features
labels_struct = load('labels.mat');
features_struct = load('features.mat');
labels = labels_struct(1).LABELS;
features = features_struct(1).FEATURES;
% make sure they're the same length
len_labels = length(labels);
len_features = length(features);
assert(len_labels == len_features);
% get 10% of this for testing
% it's not a true test, as we used it in training, but close enough
test_len = round(.1*len_features);
% get random indices
r = randi([1 test_len],1,test_len);
% create test labels and features
for ri = 1:test_len
    r_idx = r(ri);
    test_labels(ri, :) = labels(r_idx, :);
    test_feats(ri, :) = features(r_idx, :);
end 

% read in the model
NB_struct = load('nb_model.mat');
NB = NB_struct(1).NBModel;

% generate predictions
predictions = predict(NB, test_feats);

% convert to matrices
pm = cell2mat(predictions);
tm = cell2mat(test_labels);

% which of these were correct?
correct = (pm == tm);
num_correct = 0;
for i = 1:length(correct)
    if correct(i, 1) == 1 && correct(i, 2) == 1
        num_correct = num_correct + 1;
    end
end

pc_correct = num_correct / test_len * 100;
fprintf('Identified vowels with %f%% accuracy\n', pc_correct);

num_labels = length(unique(test_labels));
pc_correct_rand_guess = 100 / num_labels;
fprintf('There are %d labels, meaning roughly a %f%% at a random guess\n', num_labels, pc_correct_rand_guess);
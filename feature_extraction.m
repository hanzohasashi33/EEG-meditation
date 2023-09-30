%go to folder with matfiles of preprocessed data
cd 'C:\Users\PRASANNA\Desktop\sem9\eeg_project\osfstorage-archive-scripts\matlab_variables\'
files = dir('*.mat');
threshold = [-100,100]; %define amplitude threshold to reject epochs


freq = unique(2:0.5:30); %frequencies
no_wavelets = 6; %select number of wavelets
boundary = 1/min(freq)*no_wavelets/2; % exclude edges of epochs

featureIdx = 1;

stats = [];


% Epoch data, clean and get spectrum
for f = 1:size(files,1)
    clearvars EEG stats;


    % check if it is a meditator file
    if contains(files(f).name, 'med')
        disp(files(f).name);
        load(files(f).name); %load invidual data



        % Power calculation
        waveletFunction = 'sym8';
        for e = 1:19
            [C, L] = wavedec(EEG.data(e,:), 8, waveletFunction);
            %%Calculation The Coificients Vectors
            cD1 = detcoef(C,L,1);                   %NOISY
            cD2 = detcoef(C,L,2);                   %NOISY
            cD3 = detcoef(C,L,3);                   %NOISY
            cD4 = detcoef(C,L,4);                   %NOISY
            cD5 = detcoef(C,L,5);                   %GAMA
            cD6 = detcoef(C,L,6);                   %BETA
            cD7 = detcoef(C,L,7);                   %ALPHA
            cD8 = detcoef(C,L,8);                   %THETA
            cA8 = appcoef(C,L,waveletFunction,8);   %DELTA


            %%%%Calculation the Details Vectors
            D1 = wrcoef('d',C,L,waveletFunction,1); %NOISY
            D2 = wrcoef('d',C,L,waveletFunction,2); %NOISY
            D3 = wrcoef('d',C,L,waveletFunction,3); %NOISY
            D4 = wrcoef('d',C,L,waveletFunction,4); %NOISY
            D5 = wrcoef('d',C,L,waveletFunction,5); %GAMMA
            D6 = wrcoef('d',C,L,waveletFunction,6); %BETA
            D7 = wrcoef('d',C,L,waveletFunction,7); %ALPHA
            D8 = wrcoef('d',C,L,waveletFunction,8); %THETA
            A8 = wrcoef('a',C,L,waveletFunction,8); %DELTA

            % mean, variance, entropy, psd for GAMMA channel
            stats(e, 1) = mean(D5);
            stats(e, end + 1) = jVariance(D5);
            stats(e, end + 1) = jShannonEntropy(D5);
            stats(e, end + 1) = mean(pwelch(double(D5)));

            % mean, variance, entropy, psd for BETA channel
            stats(e, end + 1) = mean(D6);
            stats(e, end + 1) = jVariance(D6);
            stats(e, end + 1) = jShannonEntropy(D6);
            stats(e, end + 1) = mean(pwelch(double(D6)));

            % mean, variance, entropy, psd for ALPHA channel
            stats(e, end + 1) = mean(D7);
            stats(e, end + 1) = jVariance(D7);
            stats(e, end + 1) = jShannonEntropy(D7);
            stats(e, end + 1) = mean(pwelch(double(D7)));

            % mean, variance, entropy, psd for THETA channel
            stats(e, end + 1) = mean(D8);
            stats(e, end + 1) = jVariance(D8);
            stats(e, end + 1) = jShannonEntropy(D8);
            stats(e, end + 1) = mean(pwelch(double(D8)));
            

            % mean, variance, entropy, psd for DELTA channel
            stats(e, end + 1) = mean(A8);
            stats(e, end + 1) = jVariance(A8);
            stats(e, end + 1) = jShannonEntropy(A8);
            stats(e, end + 1) = mean(pwelch(double(A8)));
            
            
            
            
            % power of individual bands of the channels
            stats(e, end + 1) = (sum(D5.^2))/length(D5);
            stats(e, end + 1) = (sum(D6.^2))/length(D6);
            stats(e, end + 1) = (sum(D7.^2))/length(D7);
            stats(e, end + 1) = (sum(D8.^2))/length(D8);
            stats(e, end + 1) = (sum(A8.^2))/length(A8);

            % mean, entropy, variance of the channel
            stats(e, end + 1) = mean(EEG.data(e,:));
            stats(e, end + 1) = jShannonEntropy(EEG.data(e,:));
            stats(e, end + 1) = jVariance(EEG.data(e,:));
            stats(e, end + 1) = mean(pwelch(EEG.data(e,:)));

        end

        stats = stats(:)';
        if(startsWith(files(f).name, 'm'))
            features(featureIdx,:) = [stats 1];
        else
            features(featureIdx,:) = [stats 0];
        end
        featureIdx = featureIdx + 1;
    end
end





function ShEn = jShannonEntropy(X,~)
% Convert probability using energy
P    = (X .^ 2) ./ sum(X .^ 2);
% Entropy
En   = P .* log2(P);
ShEn = -sum(En);
end


function VAR = jVariance(X,~)
N   = length(X);
mu  = mean(X);
VAR = (1 / (N - 1)) * sum((X - mu) .^ 2);
end
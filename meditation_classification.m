data = features;
ns = size(data, 1);

% get the most important features
[idx,weights] = relieff(data(:, 1:end- 1),data(:,end), 10);

totalAcc = 0;

for i = 1:10
    cv = cvpartition(ns, 'HoldOut', 0.2);
    idxTrain = training(cv, 1);
    idxTest = test(cv, 1);
    traindata = data(idxTrain, :);
    testdata  = data(idxTest,  :);
    
    
    XTrain = traindata(:, 1: end-1);
    YTrain = traindata(:, end);
    XTest = testdata(:, 1:end-1);
    YTest = testdata(:, end);


% Original Model Labels
% disp('Original Labels');
% display(testdata(:, end)');


    lastIdx = 551;
    % XTrainUse = 1:551;
    % XTrainUse = idx(1:5);
    % XTrainUse = [1 4 5 8 9 12 13 16 17 20];
    XTrainUse = 1:4;

% SVM Model
    % SVMModel = fitcsvm(traindata(:, XTrainUse),traindata(:, end));
    % [label, ~] = predict(SVMModel, testdata(:, XTrainUse));
    % SVMAccuracy = nnz(label == testdata(:, end))/size(testdata(:,end), 1);
    % disp("SVM Model Results:");
    % display(label')
    % disp("SVM Model Accuracy:");
    % display(SVMAccuracy);


    %Naive Bayes Model
    % CNBModel = fitcnb(traindata(:, XTrainUse),traindata(:, end));
    % [label, ~] = predict(CNBModel, testdata(:, XTrainUse));
    % CNBAccuracy = nnz(label == testdata(:, end))/size(testdata(:,end), 1);
    % disp("CNB Model Results:");
    % display(label')
    % disp("CNB Model Accuracy:");
    % display(CNBAccuracy);

    nnetModel = fitcnet(traindata(:, XTrainUse),traindata(:, end));
    [label, ~] = predict(nnetModel, testdata(:,XTrainUse));
    NNAccuracy = nnz(label == testdata(:, end))/size(testdata(:,end), 1);

    totalAcc = totalAcc + NNAccuracy;
end

display(totalAcc/10);


% Nearest Neighbours Classifier Model
% KNNModel = fitcknn(traindata(:, XTrainUse),traindata(:, end),"ClassNames",{'0','1'});
% [label, ~] = predict(KNNModel, testdata(:, XTrainUse));
% disp('K Nearest Neighbours Classifier Results');
% display(label');


% Decision tree Classifier Model
% DecisionTreeModel = fitctree(traindata(:, XTrainUse),traindata(:, end));
% [label, ~] = predict(DecisionTreeModel, testdata(:, XTrainUse));
% DTAccuracy = nnz(label == testdata(:, end))/size(testdata(:,end), 1);
% disp('Decision Tree Classifier Results');
% display(label');
% disp("Decision Tree Model Accuracy:");
% display(DTAccuracy);

 

% Ensemble Classifier Model
% DecisionTreeModel = fitcensemble(traindata(:, XTrainUse),traindata(:, end));
% [label, ~] = predict(DecisionTreeModel, testdata(:, XTrainUse));
% EnsembleAccuracy = nnz(label == testdata(:, end))/size(testdata(:,end), 1);
% disp('Ensemble Classifier Results');
% display(label');
% disp("Ensemble Model Accuracy:");
% display(EnsembleAccuracy);
% 




% Neural Network Classifier Model
% nnetModel = fitcnet(traindata(:, XTrainUse),traindata(:, end));
% [label, ~] = predict(nnetModel, testdata(:,XTrainUse));
% NNAccuracy = nnz(label == testdata(:, end))/size(testdata(:,end), 1);
% disp('Neural Network Classifier Results');
% display(label');
% disp("Neural Network Accuracy:");
% display(NNAccuracy);


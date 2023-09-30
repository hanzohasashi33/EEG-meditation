data = features;
ns = size(data, 1);


cv = cvpartition(ns, 'KFold', 10);
idxTrain = training(cv, 1);
idxTest = test(cv, 1);
traindata = data(idxTrain, :);
testdata  = data(idxTest,  :);

% Original Model Labels
disp('Original Labels');
display(testdata(:, end)');

% SVM Model
SVMModel = fitcsvm(traindata(:, 1: end-1),traindata(:, end));
[label, ~] = predict(SVMModel, testdata(:, 1:end-1));
disp("SVM Model Results:");
display(label')


% Nearest Neighbours Classifier Model
KNNModel = fitcknn(traindata(:, 1: end-1),traindata(:, end),"ClassNames",{'0','1'});
[label, ~] = predict(KNNModel, testdata(:, 1:end-1));
disp('K Nearest Neighbours Classifier Results');
display(label');


% Decision tree Classifier Model
DecisionTreeModel = fitctree(traindata(:, 1: end-1),traindata(:, end));
[label, ~] = predict(DecisionTreeModel, testdata(:, 1:end-1));
disp('Decision Tree Classifier Results');
display(label');


% Logistic Regression Classifier Model
% LogisticRegressionModel = fitglm(traindata(:, 1: end-1),traindata(:, end));
% [label, ~] = predict(LogisticRegressionModel, testdata(:, 1:end-1));
% disp('Logistic Regression Classifier Results');
% display(label');


% Ensemble Classifier Model
DecisionTreeModel = fitcensemble(traindata(:, 1: end-1),traindata(:, end));
[label, ~] = predict(DecisionTreeModel, testdata(:, 1:end-1));
disp('Ensemble Classifier Results');
display(label');




% Neural Network Classifier Model
DecisionTreeModel = fitcnet(traindata(:, 1: end-1),traindata(:, end));
[label, ~] = predict(DecisionTreeModel, testdata(:, 1:end-1));
disp('Neural Network Classifier Results');
display(label');



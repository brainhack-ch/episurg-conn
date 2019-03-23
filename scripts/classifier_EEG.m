%% This code was written by Marion Curdy for the BrainHack event during Open Geneva

%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% This script tries to build a classifier to predict the outcome (good = 1/bad = 0)

% If you want to try SVM without selecting features beforehand
% SVMModel = fitcsvm(features,labels,'KernelFunction','rbf');
% CVSVMModel = crossval(SVMModel,'Leaveout','on');
% L=kfoldLoss(CVSVMModel);

% Initializing parameters
Data = features;
discrim_type = 'pseudolinear';
prior_type = 'uniform';
cp = cvpartition(labels,'kfold');

% Rank the features according to correlation score
[orderedInd,~] = rankfeat(Data,labels);

% Select the number of features we want to keep
n_sel = 300;

for fold = 1:cp.NumTestSets

        idx_train = find(training(cp,fold));

        idx_test = find(test(cp,fold));
        
        % Train the classifier
        classifier = fitcdiscr(Data(idx_train,orderedInd(1:n_sel)),labels(idx_train),'discrimtype',discrim_type,'Prior',prior_type);

        %classifier = fitcsvm(Data(idx_train,orderedInd(1:n_sel)),labels(idx_train));

        % Predict results
        training_predict = predict(classifier,Data(idx_train,orderedInd(1:n_sel)));

        testing_predict = predict(classifier,Data(idx_test,orderedInd(1:n_sel)));


        % Compute the error
        training_error(1,fold) = classerror(labels(idx_train),training_predict);

        testing_error(1,fold) = classerror(labels(idx_test),testing_predict);

            
end

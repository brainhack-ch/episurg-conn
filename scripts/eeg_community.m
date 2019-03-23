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

% This script builds a feature matrix from a PSD/PDC matrix, for alpha,
% beta, gamma and theta waves.

clear all; close all; clc;
% Put here the path were you data and your toolboxes are
path = 'D:\BRAINHACK_PROJECT05\eeg';
addpath('C:\Users\extra\Documents\BrainHack\fMRI\2019_03_03_BCT');

filePattern = fullfile(path, '*.mat');
files = dir(filePattern);
load('label_ROIs_internal.mat');

% Recover idx of brain waves we're interested in
    % Theta = 4-8Hz
    % Alpha = 8-13Hz, Alpha1 = 8-10Hz, Alpha2 = 10-13 Hz
    % Beta = 13-30Hz, Beta1 = 13-15Hz, Beta2 = 15-18Hz, Beta3 = 18-22Hz,Beta4 = 25-30Hz
    % Gamma = 30-40Hz
    
tmp=round(linspace(1,40,300)); % [1:40Hz]in 300 steps 

%indexes
idx_start_theta = find(tmp ==4,1,'first');
idx_end_theta = find(tmp ==8,1,'first');
idx_start_alpha = find(tmp ==8,1,'first');
idx_end_alpha = find(tmp ==13,1,'first');
idx_start_beta = find(tmp ==13,1,'first');
idx_end_beta = find(tmp ==30,1,'first');
idx_start_gamma = find(tmp ==30,1,'first');
idx_end_gamma = find(tmp ==40,1,'first');

% Change i with the number of patients you have
for i =1:10

    tic; load(files(i).name,'PSD'); toc;
    
% Creates the labels for the classification (good = 1, bad = 0)
    if  contains(files(i).name(1:2),'GO')
        labels(i,:) = 1;
    else
        labels(i,:) = 0;
    end

    % Remove the complex numbers
    PSD = abs(PSD).^2;
    
    % Average over time
    PSD_time = mean(PSC,4);
    clearvars PSC
    
    % Recover the wanted bands
    theta_mean = nanmean(PSD_time(:,:,idx_start_theta:idx_end_theta),3);
    alpha_mean = nanmean(PSD_time(:,:,idx_start_alpha:idx_end_alpha),3);
    beta_mean = nanmean(PSD_time(:,:,idx_start_beta:idx_end_beta),3);
    gamma_mean = nanmean(PSD_time(:,:,idx_start_gamma:idx_end_gamma),3);

   clearvars PSD_time

    % Construct the feature matrix.
    n = 1;
    for j = 1 : 72
        for k = j : 72
            if j ~= k

                features_theta(1,n) = theta_mean(j,k);
                labels_theta{1,n} = strcat('theta_',label_ROIs_internal{j}, '_', label_ROIs_internal{k});

                features_alpha(1,n) = alpha_mean(j,k);
                labels_alpha{1,n} = strcat('alpha_',label_ROIs_internal{j}, '_', label_ROIs_internal{k});

                features_beta(1,n) = beta_mean(j,k);
                labels_beta{1,n} = strcat('beta_',label_ROIs_internal{j}, '_', label_ROIs_internal{k});

                features_gamma(1,n) = gamma_mean(j,k);
                labels_gamma{1,n} = strcat('gamma_',label_ROIs_internal{j}, '_', label_ROIs_internal{k});

                n = n+1;
            end
        end
    end
    
    features(i,:) = [features_theta features_alpha features_beta features_gamma];
    labels_ROI(1,:) = [labels_theta labels_alpha labels_beta labels_gamma];


    clearvars features_theta features_alpha features_beta features_gamma theta_mean...
    alpha_mean beta_mean gamma_mean 

        

end

% Save the features matrix with all features for all subjects
save('features','features')
save('labels','labels');
save('labels_ROI','labels_ROI')


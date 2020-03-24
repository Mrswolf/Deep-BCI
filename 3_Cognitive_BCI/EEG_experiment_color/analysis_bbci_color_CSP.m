%% classify_try1�̶� ���� �ڵ� (�������� ���� ����)

clear all; close all; clc;
startup_bbci_toolbox();
dd = 'C:\Users\HANSEUL\Desktop\Analysis\Color\Converting\';
filelist = 'gh_no';
% filelist = 'gh_frequency';

%% Preprocessing cnt
[cnt, mrk, mnt]=eegfile_loadMatlab([dd filelist]); % Load cnt, mrk, mnt variables to Matlab

% Parameter setting
filtBank = [8 40];  % band pass filtering�� ���ļ� �뿪 ����
ival = [-200 5000]; % sampling rate�� 1000 �̹Ƿ� ��Ŀ ���� 2�ʸ� �߶�� �ϴϱ� 0~2000

% �ְ� ���� ä�� ����
%  subChannel = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, ...
%  24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64];
% subChannel = [57, 58, 25, 61, 62, 63, 29, 30, 31]; % ���־� ���ؽ�
%  subChannel = [8, 9. 10, 11, 13, 14, 15, 18, 19, 20, 21, 24, 25, 26, 43, 44, 47, 48, 49, 50, 52, 53, 54, 56, 57, 58, 59]

[cnt, mrk] =proc_resample(cnt, 100, 'mrk',mrk,'N',0);
%[cnt, mrk] =proc_resample(cnt, 100);


% IIR Filter (Band-pass filtering)
cnt = proc_filtButter(cnt, 2, filtBank);

% cnt = proc_commonAverageReference(cnt);
% Channel Selection
% cnt = proc_selectChannels(cnt, subChannel);

% MNT_ADAPTMONTAGE - Adapts an electrode montage to another electrode set
% mnt = mnt_adaptMontage(mnt, cnt);


%% cnt to epoch
epo = cntToEpo(cnt, mrk, ival);

% % ���̽����� ���ϰ� regularization�� ��� (���� -200�� 0���� �ٲٰ� ������)
% ival22 = [0 2000];
% epo = proc_baseline(epo, ival22);

% % -200ms�� �������� baseline correction
base = [-200 0];
epo = proc_baseline(epo, base);
%
ival2 = [0 5000];
epo = proc_selectIval(epo,ival2);

%% Ŭ���� ����

% ��ü Ŭ����
% epo_all = proc_selectClasses(epo, 'red', 'blue');
% epo_all = proc_selectClasses(epo, 'red', 'green');
epo_all = proc_selectClasses(epo, 'blue', 'green');
% epo_all = proc_selectClasses(epo, 'red', 'green', 'blue');
% epo_all = proc_selectClasses(epo, 'white','red', 'green', 'blue', 'yellow', 'cyan', 'magenta');



%% �� Ŭ������ 50Ʈ���̾� ��󳻱�

% % ����, �� Ŭ���� �� �� ���� Ʈ���̾��� �������� �����
% count_epo=sum(epo_all.y,2);
%
% % 88�� �̻��� �� �߶������
% y_temp = zeros(size(epo_all.y));
%
% for ci=1:size(y_temp,1)
%     cidx = find(epo_all.y(ci,:)==1);
%     cidx = cidx(1:50);
%     y_temp(:,cidx) = epo_all.y(:,cidx);
% end
%
% idx = find(sum(y_temp(:,:),1)==1);
% y = y_temp(:,idx);
% x = epo_all.x(:,:,idx);
%
% epo_all.x = x;
% epo_all.y = y;
%
% count_epo=sum(epo_all.y,2);

%% JH
% epo_jump = proc_jumpingMeans(epo_all, 20)
% [C_eeg, loss_eeg_std, out_eeg.out, memo] = xvalidation(epo_jump, 'RLDAshrink', 'kfold', 5);

%% Feature extraction - cross-validation
% basic multi-CSP
[csp_fv, csp_w, csp_eig] = proc_multicsp(epo_all, 3);
[csp_fv, csp_w, csp_eig] = proc_csp_regularised(epo_all, 4, 1); % regulized CSP
[csp_fv, csp_w] = proc_cspscp(epo_all, 2, 1); %CSP slow cortical potential variations
[csp_fv, csp_w, csp_eig, t_filter] = proc_csssp(epo_all, 2); % Common Sparse Spectrum Spatial Pattern
[csp_fv, csp_w] = proc_cspp_auto(epo_all); %auto csp patches, only for binary-class


proc= struct('memo', 'csp_w');  % CSP�� validation ���ο��� ���ƾ� ��, pattern ����: ä��/Ŭ����?
proc.train= ['[fv, csp_w]= proc_multicsp(fv,3); ' ...
    'fv= proc_variance(fv); ' ...
    'fv= proc_logarithm(fv);'];
proc.apply= ['fv= proc_linearDerivation(fv, csp_w); ' ...
    'fv= proc_variance(fv); ' ...
    'fv= proc_logarithm(fv);'];
%% Feature extraction - cross-validation
% % Bandpower
fv = proc_bandPower(epo_all, filtBank);
% CSP�� validation ���ο��� ���ƾ� ��, pattern ����: ä��/Ŭ����?
proc= struct();
proc.train= ['[fv]= proc_bandPower(fv, [8 40]);'];
proc.apply= ['[fv]= proc_bandPower(fv, [8 40]);'];
%%
% �з���: RLDAshrink / forest, 10 fold corss validation
[C_eeg, loss_eeg_std, out_eeg.out, memo] = xvalidation(epo_all, 'RLDAshrink', 'proc', proc, 'kfold', 10);



%% Result

figure('Name', 'CSP Patterns');
plotCSPatterns(fv, mnt, csp_w, fv.y)
% plotCSPatterns(fv, mnt, W, la);

% Result after cross validation = 1-error rate
Result = 1 - C_eeg;
Result_Std = loss_eeg_std;

% Cross-validation result
Result*100
Result_Std*100

% Confusion matrix result
[M, test_label] = max(out_eeg.out); % test label
[M, true_label] = max(epo_all.y); clear M;
n = size(epo_all.y, 1);

matrix_result = zeros(n, n);


for i = 1:size(test_label, 3)
    for j = 1:length(true_label)
        matrix_result(test_label(1, j, i), true_label(j)) = matrix_result(test_label(1, j, i), true_label(j)) + 1;
    end
end


matrix_result = (matrix_result / sum(matrix_result(:, 1)));
matrix_result = matrix_result * 100;
matrix_result = matrix_result'; % true: y��, predicted: x��


plotCSPatterns(fv, mnt, W, la);




%% EMG �з�-�н� using simple CNN 
% % 2019-07-18 by SuJin Bak
% We aim to compare classification rate between Rest state(0) and hand motion(1) using
% the EMG open data set provided by UCI.
% This is a tutorial showing the difference in 36 spectral powers.
% Reference: https://archive.ics.uci.edu/ml/datasets/EMG+data+for+gestures
% Accuracy: 

%clear all; clc;
% path: C:\Program Files\MATLAB\R2019a\toolbox\nnet\nndemos\nndatasets\EMG_Preprocessing
%���� ���� �����͸� �̹��� ����������ҷμ� �ҷ��ɴϴ�. 
digitDatasetPath = fullfile(matlabroot,'toolbox','nnet', ...
    'nndemos','nndatasets','EMG_Preprocessing');
%imageDatastore�� ���� �̸��� �������� �̹����� �ڵ����� ���̺��� �����ϰ�,�����͸� ImageDatastore ��ü�� �����մϴ�. 
%�̹��� ����������Ҹ� ����ϸ� �޸𸮿� ���� �� ���� �����͸� �����Ͽ� �ٷ��� �̹��� �����͸� ������ �� �ְ�,
%������� �Ű�� �Ʒ� �߿� �̹��� ��ġ�� ȿ�������� �о� ���� �� �ֽ��ϴ�.
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');

% ������ �̹��� ǥ��, ���� �ʿ����.
%figure;
%perm = randperm(36,4);
%for i = 1:4
%    subplot(2,2,i);
%    imshow(imds.Files{perm(i)});
%end


%�Ʒ� ��Ʈ�� �� ���ֿ� 5�� �̹����� ���Եǰ� ���� ��Ʈ�� �� ���̺��� ������ �̹����� ���Եǵ��� �����͸� �Ʒ� ������ ��Ʈ�� ���� ������ ��Ʈ�� �����ϴ�. 
%splitEachLabel�� ����������� digitData�� 2���� ���ο� ����������� trainDigitData�� valDigitData�� �����մϴ�.
numTrainFiles = 5;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

% ������� �Ű�� ��Ű��ó�� �����մϴ�.
%�̹��� �Է� ���� imageInputLayer�� �̹��� ũ�⸦ �����մϴ�. �� �������� �̹��� ũ��� 28x28x1�Դϴ�. �� ��ġ�� ����, �ʺ�, ä�� ũ�⿡ �����˴ϴ�. ���� �����ʹ� ȸ���� �̹����� �̷���� �����Ƿ� ä�� ũ��(�� ä��)�� 1�Դϴ�. �÷� �̹����� ��� ä�� ũ��� RGB ���� �����ϴ� 3�Դϴ�. trainNetwork�� �⺻������ �Ʒ��� ������ �� �����͸� ���� ������ �����͸� ���� ���� �ʾƵ� �˴ϴ�. trainNetwork�� �Ʒ� �߿� �� Epoch�� ������ ������ �����͸� �ڵ����� ���� ���� �ֽ��ϴ�.

%������� ���� ������� ������ ù ��° �μ��� filterSize�Դϴ�. 
%�̰��� �̹����� ���� ��ĵ�� �� �Ʒ� �Լ��� ����ϴ� ������ ���̿� �ʺ��Դϴ�. 
%�� �������� 3�� ���� ũ�Ⱑ 3x3���� ��Ÿ���ϴ�. ������ ���̿� �ʺ� �ٸ� ũ��� ������ �� �ֽ��ϴ�. 
%�� ��° �μ��� ������ ���� numFilters�Դϴ�. �̰��� �Է��� ������ ������ ����Ǵ� ������ �����Դϴ�.
%�� �Ķ���ʹ� Ư¡ ���� ������ �����մϴ�. 'Padding' �̸�-�� �� �μ��� ����Ͽ� �Է� Ư¡ �ʿ� ä��⸦ �߰��մϴ�. 
%����Ʈ ��Ʈ���̵尡 1�� ������� ������ ���, 'same' ä��⸦ ����ϸ� ���� ��� ũ�Ⱑ �Է� ũ��� �������ϴ�. 
%convolution2dLayer�� �̸� ��-�� �μ��� ����Ͽ� �� ������ ��Ʈ���̵�� �н����� ������ ���� �ֽ��ϴ�.
%��ġ ����ȭ ���� ��ġ ����ȭ ������ ��Ʈ��ũ ��ü�� ���ĵǴ� Ȱ��ȭ ���� ���⸦ ����ȭ�Ͽ�
%��Ʈ��ũ �Ʒ��� ���� ���� ����ȭ ������ ����� �ݴϴ�. ������� ������ ���� ����(ReLU ���� ��) ���̿� ��ġ ����ȭ ������ ����ϸ� ��Ʈ��ũ �Ʒ� �ӵ��� ���̰� ��Ʈ��ũ �ʱ�ȭ�� ���� �ΰ����� ���� �� �ֽ��ϴ�. ��ġ ����ȭ ������ batchNormalizationLayer�� ����Ͽ� ����ϴ�.
%ReLU ���� ��ġ ����ȭ ���� �ڿ��� ���� Ȱ��ȭ �Լ��� �ɴϴ�. ���� ���� ���Ǵ� Ȱ��ȭ �Լ��� ReLU(Rectified Linear Unit)�Դϴ�. ReLU ������ reluLayer�� ����Ͽ� ����ϴ�.
%�ִ� Ǯ�� ���� ������� ����(Ȱ��ȭ �Լ� ���)���� Ư¡ ���� ���� ũ�⸦ �ٿ� �ְ� �ߺ��� ���� ������ �����ϴ� �ٿ���ø� ������ �ڵ����� ��찡 �ֽ��ϴ�. �ٿ���ø��� �����ϸ� ������ �ʿ��� ���귮�� �ø��� �ʰ� ���� ������ ������� ������ �ִ� ���� ������ �ø� �� �ֽ��ϴ�. �ٿ���ø��� �����ϴ� �� ���� ����� �ִ� Ǯ���� maxPooling2dLayer�� ����Ͽ� ����ϴ�. �ִ� Ǯ�� ������ ù ��° �μ� poolSize�� ������ �Է°��� ��Ÿ���� ���簢�� ������ �ִ��� ��ȯ�մϴ�. �� �������� ���簢�� ������ ũ��� [2,2]�Դϴ�. 'Stride' �̸�-�� �� �μ��� �Ʒ� �Լ��� �Է°��� ���ʴ�� ��ĵ�� �� �����ϴ� ���� ũ�⸦ �����մϴ�.
%���� ���� ���� ������� ������ �ٿ���ø� ���� �ڿ��� �ϳ� �̻��� ���� ���� ������ �ɴϴ�. �̸����� �� �� �ֵ��� ���� ���� ������ �������� ���� ������ ��� ������ ����˴ϴ�. �� ������ ���� ������ �̹������� �н��� Ư¡���� �����Ͽ� ���� ū ������ �ĺ��մϴ�. ������ ���� ���� ������ Ư¡���� �����Ͽ� �̹����� �з��մϴ�. ���� ������ ���� ���� ������ OutputSize �Ķ���ʹ� ��ǥ �������� Ŭ���� ������ �����ϴ�. �� �������� ��� ũ��� 10���� Ŭ������ �����ϴ� 10�Դϴ�. ���� ���� ������ fullyConnectedLayer�� ����Ͽ� ����ϴ�.
%����Ʈ�ƽ� ���� ����Ʈ�ƽ� Ȱ��ȭ �Լ��� ���� ���� ������ ��°��� ����ȭ�մϴ�. ����Ʈ�ƽ� ������ ��°��� ���� 1�� ����� �����˴ϴ�. �� ���� �з� ������ ���� �з� Ȯ���� ���� �� �ֽ��ϴ�. ����Ʈ�ƽ� ������ softmaxLayer �Լ��� ����Ͽ� ������ ���� ���� ���� �ڿ� ����ϴ�.
%�з� ���� ������ ������ �з� �����Դϴ�. �� ������ ����Ʈ�ƽ� Ȱ��ȭ �Լ��� �� �Է°��� ���� ��ȯ�� Ȯ���� ����Ͽ� ��ȣ ��Ÿ���� Ŭ���� �� �ϳ��� �Է°��� �Ҵ��ϰ� �ս��� ����մϴ�. �з� ������ ������� classificationLayer�� ����Ͻʽÿ�.





layers = [
    imageInputLayer([656 875 3])  
    %imageInputLayer([266 330 3])  
    %imageInputLayer([366 480 3])
    %imageInputLayer([254 355 3])
    %imageInputLayer([241 355 3])
    %imageInputLayer([416 542 3])
    %imageInputLayer([416 542 3])
    %imageInputLayer([171 267 3])
    %imageInputLayer([488 670 3])
    
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
  
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

% �Ʒ� �ɼ� �����ϱ�
%SGDM(Stochastic Gradient Descent with Momentum: ������� ����� Ȯ���� ����ϰ���)�� ����Ͽ� �ʱ� �н��� 0.01 ��Ʈ��ũ�� �Ʒý�ŵ�ϴ�.
%�ִ� Epoch Ƚ���� 4(original version)�� �����մϴ�. Epoch 1ȸ�� ��ü �Ʒ� ������ ��Ʈ�� ���� �ϳ��� ������ �Ʒ� �ֱ⸦ �ǹ�. 
%���� �����Ϳ� ���� �󵵸� �����Ͽ� �Ʒ� �߿� ��Ʈ��ũ ��Ȯ���� ����͸��մϴ�. 
%�� Epoch���� �����͸� �����ϴ�. �Ʒ� �����Ϳ� ���� ��Ʈ��ũ�� �Ʒõǰ�, �Ʒ� �߿� ��Ģ���� �������� ���� �����Ϳ� ���� ��Ȯ���� ���˴ϴ�. 
%���� �����ʹ� ��Ʈ��ũ ����ġ�� ������Ʈ�ϴ� �� ������ �ʽ��ϴ�. �Ʒ� ���� ��Ȳ �÷��� �Ѱ� ��� â ����� ���ϴ�.
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, ...
    'MaxEpochs',100, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');


% �Ʒ� �����͸� ����Ͽ� ��Ʈ��ũ �Ʒý�Ű��
%layers�� ���� ���ǵ� ��Ű��ó, �Ʒ� ������ �� �Ʒ� �ɼ��� ����Ͽ� ��Ʈ��ũ�� �Ʒý�ŵ�ϴ�. 
%�⺻������ trainNetwork�� GPU�� ����� �� ������ GPU�� ����մϴ�(Parallel Computing Toolbox��� Compute Capability 3.0 �̻��� CUDA�� ���� GPU �ʿ�). 
%GPU�� ����� �� ������ CPU�� ����մϴ�. trainingOptions�� 'ExecutionEnvironment' �̸�-�� �� �μ��� ����Ͽ� ���� ȯ���� ������ ���� �ֽ��ϴ�.

%�Ʒ� ���� ��Ȳ �÷Կ� �̴� ��ġ�� �ս� �� ��Ȯ���� ������ �ս� �� ��Ȯ���� ǥ�õ˴ϴ�.
%�Ʒ� ���� ��Ȳ �÷Կ� ���� �ڼ��� ������ ���� �н� �Ʒ� ���� ��Ȳ ����͸��ϱ� �׸��� �����Ͻʽÿ�. 
%�ս��� ���� ��Ʈ���� �ս��Դϴ�. ��Ȯ���� ��Ʈ��ũ�� �ùٸ��� �з��� �̹����� �����Դϴ�.
net = trainNetwork(imdsTrain,layers,options);


%<���� �̹����� �з��ϰ� ��Ȯ�� ����ϱ�>
%�Ʒõ� ��Ʈ��ũ�� ����Ͽ� ���� �������� ���̺��� �����ϰ� ���� ���� ��Ȯ���� ����մϴ�. 
%��Ȯ���� ��Ʈ��ũ�� �ùٸ��� �����ϴ� ���̺��� �����Դϴ�. ���⼭�� ������ ���̺��� 99% �̻��� ���� ��Ʈ�� ��¥ ���̺�� ��ġ�մϴ�.
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

accuracy = sum(YPred == YValidation)/numel(YValidation);



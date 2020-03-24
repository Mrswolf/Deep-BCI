%% ���� raw data mat file�� �����ϴ� �ڵ� (�ּ� ���� ��, �������� ����)
% 3.15. �ݿ��� ��� �̰ɷ� ��ü convert��

clear all; close all; clc;

% ���� ��ġ (���)
dd = 'C:\Users\HANSEUL\Desktop\DoYeun\2019\analysis\';

% ���� �̸�
filelist={'gh_frequency'};

%%

% % ��Ŀ���� �̸� ���̱�

% stimDef= {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, ...
% 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, ...
% 17, 201, 202, 211, 212;
% 'imagine_Ambulance','imagine_Clock', 'imagine_Hello', 'imagine_Helpme', 'imagine_Light', 'imagine_Pain', 'imagine_Stop', 'imagine_Thankyou', 'imagine_Toilet', 'imagine_TV', 'imagine_Water', 'imagine_Yes', 'imagine_Rest', ...
% 'cue_Ambulance','cue_Clock', 'cue_Hello', 'cue_Helpme', 'cue_Light', 'cue_Pain', 'cue_Stop', 'cue_Thankyou', 'cue_Toilet', 'cue_TV', 'cue_Water', 'cue_Yes', 'cue_Rest', ...
% 'cross', 'totalstart', 'totalend', 'intervalstart', 'intervalend'};



% Scientific Reprot ����
stimDef= {1, 2, 3, 4, 5, 6, 7; 'white','red', 'green', 'blue', 'yellow', 'cyan', 'magenta'};

%%
for ff= 1:length(filelist),

file= filelist{ff};
opt= [];

fprintf('** In processing %s **\n', file);

% load the header file
try,
    hdr= eegfile_readBVheader([dd '\' file]);
catch
    fprintf('%s/%s not found.\n', dd, file);
continue;
end


%     % filtering with Chev filter
%     Wps= [42 49]/hdr.fs*2;
%     [n, Ws]= cheb2ord(Wps(1), Wps(2),3, 40);
%     [filt.b, filt.a]= cheby2(n, 50, Ws);


[cnt, mrk_orig]= eegfile_loadBV([dd '\' file]);%,'filt',filt);%,'clab',{'not','EMG*'});

% [cnt, mrk_orig]= eegfile_loadBV([dd '\' file], 'filt',filt,'clab',{'not','EMG*'}, 'fs' , 100);

cnt.title= ['C:\Users\HANSEUL\Desktop\DoYeun\2019\analysis\' file];

% create mrk and mnt
mrk= mrk_defineClasses(mrk_orig, stimDef);
mrk.orig= mrk_orig;

% Assign the channel montage information into mnt variable
mnt = getElectrodePositions(cnt.clab);

% Assign the sampling rate into fs_orig variable
fs_orig= mrk_orig.fs;

var_list= {'fs_orig',fs_orig, 'mrk_orig',mrk_orig, 'hdr',hdr};


% Convert the .eeg raw data file to .mat file
eegfile_saveMatlab(cnt.title, cnt, mrk, mnt, ...
'channelwise',1, ...
'format','int16', ...
'resolution', NaN);       

end

disp('All EEG Data Converting is Done!');
    
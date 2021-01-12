function eff_regressor(subID, session)

% Create physiological regressors

% comment to my dataset: atttention participants 12 and 10 14 16 need to be
% processed by their own because the physiology stops slighlty before the
% end of the last EPI acquisition

session = 'second'; %remove that when clusyer
%subj={subID};
displayPlot = 0;
%clc

dbstop if error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETTING THE PATH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define paths


cd ~
home = pwd;
homedir = [home '/OBIWAN'];

physiodir   = fullfile(homedir, '/SOURCEDATA/physio');
outdir = fullfile(homedir, '/DERIVATIVES/PHYSIO');

control = [homedir '/sub-control*'];
obese = [homedir '/sub-obese*'];

controlX = dir(control);
obeseX = dir(obese);

subj = vertcat(controlX, obeseX);
%subj = obeseX; 
addpath([homedir  '/CODE/ANALYSIS/PHYSIO'])

%subj={'control100'};%;'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26';}; %subID;
%physioID = {'s11'; 's13'; 's14'; 's15'; 's16'; 's17'; 's18'; 's20'; 's21'; 's22'; 's23'; 's24'; 's25'; 's26''s10'; 's11'; 's13'; 's14'; 's15'; 's16'; 's17'; 's18'; 's20'; 's21'; 's22'; 's23'; 's24'; 's25'; 's26'};
%10';'12';'14'; '16';


for i=1:length(subj)
    i = i+67; %do just 
    if i == 70
        break
    end
    %subjX = subj{i,1};
    %subjX=char(subjX); % subj{i,1}
    subjO = subj(i).name;
    subjO=char(subjO);
    %group = subjO(1:end-3);
    subjX = subjO(5:end);
    sub = subjO(end-2:end);
    
                    

    
     %load behavioral file
    if strcmp(session, 'third') %session third exceptions
        
        subjdir = fullfile(physiodir, subjX, ['ses-' session]);
        filename = ['2' sub '.acq'];
        %behav_file = [num2str(subjX) '_ses-' sessionX '_task-' taskX '_events.mat'];
        full_path = fullfile(subjdir, ['2' sub '.acq']);

    
        %missing trials
        %if strcmp(subjX(end-2:end), '201')  || strcmp(subjX(end-2:end), '214') 
            %continue
        %end

        %missing hedonic sess
        %if  strcmp(subjX(end-2:end), '208') || strcmp(subjX(end-2:end), '212') || strcmp(subjX(end-2:end), '245') || strcmp(subjX(end-2:end), '249')
            %continue
        %end
        if exist(full_path, 'file')
            cd (subjdir)
        else 
            continue
        end
    else   %session second exceptions
        subjdir = fullfile(physiodir, subjX, ['ses-' session]);
        filename = [sub '.acq'];
        %behav_file = [num2str(subjX) '_ses-' sessionX '_task-' taskX '_events.mat'];
        full_path = fullfile(subjdir, [sub '.acq']);

        %old structure
        %if strcmp(subjX(end-2:end), '101') || strcmp(subjX(end-2:end), '103')
            %continue
        %end

        if exist(full_path, 'file')
            cd (subjdir)
        else 
            continue
        end
    end
    
    disp (['****** PARTICIPANT: ' subjX ' **** session ' session ' ****' ]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % OPEN FILE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   
    physio = load_acq(filename); %load and transform acknoledge file
    %load('control100.mat')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % SET PARAMETERS ACCORDING TO THE SCANNER
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % ENTER VARIABLES PARAMETERS for the PIT
    SR = 500; % number of measures per sec
    TR = 2;

    grip_channel = 4; %
    suck_channel = 5; %
    MRI = 13; %
    %num_channel = 4; %channels of interest 

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % EXTRACT SIGNAL FOR TAPAS TOOLBOX AND SAVE INPUT VARIABLES
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Sycronize the physiological data to the MRI session %we can use EPI to check if the lenght is the same between physio recording and MRI scans 

    data = physio.data;
    
    %create new trigger channel %(CH28x1+CH29x2+CH30x4+CH31x8+CH32x16+CH33x32+CH34x64)/5
    data(:,16) = (data (:,6)*1+data (:,7)*2+data (:,8)*4+data (:,9)*8+data (:,10)*16+data (:,11)*32+data (:,12)*64)/5;
    
    %DO HED
    if find((data (:,16)) == 62, 1, 'first')
        start_HED = find((data (:,16)) == 62, 1, 'first'); % 62 is HED disctinctive trigger

        HED = data(start_HED-10000:length(data),:);
        start = find((HED (:,MRI)) == 5, 1, 'first'); % First MRI volume trigger start_INST = find((data (:,MRI_volumeALL)) == 5, 1, 'first'); % First MRI volume trigger
        fin_H = find((HED (:,MRI)) == 5, 1, 'last'); % + TR*sampling_rate; % First MRI volume trigger start_INST = find((data (:,MRI_volumeALL)) == 5, 1, 'first'); % First MRI volume trigger
        HED = HED(start:fin_H,:);

        data = data(1:start_HED-10001,:);
        
        save (['HED_' subjX '.mat'], 'HED');

        %EPI4 = get_N_scans(subjX, 'hedonicreactivity', session);
        %length(HED) - EPI4*TR*SR %check length - OK
    else 
        data = data(1:length(data),:);
    end
    
    if isempty(data)
        break
    end
    
    %DO PIT
    if find((data (:,16)) == 48, 1, 'first')
        start_PIT = find((data (:,16)) == 48, 1, 'first'); % 48 is PIT disctinctive trigger

        PIT = data(start_PIT-10000:length(data),:);
        start = find((PIT (:,MRI)) == 5, 1, 'first'); % First MRI volume trigger start_INST = find((data (:,MRI_volumeALL)) == 5, 1, 'first'); % First MRI volume trigger
        fin = find((PIT (:,MRI)) == 5, 1, 'last'); % + TR*sampling_rate; % First MRI volume trigger start_INST = find((data (:,MRI_volumeALL)) == 5, 1, 'first'); % First MRI volume trigger
        PIT = PIT(start:fin,:);
        data = data(1:start_PIT-10001,:);  

        save (['PIT_' subjX '.mat'], 'PIT');

        EPI3 = get_N_scans(subjX, 'PIT', session);
        %length(PIT) - EPI3*TR*SR %check length - OK
    
        ePIT = 1;
    else 
        data = data(1:length(data),:);
    end
    

    if isempty(data)
        break
    end
    
%     %DO PAV
%     if find((data(:,16)) == 5, 1, 'first')
%         start_PAV = find((data(:,16)) == 16, 1, 'first'); % 16 is PAV disctinctive trigger
% 
%         PAV = data(start_PAV-10000:length(data),:);
%         start = find((PAV (:,MRI)) == 5, 1, 'first'); % First MRI volume trigger start_INST = find((data (:,MRI_volumeALL)) == 5, 1, 'first'); % First MRI volume trigger
%         fin = find((PAV (:,MRI)) == 5, 1, 'last'); % + TR*sampling_rate; % First MRI volume trigger start_INST = find((data (:,MRI_volumeALL)) == 5, 1, 'first'); % First MRI volume trigger
%         PAV = PAV(start:fin,:);
% 
%         data = data(1:start_PAV-10001,:);
%         
%         %EPI2 = get_N_scans(subjX, 'pavlovianlearning', session);
%         %length(PAV) - EPI2*TR*SR %check length - OK
%         save (['PAV_' subjX '.mat'], 'PAV');
%     else 
%         data = data(1:length(data),:);
%     end
%     if isempty(data)
%         break
%     end
%     
%     
%     %DO INST
%     %if find((data(:,16)) == 7, 1, 'first')
%         start_INST = find((data(:,16)) == 7, 1, 'first'); % 7 is INST disctinctive trigger
% 
%         INST = data(start_INST-10000:length(data),:);
%         start = find((INST (:,MRI)) == 5, 1, 'first'); % First MRI volume trigger start_INST = find((data (:,MRI_volumeALL)) == 5, 1, 'first'); % First MRI volume trigger
%         fin = find((INST (:,MRI)) == 5, 1, 'last'); % + TR*sampling_rate; % First MRI volume trigger start_INST = find((data (:,MRI_volumeALL)) == 5, 1, 'first'); % First MRI volume trigger
%         INST = INST(start:fin,:);
%         
%         save (['INST_' subjX '.mat'], 'INST');
%         
%         EPI1 = get_N_scans(subjX, 'instrumentallearning', session);
% 
%         eINST = 1;
%     %else 
%         %data = data(1:length(data),:);
%     %end
%     %if data = []
%         %break
%     %end
%     
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CREATE AND SAVE THE EFFORT REGRESSOR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %PIT
    if ePIT
        mxEPI = (TR*SR); %n of physio point measure per EPI
        scanner_end = length(PIT);
        gripEPI = PIT(1:scanner_end,grip_channel); %exact length of the pyhsiological during the scanning session
        effort_reg = nan(length(EPI3),1);% initialize an empty vector
        cmpt = 1;

        for j= 1:EPI3
            %disp ([num2str(cmpt)]);
            if cmpt+mxEPI > length (gripEPI) % this should prevent matlab to crash if the physio is shorter than the scanning run
                x = length(gripEPI);
            else
                x = cmpt+mxEPI;
            end
            mean_effort = mean (gripEPI(cmpt:x));
            cmpt = cmpt+mxEPI;
            effort_reg (j) = mean_effort;
        end


        % save the reg as a file text in the participant directory
        fid = fopen('PIT_regressor_effort.txt','wt');
        for ii = 1:length(effort_reg)
            fprintf(fid,'%g\t',effort_reg(ii));
            fprintf(fid,'\n');
        end
        fclose(fid);
    end
    
    %PAV
    
%     if eINST
%         
%         mxEPI = (TR*SR); %n of physio point measure per EPI
%         scanner_end = length(PAV);
%         gripEPI = PAV(1:scanner_end,grip_channel); %exact length of the pyhsiological during the scanning session
%         effort_reg = nan (length(EPI2),1);% initialize an empty vector
%         cmpt = 1;
% 
%         for j= 1:EPI2
%             %disp ([num2str(cmpt)]);
%             if cmpt+mxEPI > length (gripEPI) % this should prevent matlab to crash if the physio is shorter than the scanning run
%                 x = length(gripEPI);
%             else
%                 x = cmpt+mxEPI;
%             end
%             mean_effort = mean (gripEPI(cmpt:x));
%             cmpt = cmpt+mxEPI;
%             effort_reg (j) = mean_effort;
%         end


%         % save the reg as a file text in the participant directory
%         fid = fopen('PAV_regressor_effort.txt','wt');
%         for ii = 1:length(effort_reg)
%             fprintf(fid,'%g\t',effort_reg(ii));
%             fprintf(fid,'\n');
%         end
%         fclose(fid);
%     end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DISPLAY PLOT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    num_channel = [4 5 9 10 13]; %channels of interest ??
    if displayPlot
        % Variable for Figure1
        Start = start_INST;
        End = fin_H;
            i = 0;
            % Figure run1
            figure
            for j = [4 5 13 16]
                i = i + 1;
                subplot(length(num_channel),1,i);
                plot(physio.data (Start:End,j));
                switch j
                    %case 1
                        %title('ACC1-X');
                    case 4
                        title ('Handgrip');
                    case 5
                        title('Licking');
                    case 13
                        title('MRI Volume');
                    case 16
                        title('Triggers');
                end
            end
        end

end 
    
end


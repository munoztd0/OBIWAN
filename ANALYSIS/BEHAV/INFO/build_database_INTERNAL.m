%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD DATABASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% created by Eva
% last modified by David on JULY 2020

% note: this scripts works only on participants who followed the full
% protocol 

dbstop if error
clear all

analysis_name = 'OBIWAN_INTERNAL';
task          = 'internal';
%% DEFINE WHAT WE WANT TO DO

save_Rdatabase = 1; % leave 1 when saving all subjects

%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/OBIWAN/'];


analysis_dir = fullfile(homedir, 'ANALYSIS/BEHAV/INTERN');
R_dir        = fullfile(homedir,'DERIVATIVES/BEHAV');
% add tools
addpath (genpath(fullfile(homedir, 'CODE/ANALYSIS/BEHAV/matlab_functions')));

%% DEFINE POPULATION

control = [homedir '/SOURCEDATA/behav/control*'];
obese = [homedir '/SOURCEDATA/behav/obese*'];

controlX = dir(control);
obeseX = dir(obese);

subj = vertcat(controlX, obeseX);

session = {'second';'third'};


%subj    = {'101'};     % subject ID
%group   = {'control'}; % control or obsese
%session = {'second'};

k = 0; %counter for database index

for j = 1:length(session)
    
    for i = 1:length(subj)

        %subjX=subj(i,1);
        subjX = subj(i).name;
        subjX=char(subjX);
        group = subjX(1:end-3);
        sub = subjX(end-2:end);
        %conditionX=char(group(i,1));
        sessionX=char(session(j)); 
        sess=['ses-' sessionX];


        %load behavioral file
        if strcmp(sessionX, 'third') %session third exceptions
                
            %missing trials
%             if strcmp(subjX(end-2:end), '201')  || strcmp(subjX(end-2:end), '214') 
%                 continue
%             end
            
            %missing hedonic sess
%             if  strcmp(subjX(end-2:end), '208') || strcmp(subjX(end-2:end), '212') || strcmp(subjX(end-2:end), '245') || strcmp(subjX(end-2:end), '249')
%                 continue
%             end
            
            dataN.Piss = NaN;
            dataN.Thirsty = NaN;
            dataN.Hungry = NaN;
            
            behavior_dir = fullfile(homedir,'/SOURCEDATA/behav/', num2str(subjX), sess);
            
            if exist(behavior_dir, 'dir')
                cd (behavior_dir)
                if exist(['internal1_2' subjX(end-2:end) '.mat' ], 'file')
                    load (['internal1_2' subjX(end-2:end) ])
                    internal1 = data;
                else
                    internal1 = dataN;
                end
                if exist(['internal3_2' subjX(end-2:end) '.mat' ], 'file')
                    load (['internal3_2' subjX(end-2:end) ])
                    internal3 = data;
                else
                    internal3 = dataN;
                end
                if exist(['internal5_2' subjX(end-2:end) '.mat' ], 'file')
                    load (['internal5_2' subjX(end-2:end) ])
                    internal5 = data;
                else
                    internal5 = dataN;
                end
                if exist(['internal7_2' subjX(end-2:end) '.mat' ], 'file')
                    load (['internal7_2' subjX(end-2:end) ])
                    internal7 = data;
                else
                    internal7 = dataN;
                end
                if exist(['internal9_2' subjX(end-2:end) '.mat' ], 'file')
                    load (['internal9_2' subjX(end-2:end) ])
                    internal9 = data;
                else
                    internal9 = dataN;
                end
            else 
                continue
            end
        else   %session second exceptions
            
            %old structure
            if strcmp(subjX(end-2:end), '101') || strcmp(subjX(end-2:end), '103')
                continue
            end

            %missing trials
%             if strcmp(subjX(end-2:end), '123') || strcmp(subjX(end-2:end), '124') || strcmp(subjX(end-2:end), '234')
%                 continue
%             end

            %missing hedonic sess
%             if strcmp(subjX(end-2:end), '212')
%                 continue
%             end
        
            behavior_dir = fullfile(homedir,'SOURCEDATA/behav/', num2str(subjX), sess);
            
            dataN.Piss = NaN;
            dataN.Thirsty = NaN;
            dataN.Hungry = NaN;
            
            if exist(behavior_dir, 'dir')
                cd (behavior_dir)
                if exist(['internal1_' subjX(end-2:end) '.mat' ], 'file')
                    load (['internal1_' subjX(end-2:end) ])
                    internal1 = data;
                else
                    internal1 = dataN;
                end
                if exist(['internal3_' subjX(end-2:end) '.mat' ], 'file')
                    load (['internal3_' subjX(end-2:end) ])
                    internal3 = data;
                else
                    internal3 = dataN;
                end
                if exist(['internal5_' subjX(end-2:end) '.mat' ], 'file')
                    load (['internal5_' subjX(end-2:end) ])
                    internal5 = data;
                else
                    internal5 = dataN;
                end
                if exist(['internal7_' subjX(end-2:end) '.mat' ], 'file')
                    load (['internal7_' subjX(end-2:end) ])
                    internal7 = data;
                else
                    internal7 = dataN;
                end
                if exist(['internal9_' subjX(end-2:end) '.mat' ], 'file')
                    load (['internal9_' subjX(end-2:end) ])
                    internal9 = data;
                else
                    internal9 = dataN;
                end
            else 
                continue
            end
        end
        
        disp (['****** PARTICIPANT: ' subjX ' **** session ' sessionX ' ****' ]);

        k = k +1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  get onsets

%         ONSETS.Hungry  = data.Onsets.Hungry; 
%         ONSETS.Thirsty      = data.Onsets.Thirsty; 
%         ONSETS.Piss       = data.Onsets.Piss;
%       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  get durations
%         DURATIONS.Hungry  = data.Durations.Hungry;
%         DURATIONS.Thirsty      = data.Durations.Thirsty;
%         DURATIONS.Piss       = data.Durations.Piss;
%         
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% concatenate
        
        BEHAVIOR.Piss = [internal1.Piss internal3.Piss internal5.Piss internal7.Piss internal9.Piss]';
        BEHAVIOR.Thirsty = [internal1.Thirsty internal3.Thirsty internal5.Thirsty internal7.Thirsty internal9.Thirsty]';
        BEHAVIOR.Hungry = [internal1.Hungry internal3.Hungry internal5.Hungry internal7.Hungry internal9.Hungry]';
        
        ntrials = length(BEHAVIOR.Hungry);
        %cHeader = {'Piss'; 'Thirsty'; 'Hungry'; 'BIC'; 'LME'};
        
%         %write header to file
%         fid = fopen([glm '.csv'],'w'); 
%         fprintf(fid,'%s\n',textHeader)
%         fclose(fid)
% 
%         %write data to end of file
%         dlmwrite([glm '.csv'],data,'-append');
%         
    

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% save mat file
        func_dir = fullfile (homedir, 'DERIVATIVES', 'PREPROC', ['sub-'  num2str(subjX)], ['ses-' sessionX], 'func');
        bids_dir = fullfile (homedir, ['sub-'  num2str(subjX)], ['ses-' sessionX], 'func');

        if ~exist(func_dir, 'dir')
            mkdir(func_dir)
        end 
        
        cd (func_dir)
        matfile_name = ['sub-'  num2str(subjX) '_ses-' sessionX '_task-' task '_events.mat'];
        %cd (behavior_dir)
        save(matfile_name,'BEHAVIOR') %, 'ODOR', 'TRIAL', 'DRIFT', 'PHYSIO' )

% 
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%% save tvs file according to BIDS format
%         phase = {'trialstart';'liquid';'liking'; 'intensity';'familiarity'; 'rince'; 'ITI'};
%         nevents = ntrials*length(phase);
% 
%         % put everything in the event structure
%         events.onsets       = zeros(nevents,1);
%         events.durations    = zeros(nevents,1);
%         events.phase        = cell (nevents,1);
%         events.condition    = cell (nevents,1);
%         events.liking       = nan (nevents,1);
%         events.intensity    = nan (nevents,1);
%         events.familiarity  = nan (nevents,1);
% 
% 
%         cmpt = 0;
%         for ii = 1:ntrials
% 
%             for iii = 1:length(phase)
% 
%                 cmpt = cmpt+1;
%                 phaseX = char(phase(iii));
% 
%                 events.onsets(cmpt)     = ONSETS.(phaseX) (ii);
%                 events.durations(cmpt)  = DURATIONS.(phaseX) (ii);
%                 events.phase(cmpt)      = phase (iii);
%                 events.condition(cmpt) = CONDITIONS(ii);
%                 events.liking(cmpt)     = BEHAVIOR.liking(ii);
%                 events.familiarity(cmpt)= BEHAVIOR.familiarity(ii);
%                 events.intensity(cmpt)  = BEHAVIOR.intensity(ii);
% 
%             end
% 
%         end

%         events.onsets       = num2cell(events.onsets);
%         events.durations    = num2cell(events.durations);
%         events.liking       = num2cell(events.liking);
%         events.familiarity  = num2cell(events.familiarity);
%         events.intensity    = num2cell(events.intensity);
% 
% 
% 
%          eventfile = [events.onsets, events.durations, events.phase,...
%          events.condition, events.liking, events.familiarity, events.intensity];
%         
%         cd (bids_dir)
%         
%         % open data base
%         eventfile_name = ['sub-'  num2str(subjX) '_ses-' sessionX '_task-' task '_run-01_events.tsv'];
%         fid = fopen(eventfile_name,'wt');
% 
%          % print heater
%         fprintf (fid, '%s   %s   %s   %s   %s   %s   %s\n',...
%             'onset', 'duration', 'trialPhase',...
%             'condition','perceived_liking','perceived_familiarity','perceived_intesity');
% 
%         % print data
%         formatSpec = '%d   %d   %s   %s  %d  %d  %d \n';
%         [nrows,ncols] = size(eventfile);
%         for row = 1:nrows
%             fprintf(fid,formatSpec,eventfile{row,:});
%         end

%         fclose(fid);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% save data for compiled database

        db.id(:,k)           = cellstr(repmat(sub,ntrials, 1));
        db.group(:,k)        = cellstr(repmat(group,ntrials, 1));
        db.session(:,k)      = cellstr(repmat(sessionX,ntrials,1));
        db.task(:,k)         = repmat({task},ntrials,1);
        db.phase(:,k)        = [1:ntrials]';
        db.Piss (:,k)      = BEHAVIOR.Piss;
        db.Thirsty (:,k) = BEHAVIOR.Thirsty;
        db.Hungry (:,k)   = BEHAVIOR.Hungry;

    end
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% SAVE RESULTS IN TXT for analysis in R


% random
R.id      = db.id(:);
R.phase   = num2cell(db.phase(:));

%fixe
R.group      = db.group(:);
R.session    = db.session(:);
R.task       = db.task(:);


% dependent variable
R.Piss      = num2cell(db.Piss(:));
R.Thirsty   = num2cell(db.Thirsty(:));
R.Hungry = num2cell(db.Hungry(:));


%% print the database
if save_Rdatabase
    cd (R_dir)
    % concatenate
    Rdatabase = [R.task, R.id, R.group, R.session, R.phase, R.Piss, R.Thirsty, R.Hungry];

    % open database
    fid = fopen([analysis_name '.txt'], 'wt');

    % print heater
    fprintf(fid,'%s   %s   %s   %s   %s   %s   %s   %s\n',...
        'task','id', 'group', ...
        'session','phase','piss','thirsty', 'hungry');

    % print data
    formatSpec ='%s   %s   %s   %s   %d  %d   %d   %d\n';
    [nrows,~] = size(Rdatabase);
    for row = 1:nrows
        fprintf(fid,formatSpec,Rdatabase{row,:});
    end

    fclose(fid);
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% CREATE FIGURE
% 
% for id = 1:length(subj)
%     
%     % get data for that participant
%     subjX=subj(id,1);
%     subjX=char(subjX);
%     
%     idx = strcmp(db.id, subjX);
%     
%     s.condition   = db.condition(idx);
%     s.liking      = db.liking(idx);
%     %s.familiarity = db.familiarity(idx);
%     s.intensity   = db.intensity(idx);
%     
%     ratings.liking.reward(id,:)      = s.liking (strcmp ('chocolate', s.condition));
%     ratings.liking.control(id,:)     = s.liking (strcmp ('empty', s.condition));
%     ratings.liking.neutral(id,:)     = s.liking (strcmp ('neutral', s.condition));
%    
%     %ratings.familiarity.reward(id,:) = s.familiarity (strcmp ('chocolate', s.condition));
%     %ratings.familiarity.control(id,:)= s.familiarity (strcmp ('empty', s.condition));
% 
%     ratings.intensity.reward(id,:)   = s.intensity (strcmp ('chocolate', s.condition));
%     ratings.intensity.control(id,:)  = s.intensity (strcmp ('empty', s.condition));
%     ratings.intensity.neutral(id,:)  = s.intensity (strcmp ('neutral', s.condition));
% 
%     
% end
% 
% % get means and std
% list = {'liking'; 'intensity'};
% 
% for ii = 1:length(list)
%     
%     conditionX = char(list(ii));
%     
%     means.(conditionX).reward = nanmean(ratings.(conditionX).reward,1);
%     means.(conditionX).control= nanmean(ratings.(conditionX).control,1);
%     means.(conditionX).neutral= nanmean(ratings.(conditionX).neutral,1);
%     
%     
%     stnd.(conditionX).reward = nanstd(ratings.(conditionX).reward,1)/sqrt(length(subj));
%     stnd.(conditionX).control= nanstd(ratings.(conditionX).control,1)/sqrt(length(subj));%eva, you put reward twice?
%     stnd.(conditionX).neutral= nanstd(ratings.(conditionX).neutral,1)/sqrt(length(subj));
%     
% end
% 
% 
% % plot the means and std
% figure;
% 
% set(gcf, 'Color', 'w')
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%% liking pannel
% subplot(3,1,1)
% 
% % reward
% forplot.liking.reward = plot(means.liking.reward,'-o');
% set(forplot.liking.reward(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
% hold
% % control
% forplot.liking.control= plot(means.liking.control,'--o');
% set(forplot.liking.control(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])
% 
% % neutral
% forplot.liking.neutral= plot(means.liking.neutral,'--o');
% set(forplot.liking.neutral(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.3 0.4 0.4],'MarkerEdgeColor', [0.3 0.7 0.7], 'Color', [0 0 0])
% 
% %axis
% xlabel('Trial', 'FontSize', 15)
% ylabel('Liking', 'FontSize', 18)
% ylim ([0 100])
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%% intesity pannel
% subplot(3,1,2)
% 
% % reward
% forplot.intensity.reward = plot(means.intensity.reward,'-o');
% set(forplot.intensity.reward(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
% hold
% % control
% forplot.intensity.control= plot(means.intensity.control,'--o');
% set(forplot.intensity.control(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])
% 
% % neutral
% forplot.intensity.neutral= plot(means.intensity.neutral,'--o');
% set(forplot.intensity.neutral(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.3 0.4 0.4],'MarkerEdgeColor', [0.3 0.7 0.7], 'Color', [0 0 0])
% 
% %axis
% xlabel('Trial', 'FontSize', 15)
% ylabel('Intensity', 'FontSize', 18)
% ylim ([0 100])
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%  familiarity pannel
% %subplot(3,1,3)
% 
% % reward
% %forplot.familiarity.reward = plot(means.familiarity.reward,'-o');
% %set(forplot.familiarity.reward(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
% %hold
% % control
% %forplot.familiarity.control= plot(means.familiarity.control,'--o');
% %set(forplot.familiarity.control(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])
% 
% %axis
% %xlabel('Trial', 'FontSize', 15)
% %ylabel('Familiarity', 'FontSize', 18)
% %ylim ([0 100])
% 
% %legend
% LEG = legend ('reward','control','neutral');  % 'neutral');
% set(LEG,'FontSize',18);
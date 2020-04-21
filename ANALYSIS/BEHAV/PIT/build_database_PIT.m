
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD DATABASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% created by Eva
% last modified by David on August 2020

%  rescued 101 and 103

dbstop if error
clear all

analysis_name = 'OBIWAN_PIT';
task          = 'PIT';
%% DEFINE WHAT WE WANT TO DO

save_Rdatabase = 1; % leave 1 when saving all subjects

%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/OBIWAN/'];


analysis_dir = fullfile(homedir, 'ANALYSIS/BEHAV/PIT');
R_dir        = fullfile(homedir,'DERIVATIVES/BEHAV');
% add tools
addpath (genpath(fullfile(homedir, 'CODE/ANALYSIS/BEHAV/matlab_functions')));

%% DEFINE POPULATION

control = [homedir 'SOURCEDATA/behav/control*'];
obese = [homedir 'SOURCEDATA/behav/obese*'];

controlX = dir(control);
obeseX = dir(obese);

subj = vertcat(controlX, obeseX);

session = {'second'; 'third'};
% 
% subj    = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};    % subject ID excluding 8 & 19
% session = {'two';'two';'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'; 'two'};
% 
% ses = {'ses-second'};
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
        if strcmp(sessionX, 'third')
            
            %missing trials
            if strcmp(subjX(end-2:end), '214')  
                continue
            end
            
            %missing PIT sess
            if  strcmp(subjX(end-2:end), '212')  || strcmp(subjX(end-2:end), '245') || strcmp(subjX(end-2:end), '249')
                continue
            end
            

            behavior_dir = fullfile(homedir,'SOURCEDATA/behav/', num2str(subjX), sess);
            if exist(behavior_dir, 'dir')
                cd (behavior_dir)
                load (['participant_2' subjX(end-2:end) ])
            else 
                continue
            end
        else
            
%             %old structure
%             if strcmp(subjX(end-2:end), '101') || strcmp(subjX(end-2:end), '103')
%                 continue
%             end

            %missing trials
            if strcmp(subjX(end-2:end), '110') || strcmp(subjX(end-2:end), '218') %|| strcmp(subjX(end-2:end), '234')
                continue
            end

            %missing PIT sess
            if strcmp(subjX(end-2:end), '212') || strcmp(subjX(end-2:end), '224')
                continue
            end
            
            behavior_dir = fullfile(homedir,'SOURCEDATA/behav/', num2str(subjX), sess);
            if exist(behavior_dir, 'dir')
                cd (behavior_dir)
                load (['participant_' subjX(end-2:end) ])
            else 
                continue
            end
        end
        
        
        disp (['****** PARTICIPANT: ' subjX ' **** session ' sessionX ' ****' ]);
        
        k = k +1;

        % get ntrials
        [a b c] = size(data.PIT.Time);
        ntrials = b*c;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  get onsets

        ONSETS.trial    = reshape(data.PIT.Onsets.StartTrial,1,ntrials)';
        ONSETS.ITI      = reshape(data.PIT.Onsets.ITI,1,ntrials)';

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  get durations
        DURATIONS.trial = reshape(data.PIT.Durations.TimeTrial',1,ntrials); 
        DURATIONS.ITI    = reshape(data.PIT.Durations.ITI',1,ntrials);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  get condition name
        
        %rescuing data from old structure #fffff
        if strcmp(subjX(end-2:end), '101') || strcmp(subjX(end-2:end), '103')
           %a = reshape(data.PIT.Image,ntrials,1);
            for f = 1:c
                for g = 1:b
                    x = data.PIT.Image{f,g};
                    data.PIT.Cond{f,g} = x(1:end-4);
                    if strcmp(data.PIT.Cond{f,g}, 'Baseli')
                        data.PIT.Cond{f,g} = 'BL';
                    elseif strcmp(data.PIT.Cond{f,g}, 'CSminu')
                        data.PIT.Cond{f,g} = 'CSminus';
                    end
                end
            end   
        end
        
        CS = '';
        cmp = 0;
        for ii = 1:c
            for n = 1:b
                cmp = cmp + 1;
                CS = data.PIT.Cond{ii,n};%first dimension of the matrix
                CONDITIONS.CS{cmp} = CS;
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% get the mobilized effort

        % concatenate the mobilized effort
        mobilized_effort = reshape(data.PIT.mobilizedforce,a,ntrials);


        % compute the treshold to determine what we consider as a response (50% of the maximal force)
        treshold = data.minimalforce+((data.maximalforce-data.minimalforce)/100*50);% value

        % extract the number of grips
        nlines = size(mobilized_effort,1);
        ncolons = size(mobilized_effort,2);
        BEHAVIOR.gripFreq = countgrips(treshold,nlines,ncolons,mobilized_effort);

        % extract the onset of each grip
        ONSETS.grips = gripsOnsets (treshold,nlines,ncolons,mobilized_effort,ONSETS.trial);

        % item by condition
        itemxc          = nan  (length(ntrials/3),1);
        count_CSp       = 0;
        count_CSm       = 0;
        count_baseline  = 0;
        
        for ii = 1:length(CONDITIONS.CS)
        
            if strcmp ('CSplus', CONDITIONS.CS(ii))
                count_CSp     =  count_CSp + 1;
                 itemxc(ii)   = count_CSp;
            elseif strcmp ('CSminus', CONDITIONS.CS(ii))
                count_CSm      = count_CSm + 1;
                itemxc(ii)   = count_CSm;
            elseif strcmp ('BL', CONDITIONS.CS(ii))
                count_baseline = count_baseline + 1;
                itemxc(ii)   = count_baseline;
            end
        
        end




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% save mat file
        func_dir = fullfile (homedir, 'DERIVATIVES', 'PREPROC', ['sub-' num2str(subjX)], ['ses-' sessionX], 'func');
        
        if ~exist(func_dir, 'dir')
            mkdir(func_dir)
        end
        
        cd (func_dir)
        matfile_name = ['sub-' num2str(subjX) '_ses-' sessionX  '_task-' task '_run-01_events.mat'];


        save(matfile_name, 'ONSETS', 'DURATIONS',  'BEHAVIOR', 'CONDITIONS') %, 'REWARD', 'TRIAL', 'RIM', 'PE', 'PIT')




        %dir_dir = fullfile (homedir, ['sub-' num2str(subjX)], 'ses-second', 'func');
        %cd (dir_dir)


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% save tvs file according to BIDS format
        phase = {'trial';'ITI'};
        nevents = ntrials*length(phase);

         % put everything in the event structure
        events.onsets       = zeros(nevents,1);
        events.durations    = zeros(nevents,1);
        events.phase        = cell (nevents,1);
        events.CSname       = cell (nevents,1);
        events.grips        = nan (nevents,1);

        cmpt = 0;
        for ii = 1:ntrials

            for iii = 1:length(phase)

                cmpt = cmpt+1;
                phaseX = char(phase(iii));

                events.onsets(cmpt)     = ONSETS.(phaseX) (ii);
                events.durations(cmpt)  = DURATIONS.(phaseX) (ii);
                events.phase(cmpt)      = phase (iii);
                events.CSname(cmpt)     = CONDITIONS.CS(ii);
                events.grips(cmpt)      = BEHAVIOR.gripFreq(ii);

            end

        end

        events.onsets       = num2cell(events.onsets);
        events.durations    = num2cell(events.durations);
        events.grips        = num2cell(events.grips);

         eventfile = [events.onsets, events.durations,events.phase,...
            events.CSname, events.grips];

        % open data base
        eventfile_name = ['sub-' num2str(subjX) '_ses-' sessionX '_task-' task '_run-01_events.tsv'];
        fid = fopen(eventfile_name,'wt');

        % print heater
        fprintf (fid, '%s   %s   %s   %s   %s\n',...
            'onset', 'duration', 'trialPhase',...
            'CSname','grips');
    
        % print data
        formatSpec = '%d   %d   %s   %s  %d \n';
        [nrows,ncols] = size(eventfile);
        for row = 1:nrows
            fprintf(fid,formatSpec,eventfile{row,:});
        end

        fclose(fid);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% save data for compiled database

        db.id(:,k)        = cellstr(repmat(sub,ntrials, 1));
        db.group(:,k)     = cellstr(repmat(group,ntrials, 1));
        db.session(:,k)   = cellstr(repmat(sessionX,ntrials,1));
        db.task(:,k)      = repmat({task},ntrials,1);
        db.trial(:,k)     = [1:ntrials]';
        db.condition(:,k) = CONDITIONS.CS;
        db.itemxc(:,k)    = itemxc;
        db.gripFreq (:,k) = BEHAVIOR.gripFreq;

    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAVE RESULTS IN TXT for analysis in R

% random
R.id      = db.id(:);
R.trial   = num2cell(db.trial(:));

%fixe
R.group      = db.group(:);
R.session    = db.session(:);
R.task       = db.task(:);
R.condition = db.condition(:);

% mixed
R.itemxc     = num2cell(db.itemxc(:));

% dependent variable
R.gripFreq  = num2cell(db.gripFreq(:));




%% print the database
if save_Rdatabase
    cd (R_dir)

    % concatenate
    Rdatabase = [R.task, R.id, R.group, R.session, R.trial,R.condition, R.itemxc, R.gripFreq];

    % open database
    fid = fopen([analysis_name '.txt'], 'wt');

    % print heater
    fprintf(fid,'%s   %s   %s   %s   %s   %s   %s   %s\n',...
        'task','id', 'group', ...
        'session','trial', 'condition',...
        'trialxcondition','gripFreq');

    % print data
    formatSpec ='%s   %s   %s   %s   %d    %s   %d   %d\n';
    [nrows,~] = size(Rdatabase);
    for row = 1:nrows
        fprintf(fid,formatSpec,Rdatabase{row,:});
    end

    fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%     condition = db.condition(idx);
%     gripsFreq = db.gripFreq(idx);
%     
%     grips.CSplus(id,:)   = gripsFreq (strcmp ('CSplus', condition));
%     grips.CSminus(id,:)  = gripsFreq (strcmp ('CSminus', condition));
%     grips.baseline(id,:) = gripsFreq (strcmp ('Baseline', condition));
%     %grips.none(id,:) = gripsFreq (strcmp ('None', condition));
%     
% end
% 
% % get means and std
% f.means.CSp = nanmean(grips.CSplus,1);
% f.means.CSm = nanmean(grips.CSminus,1);
% f.means.B   = nanmean(grips.baseline,1);
% %f.means.none   = nanmean(grips.none,1);
% 
% %f.stnd.CSp  = nanstd(grips.CSplus,1)/sqrt(length(subj));
% %f.stnd.CSm  = nanstd(grips.CSminus,1)/sqrt(length(subj));
% %f.stnd.B    = nanstd(grips.baseline,1)/sqrt(length(subj));
% 
% 
% figure; hold;
% 
% % cs plus
% csp = plot(f.means.CSp,'-o');
% set(csp(1),'MarkerEdgeColor','none','MarkerFaceColor', [1 1 1],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
% 
% 
% % csminus
% csm = plot(f.means.CSm,'-o');
% set(csm(1),'MarkerEdgeColor','none','MarkerFaceColor', [0 0 0],'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0])
% 
% 
% % baseline
% b = plot(f.means.B,'--o');
% set(b(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.4 0.4 0.4],'MarkerEdgeColor', [0.7 0.7 0.7], 'Color', [0 0 0])
% 
% %none
% %none = plot(f.means.none,'--o');
% %set(b(1),'MarkerEdgeColor','none','MarkerFaceColor', [0.7 0.7 0.7],'MarkerEdgeColor', [0.4 0.4 0.4], 'Color', [0 0 0])
% 
% 
% %legend
% LEG = legend ('CS+','CS-','baseline');
% set(LEG,'FontSize',18)
% 
% %axis
%  xlabel('Trial', 'FontSize', 18)
%  ylabel('Grips', 'FontSize', 18)
%  
% %plot
% title ('Pavlovian Instrumental Transfer', 'FontSize', 18)
% set(gcf, 'Color', 'w')

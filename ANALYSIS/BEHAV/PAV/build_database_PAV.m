%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD DATABASE FOR PAVLOVIAN LEARNING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modified by David on August 2020


dbstop if error
clear all

analysis_name = 'REWOD_PAVCOND_ses_first';
task          = 'pavconditioning';
taskshort          = 'PAV';
%% DEFINE WHAT WE WANT TO DO

save_Rdatabase = 1; % leave 1 when saving all subjects

%% DEFINE PATH

cd ~
home = pwd;
homedir = [home '/REWOD/'];


R_dir        = fullfile(homedir,'DERIVATIVES/BEHAV/PAV');
% add tools
addpath (genpath(fullfile(homedir, 'CODE/ANALYSIS/BEHAV/matlab_functions')));

%% DEFINE POPULATION

subj    = {'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'};    % number 01 has not instru

session = {'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'; 'one'};

ses = {'ses-first'};

for i = 1:length(subj)
        
    subjO=subj(i,1);
    subjX=char(subjO);
    %conditionX=char(group(i,1))
    sessionX  =char(ses);   
    
    disp (['****** PARTICIPANT: ' subjX ' *******']);
   
    %load behavioral file
    behavior_dir = fullfile(homedir, 'SOURCEDATA', 'behav', subjX, [sessionX '_task-' task]);
            cd (behavior_dir)
            load (['conditioning' num2str(subjX) ])
   
    ntrials = size(responseTimes,1) +1;
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get onsets  
  
    %ONSETS.action  = nan;
    
    %ONSETS.CS = data.Onsets.StageTwo;
    %cmpt = 0;
  

    
    ONSETS.dummy =     zeros(1,ntrials);
    DURATIONS.dummy   = zeros(1,ntrials);

    %ONSETS.reward  = data.Onsets.StageNine;
    %ONSETS.swallow = data.Onsets.StageThirten;
    %ONSETS.ITI     = data.Onsets.StageThirten;
    %ONSETS.baseline = data.Onsets.BaselineStart;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get durations
    
    %DURATIONS.action  = nan;
   
    %DURATIONS.CS = data.Durations.TrialStageTwo;
    %cmpt = 0;
    %for ii = 1:length(data.Durations.TrialStageSix) % here take onther variable
        %if data.Durations.TrialStageSix(ii) < 0.9999
            %cmpt = cmpt+1;
            %DURATIONS.action(cmpt,1) = data.Durations.TrialStageSix(ii);
        %end
    %end
    
    %DURATIONS.signal   = data.Durations.TrialStageSix;
    %DURATIONS.reward   = data.Durations.TrialStageNine + data.Durations.TrialStageEleven;
    %DURATIONS.swallow  = data.Durations.TrialStageThirten;
    %DURATIONS.ITI      = data.Durations.TrialStageThirten;
    %DURATIONS.baseline = data.Durations.ShowBaseline;
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  create task  
    pav = ['PavlovianTask'];
    TASK = repmat({pav}, ntrials, 1);
    TASK(end,1) = {'ManipulationCheck'};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% add baseline row
    dataPav.csNames(end+1,1) = {'Baseline'};
    dataPav.rounds(end+1,1) = [NaN];
    responseTimes(end+1,1) = [NaN];
       
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  get condition name right
    A =strcmp(dataPav.csNames,'CSplus');
    B = strcmp(dataPav.csNames,'CSminu');
    dataPav.csNames2 = categorical(zeros(1,ntrials)'+ 2*A + B);
    dataPav.csNames2 = mergecats(dataPav.csNames2,'2','CSplus');
    dataPav.csNames2 = mergecats(dataPav.csNames2,'1','CSminus');
    dataPav.csNames2 = cellstr(mergecats(dataPav.csNames2,'0','Baseline')); 
    CONDITIONS = dataPav.csNames2;
    ROUNDS = dataPav.rounds;
    TRIAL = [1:ntrials]';
    
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% get BEHAVIOR
    BEHAVIOR.RT  = responseTimes;
    
    %%%% change Response into 0 and 1
    D =strcmp(keysPressed,'a');
    keysPressed2 = zeros(1,ntrials-1)'+ D; 
    keysPressed2(end+1,1) = [NaN];
    BEHAVIOR.ACC = keysPressed2;
    
    %for ii = 1:length(DURATIONS.action)
        %BEHAVIOR.RT(ii) = DURATIONS.action(ii);
        %BEHAVIOR.ACC(ii) = nan; % to be added
    %end
    
    %%%%%get ratings
    A =strcmp(CONDITIONS,'CSplus');
    B = strcmp(CONDITIONS,'CSminus');
    C = zeros(1,ntrials)'+ 2*A + B;
      for r = 1:ntrials
        if C(r,1) == 2
            C(r,1) =  PavCheck.ratings(strcmp('CSplus.jpg',PavCheck.imagesName));
        elseif C(r,1) == 1
            C(r,1) = PavCheck.ratings(strcmp('CSminu.jpg',PavCheck.imagesName));
        else
            C(r,1) = PavCheck.ratings(strcmp('Baseli.jpg',PavCheck.imagesName));
        end
      end
    BEHAVIOR.ratings = C;
    
    % item by condition
    itemxc          = nan(ntrials,1);
    count_CSp       = 0;
    count_CSm       = 0;
    count_B       = 0;
     
    for ii = 1:length(CONDITIONS)
        
        if strcmp ('CSplus', CONDITIONS(ii))
            count_CSp            =  count_CSp + 1;
            itemxc(ii)           = count_CSp;
            %Behavior.ratings (ii) = BEHAVIOR.ratings.CSp;
        elseif strcmp ('CSminus', CONDITIONS(ii))
            count_CSm            = count_CSm + 1;
            itemxc(ii)           = count_CSm;
            %Behavior.ratings(ii) = BEHAVIOR.ratings.CSm;
        elseif strcmp ('Baseline', CONDITIONS(ii))
            count_CSm            = count_B + 1;
            itemxc(ii)           = count_B;
        end
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save mat file
    func_dir = fullfile (homedir, 'DERIVATIVES', 'PREPROC', ['sub-' num2str(subjX)], 'ses-first', 'beh');
    cd (func_dir)
    matfile_name = ['sub-' num2str(subjX) '_ses-first' '_task-' task '_events.mat'];
    save(matfile_name, 'ROUNDS', 'TRIAL', 'TASK' , 'BEHAVIOR', 'CONDITIONS')
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save tvs file according to BIDS format
    %phase = {'CS';'signal';'reward';'swallow';'baseline'};
    nevents = ntrials; %*length(phase);
    
    % put everything in the event structure
    events.onsets       = zeros(nevents,1);
    events.duration       = zeros(nevents,1);
    events.ratings    = zeros(nevents,1);
    events.trial    = zeros(nevents,1);
    events.task        = cell (nevents,1);
    events.CSname       = cell (nevents,1);
    events.reactionTime  = zeros (nevents,1);
    events.response  = zeros(nevents,1);
    events.rounds       = zeros(nevents,1);
    
    
    cmpt = 0;
    for ii = 1:ntrials
        
        
            
            cmpt = cmpt+1;
            %phaseX = char(phase(iii));
            
            events.trial(cmpt)     = TRIAL(ii);
            events.ratings(cmpt)  = BEHAVIOR.ratings(ii);
            events.task(cmpt)      = TASK (ii);
            events.CSname(cmpt)     = CONDITIONS(ii);
            events.reactionTime(cmpt) = BEHAVIOR.RT(ii);
            events.response(cmpt) = BEHAVIOR.ACC(ii);
            events.rounds(cmpt) = ROUNDS(ii);
            
  
        
    end
    
    events.ratings    = num2cell(events.ratings);
    events.reactionTime = num2cell(events.reactionTime);
    events.rounds  = num2cell(events.rounds);
    events.response  = num2cell(events.response);
    events.trial  = num2cell(events.trial);
    events.onsets  = num2cell(events.onsets);
    events.duration  = num2cell(events.duration);
            
    eventfile = [events.onsets, events.duration, events.trial, events.CSname, events.reactionTime, events.ratings, events.response, events.rounds];
    
    
    base_dir = fullfile (homedir, ['sub-' num2str(subjX)], 'ses-first', 'beh');
    %mkdir(base_dir)
    cd (base_dir)
    
    
    % open data base
    eventfile_name = ['sub-' num2str(subjX) '_ses-first' '_task-' task '_events.tsv'];
    fid = fopen(eventfile_name,'wt');
    
    % print header
    fprintf (fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
        'onset', 'duration','trial', 'condition','reaction_times', 'liking_ratings', 'accuracy', 'rounds');
    
    % print data
    formatSpec = '%d\t%d\t%d\t%s\t%f\t%f\t%d\t%d\n';
    [nrows,ncols] = size(eventfile);
    for row = 1:nrows
        fprintf(fid,formatSpec,eventfile{row,:});
    end
    
    fclose(fid);
 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% save data for compiled database
    
    db.id(:,i)        = repmat(subj(i,1),ntrials, 1);
    %db.group(:,i)     = repmat(group(i,1),ntrials, 1);
    db.session(:,i)   = repmat(session(i,1),ntrials,1);
    db.task(:,i)      = repmat({task},ntrials,1);
    db.trial(:,i)     = TRIAL;
    db.condition(:,i) = CONDITIONS;
    db.itemxc(:,i)    = itemxc;
    db.RT (:,i)       = BEHAVIOR.RT;
    db.Response(:,i)    = BEHAVIOR.ACC;
    db.ratings(:,i)    = BEHAVIOR.ratings;
    db.rounds(:,i)     = ROUNDS;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAVE RESULTS IN TXT for analysis in R

% random
R.id      = db.id(:);
R.trial   = num2cell(db.trial(:));

%fixe
%R.group     = db.group(:);
R.session   = db.session(:);
R.task      = db.task(:);
R.condition = db.condition(:);
R.rounds    = num2cell(db.rounds(:));

% mixed
R.itemxc    = num2cell(db.itemxc(:));

% dependent variable
R.RT        = num2cell(db.RT(:));
R.Response       = num2cell(db.Response(:));
R.ratings    = num2cell(db.ratings(:));


%% print the database
if save_Rdatabase
    
    cd (R_dir)
    
    % concatenate
    Rdatabase = [R.task, R.id, R.session, R.trial, R.condition, R.itemxc, R.RT, R.Response, R.ratings, R.rounds];
    
    % open database
    fid = fopen([analysis_name '.txt'], 'wt');
    
    % print heater
    fprintf(fid,'%s %s %s %s %s %s %s %s %s %s\n',...
        'task','id',  ...
        'session','trial', 'condition',...
        'trialxcondition','RT', 'accuracy', 'liking_ratings', 'rounds');
    
    % print data
    formatSpec ='%s %s %s %d %s %d %f %d %f %d\n';
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
%     tmp.condition = db.condition(idx);
%     tmp.RT        = db.RT(idx);
%     tmp.ratings    = db.ratings(idx);
%     
%     all.RT.CSplus(id,:)   = nanmean(tmp.RT (strcmp ('CSplus', tmp.condition)));
%     all.RT.CSminus(id,:)  = nanmean(tmp.RT (strcmp ('CSminus', tmp.condition)));
%     
%     all.ratings.CSplus(id,:)  = tmp.ratings(strcmp ('CSplus', tmp.condition));
%     all.ratings.CSminus(id,:) = tmp.ratings(strcmp ('CSminus', tmp.condition));
%     
% end



%%%%%%%%%%%%%%%%%%%%%%%%%% ratings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get means and std

% bysub.ratingsCSp  =  PavCheck.ratings(strcmp('CSplus.jpg',PavCheck.imagesName));
% bysub.ratingsCSm  =  PavCheck.ratings(strcmp('CSminu.jpg',PavCheck.imagesName));
% bysub.ratingsbase = PavCheck.ratings(strcmp('CSbaseli.jpg',PavCheck.imagesName));

%f.ratings.means.CSp = nanmean(bysub.ratingsCSp,1);
%f.ratings.means.CSm = nanmean(bysub.ratingsCSm,1);
%f.ratings.means.b   = nanmean(bysub.ratingsbase,1);

%f.ratings.stnd.CSp  = nanstd(bysub.ratingsCSp,1)/sqrt(length(subj));
%f.ratings.stnd.CSm  = nanstd(bysub.ratingsCSm,1)/sqrt(length(subj));
%f.ratings.stnd.b    = nanstd(bysub.ratingsbase,1)/sqrt(length(subj));

%means = ([f.ratings.means.CSp, f.ratings.means.CSm, f.ratings.means.b]);
%sems  = ([f.ratings.stnd.CSp, f.ratings.stnd.CSm, f.ratings.stnd.b]);

%y = means ((1:length(means)));
%bars = sems (1:length(sems));

%figure;
%bar(1, y(1),0.5, 'faceColor',[1 1 1],'EdgeColor', [0 0 0], 'LineWidth', 1);
%hold on
%bar(2, y(2),0.5, 'faceColor',[0 0 0]);
%bar(3, y(3),0.5, 'faceColor',[0.4 0.4 0.4],'EdgeColor', [0 0 0], 'LineWidth', 1);

%errorbar(1:length(sems),y,bars,'.k', 'LineWidth', 1.5);
%set(gca, 'XTickLabel', '')

% general
%set(gcf, 'Color', 'w')
%box off

%legend
%LEG = legend ('CS+','CS-','baseline');
%set(LEG,'FontSize',18)

%axis
%xlabel('Fractals', 'FontSize', 18)
%ylabel('ratings', 'FontSize', 18)
%ylim ([0 100])

%plot
%title ('Pavlovian learning: ratings ratings', 'FontSize', 18)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%f.RT.means.CSp = nanmean(all.RT.CSplus);
%f.RT.means.CSm = nanmean(all.RT.CSminus);

%f.RT.stnd.CSp  = nanstd(all.RT.CSplus,1)/sqrt(length(subj));
%f.RT.stnd.CSm  = nanstd(all.RT.CSminus,1)/sqrt(length(subj));

%figure;
%means = ([f.RT.means.CSp, f.RT.means.CSm]);
%sems  = ([f.RT.stnd.CSp, f.RT.stnd.CSm]);

%y = means ((1:length(means)));
%bars = sems (1:length(sems));

%bar(1, y(1),0.5, 'faceColor',[1 1 1],'EdgeColor', [0 0 0], 'LineWidth', 1);
%hold on
%bar(2, y(2),0.5, 'faceColor',[0 0 0]);

%errorbar(1:length(sems),y,bars,'.k', 'LineWidth', 1.5);
%set(gca, 'XTickLabel', '')

% general
%set(gcf, 'Color', 'w')
%box off

%legend
%LEG = legend ('CS+','CS-');
%set(LEG,'FontSize',18)

%axis
%xlabel('Fractals', 'FontSize', 18)
%ylabel('Reaction Times', 'FontSize', 18)

%title
%title ('Pavlovian learning: Reaction times', 'FontSize', 18)

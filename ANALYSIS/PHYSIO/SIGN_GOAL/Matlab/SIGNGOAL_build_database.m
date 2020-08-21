%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUILD DATABASE FOR SIGNGOAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% last modified April 2018 by Eva

clear all

%% INPUT VARIABLE

extract_subj_data = 1;
save_results      = 1;

analysis_name     = 'Database-SIGNGOAL';
sessionToMerge    = {'01';'02';'03'};
sessionNtrials    = [ 54 ; 54 ; 54 ];

subj              = {'01';'02'; '03'; '04'; '05'; '06'; '07'; '08'; '09'; '10'; '11'; '12'; '13'; '14'; '16'; '17';'18'; '19'; '20'; '21'; '22'; '23'; '24'; '25'; '26'; '27'; '28'; '29'; '30' ; '31'; '32'; '33'; '34';  '35'; '36'; '37'; '38'; '39'; '41'; '42'; '43'; '44'; '45'; '46'; '47'; '48'; '49'; '50'; '51'; '52'; '53'; '54'; '55'; '56'; '57'; '58'; '59'; '60'; '61'; '63'; '64'; '65'; '66'; '67'; '68'; '69'; '70'; '71'; '72'; '74'; '75'; '76'; '77'; '78'; '80'; '81'; '82'; '83'; '84' ;'85';'86';'87';'88';'89';'90';'91';'92';'93';'94';'95';'96';'97';'98';'99';'100';'101';'102';'103';'104';'105';'106';'107';'108';'109';'110';'111';'112';'113';'114';'115';'116';'117';'118';'119';'120';'121';'122';'123';'124';'125';'126';'127';'128';'129';'130';'131';'132';'133';'134';'135';'136';'137';'138';'139';'141';'142';'143';'144';'145';'146';'147';'148';'149';'150';'151';'152';'153';'154';'155';'156';'157';'158'};
eye               = ones (1,length(subj));

%% DEFINE PATH


% get homedirectory
%current_dir       = pwd;
%where_to_cut      = (regexp (pwd, 'ANALYSIS/Matlab') -1);
%homedir           = current_dir(1:where_to_cut);

homedir = '/Users/lance/switchdrive/SIGNGOAL';


% current
data_dir          = fullfile(homedir,'DATA','STUDY');
questionnaire_dir = fullfile(homedir,'DATA','STUDY','phenotype');
analysis_dir      = fullfile(homedir,'ANALYSIS','Matlab');

% outputs
R_dir             = fullfile(homedir,'ANALYSIS','R');
database_dir      = fullfile(analysis_dir, 'my_databases');

% tools
addpath (genpath(fullfile(analysis_dir,'my_tools')));


%**************************************************************************
%% LOOP TO EXTRACT DATA

if extract_subj_data == 1
    
    for  i=1:length(subj) % for each subject
        
        subjX=subj(i,1);
        subjX=char(subjX);
        
        subj_dir = fullfile (data_dir, ['sub-' subjX]);

        % initialize dependent variables vectors
        PUPIL          = nan(sum(sessionNtrials),1);
        DW_CS_right    = nan(sum(sessionNtrials),1);
        DW_CS_left     = nan(sum(sessionNtrials),1);
        DW_CS_congr    = nan(sum(sessionNtrials),1);
        DW_CS_cue      = nan(sum(sessionNtrials),1);
        DW_ANT_right   = nan(sum(sessionNtrials),1);
        DW_ANT_left    = nan(sum(sessionNtrials),1);
        DW_ANT_congr   = nan(sum(sessionNtrials),1);
        DW_ANT_cue     = nan(sum(sessionNtrials),1);
        USACC          = nan(sum(sessionNtrials),1);
        
        % initialize random factors vectors (run and trial are not really random)
        ID             = cell(sum(sessionNtrials),1);
        RUN            = cell(sum(sessionNtrials),1);
        TRIAL          = nan(sum(sessionNtrials),1);
        
        % initialize fixed factors vectors
        CS             = cell(sum(sessionNtrials),1);
        CONGR          = cell(sum(sessionNtrials),1);
        CSLIKING       = nan(sum(sessionNtrials),1);  

        % temporary variables
        medianX        = nan(sum(sessionNtrials),1);
        medianY        = nan(sum(sessionNtrials),1);
        CStypeSwitch   = nan(sum(sessionNtrials),1);
        CSposition     = nan(sum(sessionNtrials),1);
        switch_cost    = nan(sum(sessionNtrials),1);
        log_usrt       = nan(sum(sessionNtrials),1);
        us_position    = nan(sum(sessionNtrials),1);
        
        % intilize trial counter
        cmpt  = 1;
        
        for ii = 1: length (sessionToMerge) % for each run
            
            sessionX=sessionToMerge(ii,1);
            sessionX=char(sessionX);
            
            disp (['****** PARTICIPANT: ' subjX '; RUN: ' sessionX ' *******']);
            
            % matlab data
            load (fullfile(subj_dir, ['sub-' subjX  '_task-SIGNGOAL_run-' sessionX '_events.mat']));
            
            % eye link data
            load (fullfile(subj_dir,['sub-' subjX  '_task-SIGNGOAL_run-' sessionX '_eyes.mat']));
             
            param.dispPlot   = 0; % Ksenia you can put this to 0 after the first time you opened each files
            param.whichEye   = eye(i);
            param.screendim  = [0 0 1920 1080];% data.screen; % get this from data
            param.FSP        = getFPS(dataGaze.RawEdf.FSAMPLE.time);
            [t, allEye, s]   = load_EDF(param, dataGaze, data, subjX);
            
            ntrials = sessionNtrials(ii); % get number of trial in this run
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % PUPIL ON THE CS
            
            Pupil_plot_all(i).(['session_' sessionX]) = t.CS.pa.plot;              % For the plot we take 3 s of baseline corrected data
            mean_pupil     = nanmean(t.CS.pa.reflex,2); % average of the pupil dilation between 500 and 1.5 s (look at the plot what makes sense the  most)
            
            % create variable to adjust for CS repetition, CS position and eye movement
            medianX (cmpt:cmpt+ntrials-1)      = nanmedian (t.CS.pa.x,2);
            medianY (cmpt:cmpt+ntrials-1)      = nanmedian (t.CS.pa.y,2);
            CStypeSwitch (cmpt:cmpt+ntrials-1) = getCSswitch (data.CSname);
            CSposition(cmpt:cmpt+ntrials-1)    = data.CSposition;
            PUPIL(cmpt:cmpt+ntrials-1)         = mean_pupil; % save
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % DWELL TIME LEFT AND RIGHT DURING CS
            
            CS_Gaze_antX(i).(['session_' sessionX]) = t.CS.x;% For the plot 
            CS_Gaze_antY(i).(['session_' sessionX]) = t.CS.y;% For the plot 
            
            [ROI_L, ROI_R, ROI_U, ROI_D,ROI_matrix_toolbox] = defineROI (); %ROI_matrix = ROI_L =1, ROI_U=2, ROI_R=3, ROI_D=4 (from left to right clokwise)
            ROI = [2;1;4;3];  % 2 = up; 1 = left; 4 = down 3 = right
            name_roi_vect = {'ROI_up'; 'ROI_left';'ROI_down';'ROI_right'};
            
            for iii = 1:length(ROI);
                
                ROIX = ROI(iii);
                name_roiX = name_roi_vect(iii,1);
                name_roi = char(name_roiX);
                
                ROI_mean_number_duration.(name_roi) = getROIfixations(ROI_matrix_toolbox,t.CS.x,t.CS.y,t.CS.time,ROIX);
                
            end
            
            dwell_CS_right = ROI_mean_number_duration.ROI_right(:,3);
            dwell_CS_left  = ROI_mean_number_duration.ROI_left(:,3);
            
            dwell_CS_congruent = NaN (length(data.CSposition),1);
            
            for iii = 1:length(data.CSposition)
                
                if data.CSname (iii) == 1
                    dwell_CS_congruent (iii,1) = ROI_mean_number_duration.ROI_left(iii,3);
                elseif data.CSname (iii) == 2
                    dwell_CS_congruent(iii,1) = ROI_mean_number_duration.ROI_right(iii,3);
                elseif data.CSname (iii) == 3
                    dwell_CS_congruent(iii,1) = nanmean ([ROI_mean_number_duration.ROI_right(iii,3),ROI_mean_number_duration.ROI_left(iii,3)],2);
                end
                
            end
            
            dwell_CS_cue = NaN (length(data.CSposition),1);
            
            for iii = 1:length(data.CSposition)
                
                if data.CSposition (iii) == 2 % up and down are inverted in the eye tracking units
                    dwell_CS_cue (iii,1) = ROI_mean_number_duration.ROI_up(iii,3);
                elseif data.CSposition (iii) == 1
                    dwell_CS_cue(iii,1) = ROI_mean_number_duration.ROI_down(iii,3);
                end
                
            end
        
            % save
            DW_CS_right(cmpt:cmpt+ntrials-1) = dwell_CS_right;
            DW_CS_left(cmpt:cmpt+ntrials-1)  = dwell_CS_left;
            DW_CS_congr(cmpt:cmpt+ntrials-1) = dwell_CS_congruent;
            DW_CS_cue(cmpt:cmpt+ntrials-1)   = dwell_CS_cue;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % GAZE BIAS DURING ANTICIPATION (DURATION: DWELL TIME)
            

            Gaze_antX(i).(['session_' sessionX]) = t.ANT.x;% For the plot 
            Gaze_antY(i).(['session_' sessionX]) = t.ANT.y;% For the plot 

            for iii = 1:length(ROI);
                
                ROIX = ROI(iii);
                name_roiX = name_roi_vect(iii,1);
                name_roi = char(name_roiX);
                
                ROI_mean_number_duration.(name_roi) = getROIfixations(ROI_matrix_toolbox,t.ANT.x,t.ANT.y,t.ANT.time,ROIX);
                
            end
            
            dwell_ANT_right = ROI_mean_number_duration.ROI_right(:,3);
            dwell_ANT_left  = ROI_mean_number_duration.ROI_left(:,3);

            dwell_ANT_congruent = NaN (length(data.CSposition),1);
            
            for iii = 1:length(data.CSposition)
                
                if data.CSname (iii) == 1
                    dwell_ANT_congruent (iii,1) = ROI_mean_number_duration.ROI_left(iii,3);
                elseif data.CSname (iii) == 2
                    dwell_ANT_congruent(iii,1) = ROI_mean_number_duration.ROI_right(iii,3);
                elseif data.CSname (iii) == 3
                    dwell_ANT_congruent(iii,1) = nanmean ([ROI_mean_number_duration.ROI_right(iii,3),ROI_mean_number_duration.ROI_left(iii,3)],2);
                end
                
            end
            
            dwell_ANT_cue = NaN (length(data.CSposition),1);
            
            for iii = 1:length(data.CSposition)
                
                if data.CSposition (iii) == 2 % up and down are inverted in the eye tracking units
                    dwell_ANT_cue (iii,1) = ROI_mean_number_duration.ROI_up(iii,3);
                elseif data.CSposition (iii) == 1
                    dwell_ANT_cue(iii,1) = ROI_mean_number_duration.ROI_down(iii,3);
                end
                
            end
            
            % save
            DW_ANT_right(cmpt:cmpt+ntrials-1) = dwell_ANT_right;
            DW_ANT_left(cmpt:cmpt+ntrials-1)  = dwell_ANT_left;
            DW_ANT_congr(cmpt:cmpt+ntrials-1) = dwell_ANT_congruent;
            DW_ANT_cue(cmpt:cmpt+ntrials-1)   = dwell_ANT_cue;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % COMPUTE RT AND ACC On THE USs
            
            % create variable to adjust for US repetition and US position
            usrt                             = cleanRT(data.behavior.USRT);% remove anticipation
            log_usrt(cmpt:cmpt+ntrials-1)    = log(usrt);                   % log transform
            switch_cost(cmpt:cmpt+ntrials-1) = getCSswitch (data.US);       % switching cost
            us_position (cmpt:cmpt+ntrials-1)= data.US;
            
            % save
            usacc                            = data.behavior.USACC;
            USACC(cmpt:cmpt+ntrials-1)       = usacc;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % ID; RUN; ITEM; GROUP; CONGRUENCY; CS
            
            % random factors
            id    = repmat({['sub-' char(subj(i,1))]},ntrials, 1);
            run   = repmat(sessionToMerge(ii,1),   ntrials,1);
            trial = [cmpt:cmpt+ntrials-1]';
            
            %save
            ID(cmpt:cmpt+ntrials-1)    = id;
            RUN(cmpt:cmpt+ntrials-1)   = run;
            TRIAL(cmpt:cmpt+ntrials-1) = trial;
            
            % fixed factors
            
            % translate my code number into meaningfull terms
            CSname = cell (ntrials,1);
            for iii = 1:ntrials % translate my code number into meaningfull terms
                
                switch data.CSname (iii)
                    case 1
                        CSname{iii} = 'CSpL';
                    case 2
                        CSname{iii} = 'CSpR';
                    case 3
                        CSname{iii} = 'CSmi';
                end
                
            end
            
            congruency = cell (ntrials,1);
            for iii = 1:ntrials % translate my code number into meaningfull terms
                
                switch data.CScongr (iii)
                    case 1
                        congruency{iii} = 'congr';
                    case 0
                        congruency{iii} = 'congr';
                    case -1
                        congruency{iii} = 'incongr';
                end
                
            end
            
            % save
            CS(cmpt:cmpt+ntrials-1)    = CSname;
            CONGR(cmpt:cmpt+ntrials-1) = congruency;

           
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % LIKING RATINGS
            
            if isfield (data.behavior, 'likingImageName') % this is because the first 3 participants did not have liking ratings
                
                likingRating.CSpL = data.behavior.likingRating(strcmp(data.behavior.likingImageName, 'CSpL'));
                likingRating.CSpR = data.behavior.likingRating(strcmp(data.behavior.likingImageName, 'CSpR'));
                likingRating.CSmi = data.behavior.likingRating(strcmp(data.behavior.likingImageName, 'CSmi'));
                
                list = {'CSpL';'CSpR';'CSmi'};
                liking_run = nan (length(CSname),1);
                
                for iiii = 1:length(list)
                    
                    what = char(list(iiii));
                    idx = ((strcmp (what,CSname)));
                    liking_run(idx) = likingRating.(what);
                    
                end
                
                % save liking
                CSLIKING(cmpt:cmpt+ntrials-1) = liking_run;
                
            end % end of if field
            
            % update trial couter for the next run
            cmpt  = cmpt + ntrials;
          
            
        end % end for each run
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % OPERATIONS THAT NEED TO BE DONE ON THE THREE RUNS MERGED
        
        % clean pupil
        costant          = ones(length(medianX),1);
        lineartrend      = getLinearTrend(PUPIL);
        correctionMatrix = [costant,medianX,medianY,CStypeSwitch,CSposition, lineartrend];
        [~,~,R,~,~]      = regress(PUPIL,correctionMatrix); % R are the residulas after removing linear trend and switch cost
        PUPIL            = R; % for the model will use the pupil adjusted for movement and CS repetition
            
        % clean RT
        lineartrend      = getLinearTrend(log_usrt);  
        correctionMatrix = [costant,switch_cost,us_position,lineartrend];% remove
        [~,~,R,~,~]      = regress(log_usrt,correctionMatrix); % R are the residulas after removing linear trend and switch cost
        USRT             = R;
           
        % divide all trials in bins taking into consideration the kind of CS that has been presented
        % count trial per condition for item analysis
        bins             = cell (length(TRIAL),1);
        itemxc           = nan  (length(TRIAL),1);
        count_CSpL       = 0;
        count_CSpR       = 0;
        count_CSmi       = 0;
        
        for iii = 1:length(CS)
            if strcmp ('CSpL', CS(iii))
                count_CSpL = count_CSpL + 1;
                itemxc(iii)= count_CSpL;
                if count_CSpL <= 9
                    bins{iii}  = 'bin01';
                elseif count_CSpL > 9  && count_CSpL <= 18
                    bins{iii}  = 'bin02';
                elseif count_CSpL > 18  && count_CSpL <= 27
                    bins{iii}  = 'bin03';
                elseif count_CSpL > 27  && count_CSpL <= 36
                    bins{iii}  = 'bin04';
                elseif count_CSpL > 36  && count_CSpL <= 45
                    bins{iii}  = 'bin05';
                elseif count_CSpL > 45 && count_CSpL <= 54
                    bins{iii}  = 'bin06';
                end
            elseif strcmp ('CSpR', CS(iii))
                count_CSpR = count_CSpR + 1;
                itemxc(iii)= count_CSpR;
                if count_CSpR <= 9
                    bins{iii}  = 'bin01';
                elseif count_CSpR > 9  && count_CSpR <= 18
                    bins{iii}  = 'bin02';
                elseif count_CSpR > 18  && count_CSpR <= 27
                    bins{iii}  = 'bin03';
                elseif count_CSpR > 27  && count_CSpR <= 36
                    bins{iii}  = 'bin04';
                elseif count_CSpR > 36  && count_CSpR <= 45
                    bins{iii}  = 'bin05';
                elseif count_CSpR > 45 && count_CSpR <= 54
                    bins{iii}  = 'bin06';
                end
            elseif strcmp ('CSmi', CS(iii))
                count_CSmi = count_CSmi + 1;
                itemxc(iii)= count_CSmi;
                if count_CSmi <= 9
                    bins{iii}  = 'bin01';
                elseif count_CSmi > 9  && count_CSmi <= 18
                    bins{iii}  = 'bin02';
                elseif count_CSmi > 18  && count_CSmi <= 27
                    bins{iii}  = 'bin03';
                elseif count_CSmi > 27  && count_CSmi <= 36
                    bins{iii}  = 'bin04';
                elseif count_CSmi > 36  && count_CSmi <= 45
                    bins{iii}  = 'bin05';
                elseif count_CSmi > 45 && count_CSmi <= 54
                    bins{iii}  = 'bin06';
                end  
            end       
        end
        
        % SAVE EACH SUBJECT IN THE DATABASE
        
        db.id(:,i)          = ID;
        db.trial(:,i)       = TRIAL;
        db.itemxc(:,i)      = itemxc;
        db.run(:,i)         = RUN;
        db.bins(:,i)        = bins;
        
        db.CS(:,i)          = CS;
        db.CONGR(:,i)       = CONGR;
        
        db.pupil(:,i)       = PUPIL;
        db.dw_CS_left(:,i)  = DW_CS_left;
        db.dw_CS_right(:,i) = DW_CS_right;
        db.dw_CS_congr(:,i) = DW_CS_congr;
        db.dw_CS_cue (:,i)  = DW_CS_cue;
        db.dw_ANT_left(:,i) = DW_ANT_left;
        db.dw_ANT_right(:,i)= DW_ANT_right;
        db.dw_ANT_congr(:,i)= DW_ANT_congr;
        db.dw_ANT_cue(:,i)  = DW_ANT_cue;
        db.USRT(:,i)        = USRT;
        db.USACC(:,i)       = USACC;
        db.liking(:,i)      = CSLIKING;
     

    end % end loop
    
    if save_results
        cd (database_dir)
        save ([analysis_name '.mat'], 'db', 'Pupil_plot_all', 'Gaze_antX', 'Gaze_antY','CS_Gaze_antX', 'CS_Gaze_antY' )
        cd(analysis_dir)
    end
      
else % if do not extract the data from each participant load the mat file previously saved
    
    cd(database_dir)
    load ([analysis_name '.mat'])
    cd(analysis_dir)
    
end % if extract data

%**************************************************************************
%% SAVE RESULTS IN TXT for analysis in R

clear R % R was used as variable name for residuals before

% random-ish factors
R.ID          = db.id(:);
R.trial       = num2cell(db.trial(:));
R.itemxc      = num2cell(db.itemxc(:));
R.run         = db.run(:);
R.bins        = db.bins(:);


% Fixed factors
R.CSname      = db.CS(:);
R.congr       = db.CONGR(:);

% dependent variable
R.CS.pupil    = num2cell(db.pupil(:));

R.CS.liking   = num2cell(db.liking(:));

R.CS.DW_L     = num2cell(db.dw_CS_left(:));
R.CS.DW_R     = num2cell(db.dw_CS_right(:));
R.CS.DW_congr = num2cell(db.dw_CS_congr(:));
R.CS.DW_cue   = num2cell(db.dw_CS_cue(:));

R.ANT.DW_L    = num2cell(db.dw_ANT_left(:));
R.ANT.DW_R    = num2cell(db.dw_ANT_right(:));
R.ANT.DW_congr= num2cell(db.dw_ANT_congr(:));
R.ANT.DW_cue  = num2cell(db.dw_ANT_cue(:));

R.US.RT       = num2cell(db.USRT(:));
R.US.ACC      = num2cell(db.USACC(:));

Rdatabase = [R.ID, R.trial, R.itemxc, R.run, R.bins,...
    R.congr, R.CSname,...
    R.CS.pupil, R.CS.DW_L, R.CS.DW_R, R.CS.DW_congr, R.CS.DW_cue,...
    R.ANT.DW_L, R.ANT.DW_R, R.ANT.DW_congr, R.ANT.DW_cue, ...
    R.US.RT, R.US.ACC, R.CS.liking];

%% print the database
cd (R_dir)

% open database
fid = fopen([analysis_name '.txt'], 'wt');

% print heater
fprintf(fid,'%s   %s   %s   %s   %s   %s   %s   %s   %s   %s   %s   %s   %s   %s   %s   %s   %s   %s   %s\n',...
    'ID','trial', 'item_condition', 'run','bin',...
    'congr', 'CS',...
    'CS_pupil', 'CS_DW_L', 'CS_DW_R', 'CS_DW_congr','CS_DW_cue',...
    'ANT_DW_L', 'ANT_DW_R', 'ANT_DW_congr', 'ANT_DW_cue',...
    'US_RT', 'US_ACC', 'CS_liking');

% print data
formatSpec = '%s   %d   %d   %s   %s    %s   %s  %d   %d   %d   %d   %d   %d   %d   %d   %d   %d   %d   %d\n';
[nrows,~] = size(Rdatabase);
for row = 1:nrows
    fprintf(fid,formatSpec,Rdatabase{row,:});
end

fclose(fid);
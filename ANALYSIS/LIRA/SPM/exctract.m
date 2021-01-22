%function extract_betas_mods(glm, task)
%use to be a function but I got tired of it

dbstop if error

glm= 'GLM_GUSTO';
task='hedonicreactivity';

list_roi = {'Pirif', 'hpp'};

% which contrast
group_list = {'placebo'; 'treatment'}; %
con_list = {'con_0002.nii'; 'con_0003.nii'}; %
con_name = {'reward'; 'neutral'}; %



%% DEFINE PATH
cd ~
home = pwd;
homedir = [home '/OBIWAN'];

% control = [homedir '/DERIVATIVES/GLM/SPM/' task '/' glm '/sub-control*'];
% obese = [homedir '/DERIVATIVES/GLM/SPM/' task '/' glm '/sub-obese*'];
% 
% controlX = dir(control);
% obeseX = dir(obese);
% 
% sub_list = vertcat(controlX, obeseX);

for g=1:length(group_list)
    
for k=1:length(con_list)
    
    dir_data   =  fullfile (homedir, '/DERIVATIVES/GLM/SPM', task, glm, 'group', group);
    subj = [dir_data '/*' con_list{k}];

    sub_list = dir(subj);

    roi_dir = fullfile(homedir, '/DERIVATIVES/GLM/SPM',task, glm, 'group', 'ROI');


    % for k = 1:length(list_roi)
    %     ROI_name = list_roi{k};

    % intialize spm 
    spm('defaults','fmri');
    spm_jobman('initcfg');

    cd(dir_data)

    %loop across ROIs first
    for r  =1:length(list_roi)
        result = con_name';
        maskName = list_roi{r};
        
        cd (roi_dir)

        mkdir(con_name{k})
        
        v_mask = spm_vol([maskName '.nii']); %extract voxels from ROIs as mask
        outputFile = [v_mask.fname(1:end-4) '_betas.mat'];

        if exist(outputFile,'file')==0 %extract betas only if file doesn't exist    
            Y = spm_read_vols(v_mask);
            roi_volume_mm = length(find(Y > 0))*abs(det(v_mask.mat));
            clear Y;

    %         %loop across contrasts
    %         for c = 1:length()
            conName = con_list{k};
            % List of files to extract data from

    %                 for s0 = 1:length(sub_list)  % select con image from every subject
    %                     conDir = fullfile(dir_data, [sub_list(s0,:).name '_' char(con_list(c,:))]); %add Model directory if necessary
    %                     images(s0,:) = conDir;
    %                 end

            fprintf(1,[char(conName) ': Memory mapping images...\n']);

            for i=1:size(sub_list,1)
                v{i} = spm_vol([sub_list(1).folder '/' sub_list(i).name]);
                % Verify images are in same space
                if ~isequal(v{i}.dim(1:3),v{1}.dim(1:3))
                error('Images must have same dimensions.')
                end
                % Verify orientation/position are the same
                if ~isequal(v{i}.mat,v{1}.mat)
                error('Images must have same orientation/position.')
                end
                fprintf(1,[sub_list(i).name ' done.\n']);
            end


            [Y, XYZmm] = spm_read_vols(v{1});
            clear Y

            XYZmask = inv(v_mask.mat)*([XYZmm; ones(1,size(XYZmm,2))]);
            ind = find(spm_sample_vol(v_mask, XYZmask(1,:), XYZmask(2,:), XYZmask(3,:),0) > 0);

            ind = ind(:)';
            vals = [];
            for j=1:length(v)
                Y = spm_read_vols(v{j});
                % rows:  images.  cols:  voxels
                vals = [vals; Y(ind)];
            end

            % Consider only values which are finite for all images
            vals = vals(:, find(all(isfinite(vals))));
            intersection_volume_mm = size(vals,2)*abs(det(v{1}.mat));
            if intersection_volume_mm==0
                error('No voxels in ROI are in-brain for all images to be sampled.');
            end
            m = mean(vals, 2);

            result = [{'betas'}; num2cell(m)];


            cd (con_name{k})

            save(outputFile,'result');

            writecell(result,[maskName '_betas.csv'])

            disp ('betas extracted!')

        else
            display('error')

        end


    end
end

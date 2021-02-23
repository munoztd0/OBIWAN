%function extract_betas_mods(glm, task)
%use to be a function but I got tired of it
clear all

dbstop if error
glm= 'GLM-01';
task='hedonicreactivity';

list_roi = {'mask_PHC', 'mask_OFC'};

% which contrast
group_list = {'placebo'}; %treatment
ses_list = {'0'; '1'}; %
con_list = {'con_0003.nii'; 'con_0004.nii'}; %
con_name = {'reward'; 'neutral'}; %



%% DEFINE PATH
cd ~
home = pwd;
homedir = [home '/OBIWAN'];

% intialize spm 
spm('defaults','fmri');
spm_jobman('initcfg');


for g=1:length(group_list)
    
    clear subj sub_list dir_data
    
    group = group_list{g};
    
    for s=1:length(ses_list)
        
        ses = ses_list{s};
    
        for k=1:length(con_list)
            
            con = con_list{k};
            
            dir_data   =  fullfile (homedir, '/DERIVATIVES/GLM/SPM', task, [glm '_' ses], 'group', group);
            
            subj = [dir_data '/*' con];

            sub_list = dir(subj);

            roi_dir = fullfile(homedir, '/DERIVATIVES/GLM/SPM',task, 'ROI');

            cd(dir_data)

            %loop across ROIs first
            for r  =1:length(list_roi)
                result = con_name';
                maskName = list_roi{r};

                cd (roi_dir)

                mkdir(con_name{k})

                v_mask = spm_vol([maskName '.nii']); %extract voxels from ROIs as mask
                outputFile = [v_mask.fname(1:end-4) '_' ses '_' group '_betas.mat'];

                if exist(outputFile,'file')==0 %extract betas only if file doesn't exist    
                    Y = spm_read_vols(v_mask);
                    roi_volume_mm = length(find(Y > 0))*abs(det(v_mask.mat));
                    clear Y;

                    conName = con_list{k};


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

                    writecell(result,[maskName  '_' ses '_' group '_betas.csv'])

                    disp ('betas extracted!')

                else
                    display('error')

                end
            end
        end
    end
end


function exctract_betas_mods(glm, task)

%clear
%clc
dbstop if error

glm= 'GLM-04';
task='PIT';

%% which model?
ana_name = glm;

% which task?
task_name = task; %
threshold = '0.01';
con_name = 'R_N_lik';
glm_roi= 'GLM-04_HED';

% which contrast
con_names = {'CSp-CSm'};

con_list = {'con_0001.nii'}; %
%R_C = CONTRAT 1   
%R_N = CONTRAT 2   

% path

cd ~
home = pwd;
homedir = [home '/REWOD'];

dir_data   =  fullfile (homedir, '/DERIVATIVES/ANALYSIS', task_name, ana_name, 'group');
roi_dir = fullfile(homedir, '/DERIVATIVES/ANALYSIS',task_name, 'ROI', threshold, glm_roi, con_name);

% intialize spm 
spm('defaults','fmri');
spm_jobman('initcfg');

cd(dir_data)

sub_list = ['01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'20';'21';'22';'23';'24';'25';'26'];


%list ROIs/clusters from which to extract betas

roi_list = char(spm_select('FPList', roi_dir, ['^'  '.*' 'nii']));




%loop across ROIs first
for r=1:size(roi_list,1)
    result = con_names';
    maskName = roi_list(r,:);
    v_mask = spm_vol(maskName); %extract voxels from ROIs as mask
    outputFile = [v_mask.fname(1:end-4) '_betas.mat'];
    
    if exist(outputFile,'file')==0 %extract betas only if file doesn't exist    
        Y = spm_read_vols(v_mask);
        roi_volume_mm = length(find(Y > 0))*abs(det(v_mask.mat));
        clear Y;
        
        %loop across contrasts
        for c = 1:length(con_list)
            conName = con_names(c,:);
            % List of files to extract data from
            for s0 = 1:length(sub_list)  % select con image from every subject
                conDir = fullfile( dir_data, ['sub-' sub_list(s0,:) '_' char(con_list(c,:))]); %add Model directory if necessary
                images(s0,:) = conDir;
            end
            numImages = size(images,1);

            fprintf(1,[char(conName) ': Memory mapping images...\n']);
            for i=1:numImages
                v{i} = spm_vol(images(i,:));
                % Verify images are in same space
                if ~isequal(v{i}.dim(1:3),v{1}.dim(1:3))
                error('Images must have same dimensions.')
                end
                % Verify orientation/position are the same
                if ~isequal(v{i}.mat,v{1}.mat)
                error('Images must have same orientation/position.')
                end
            end
            fprintf(1,'done.\n');

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

            result(2:length(v)+1,c) = num2cell(m); 

            cd (roi_dir)
            mkdir betas
                        
            save(outputFile,'result');

        end
        
         disp ('betas extracted!')
    
    else
        display('error')
 
    end
    
    movefile *_betas.mat betas/
         
end

end

% apply transform to all images
%level = exp(0.0001*32768/2);
   hdr = spm_vol('MS_SMM_map_pos_1_mod_1_GLM-28.nii');
   img = spm_read_vols(hdr);
   hdr.pinfo = [0.01; 0; 0];
   hdr.fname = strcat('l', 'MS_SMM_map_pos_1_mod_1_GLM-28.nii');
   img = 1000*log(img);
   img = img*-1; 
   img =log(img);
   scale =  100/ max(img(~isinf(img)));
   img = img *scale;
   spm_write_vol(hdr, img);

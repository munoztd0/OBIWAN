function espm_conjunction(groupdir, fname, con_num) 
dbstop if error
% created on JUNE 2019 by Eva
% last modified on JUNE 2019 by Eva


% ARGUMENTS:
%   1) groupdir: path for finding level 1 dir containing con images
%   2) outputname name of the output image (e.g., conjuction.nii)
%   3) constrated images to enter in the conjuction analysis
%   4) analysisX: analysis name (e.g., Conjunction1)

% Adapted from function spm8w_conjunction(): A script to create a map of the minimum t-statistic across conditions (resulting in a logical AND conjunction)

cd ~
home = pwd;
homedir = [home '/REWOD/'];


% | DEFINE FOLDER
constrastFolder = fullfile (groupdir);


% | LOAD T-STAT FILES
cd (constrastFolder)
% For manual selection
%vt = spm_vol(spm_select(con_num,'image',['Please select all ',num2str(con_num),' spm_t files'],[],[],'^spmT.*'));
% automatically select all t maps in the folder
vt = spm_vol(spm_select('List',constrastFolder,'^spmT.*'));


% | CREATE MINUMS
fprintf('==========Creating conjunction map from all %d conditions\n',con_num);

for i = 1:con_num
   t{i} = spm_read_vols(vt(i));
end

%Calculate the minimum t values for all conditions
for i = 1:(con_num-1)
   if i==1
       Yout = max(0,min(t{1},t{2})) + min(0,max(t{1},t{2}));
   else
       Yout = max(0,min(Yout,t{i+1})) + min(0,max(Yout,t{i+1}));
   end
end
fprintf('Done... Writing out conjunction volume...\n');

% | WRITE OUT CONJUNCTION VOLUME
cd (constrastFolder)

%Setup writing
Vout = vt(1);
Vout.fname = fname;
spm_write_vol(Vout,Yout);

fprintf('Conjunction of all %d t-stat files saved to %s\n',con_num,fname);

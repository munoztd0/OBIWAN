function path = MakePathStruct()

path.main = pwd;
path.data = fullfile(path.main,'data');
cd(path.main);
%if var.day == 1
path.scripts = fullfile(path.main,'scripts');
%elseif var.day == 2;
   % path.scripts = fullfile(path.main,'scripts_MRI');
%
end
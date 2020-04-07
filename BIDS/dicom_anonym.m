function dicom_anonym(subID)

%%little script to anonymize dicom

%by David Munoz  -  March 2020


cd ~
home = pwd;
homedir =[home '/REWOD/'];

subj  =  {'11'}; %subID; %{'01';'02';'03';'04';'05';'06';'07';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19'; '20';'21';'22';'23';'24';'25';'26'};

for i = 1:length(subj)

    % participant's specifics
    subjX = char(subj(i));
    subjindir =fullfile(homedir,'SOURCEDATA', 'brain', subjX, 'dcm');

    cd (subjindir)

    list1 = dir('MR*');
    list2 = dir('SC*');
    list3 = dir('SRe*');
    
    x = 1;
    for ii = 1:length(list1)
        dicomanon([list1(ii).folder '/' list1(ii).name], [list1(ii).folder  '/' list1(ii).name '_an'])
   
        x = x +1;
        display (x);
    end
    
    %for ii = 1:length(list2)
        %dicomanon([list2(ii).folder '/' list2(ii).name], [list2(ii).folder  '/' list2(ii).name '_an'])
    %end

    for ii = 1:length(list3)
        dicomanon([list3(ii).folder '/' list3(ii).name], [list2(ii).folder  '/' list3(ii).name '_an'])
    end

    disp (['sub ' subjX ' anonymized!'])


end
end

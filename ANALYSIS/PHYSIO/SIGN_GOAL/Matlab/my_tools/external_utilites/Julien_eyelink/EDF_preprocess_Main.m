% 
 edf_fileName = 'W:\dataRawEpilepsy\P29CS_011714\logs\Array3.edf';
 edf_preprocess_result = 'W:\dataRawEpilepsy\P29CS_011714\logs\Array3.mat';
 offsets = [ 0 4000]; %ms
% 
% 
% edf_fileName = 'W:\dataRawEpilepsy\P29CS_103113\logs\p29cs_no2_recog.edf';
% edf_preprocess_result = 'W:\dataRawEpilepsy\P29CS_103113\logs\p29cs_no2_recog.mat';
% 
% edf_fileName = 'W:\dataRawEpilepsy\P29CS_103113\logs\p29cs_no2_learn.edf';
% edf_preprocess_result = 'W:\dataRawEpilepsy\P29CS_103113\logs\p29cs_no2_learn.mat';
% 
% edf_fileName = 'W:\dataRawEpilepsy\P29CS_011714\logs\p29cs_no3_recog.edf';
% edf_preprocess_result = 'W:\dataRawEpilepsy\P29CS_011714\logs\p29cs_no3_recog.mat';

%offsets = [ 0 1000]; %ms


whichEye = 1;  % which eye was tracked

dataGaze = edfmex(edf_fileName);

[eventsTask, eventsGaze, eventsInfo] = EDF_preprocess_Events( dataGaze.FEVENT);

trialsToUse = find( eventsTask(:,2) == 1);


[gazeDataAll, gazeDataTrials] = EDF_preprocess_Data( dataGaze.FSAMPLE, dataGaze.FEVENT, eventsTask, eventsGaze, trialsToUse, whichEye, offsets )


save(edf_preprocess_result, 'gazeDataAll', 'gazeDataTrials', 'whichEye', 'offsets', 'trialsToUse', 'edf_fileName');




%% ==== plot example trials (NO task)
figure(20);
c=0;
%for k=[2 4 7 8 9 10 12 15 27 34 35 42 44 57 59 82 93 95]
for k=1:25
    
    c=c+1;
    subplot(5,5,c);
    
    %figure(100+k);
    
    % plot the image
    fnameImg = eventsInfo(k).filenameStr;
    fnameImg = strrep(fnameImg, 'c:\images\', 'W:\stimuli\images\');
    imgOrig = imread( fnameImg );
    
    %posImg = [ posx-sizeX/2 posy-sizeY/2 posx+sizeX/2 posy+sizeY/2 ];

    if length(size(imgOrig))==2
        % img is bw
        imgOrig = repmat(double(imgOrig)./255,[1 1 3]);
    end
    
    posImg = fix(centerImg(imgOrig));
    image(posImg(1):posImg(3)-1, posImg(2):posImg(4)-1, imgOrig)
    set(gca,'XTickLabel','');
    set(gca,'YTickLabel','');

    title(['k=' num2str(k) ]);
    
    EDF_plotGazeData_ofTrial( gazeDataTrials, k);
end


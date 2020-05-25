function [USdownAdapted, USupAdapted] = selectImages(ratingResult, imagesName, imagesType, USdown, USup)

% The images are rated and we choose the 3 images for the experiment.
% First: find the indices of the different images categories.
indicesMen = imagesType == 0;
indicesWomen = imagesType == 1;
indicesScrambled = imagesType == 2;

% Second: for men and women find the highest rated images. For scrambled
% find rating value nearer to 50.
[~, indexMan] = max(ratingResult(indicesMen));
[~, indexWoman] = max(ratingResult(indicesWomen));
[~, indexScrambled] = min(abs(50 - ratingResult(indicesScrambled)));

% Third: select the images.
imagesManName = imagesName(indicesMen);
imageMan = imagesManName{indexMan};

imagesWomanName = imagesName(indicesWomen);
imageWoman = imagesWomanName{indexWoman};

imagesScrambledName = imagesName(indicesScrambled);
imageScrambled =  imagesScrambledName{indexScrambled};

% Finally we can set the USdown and USup with the images choosen by the
% user.
USdownAdapted = USdown;
USdownAdapted{2} = imageWoman;
USdownAdapted{4} = imageScrambled;
USdownAdapted{6} = imageMan;

USupAdapted = USup;
USupAdapted{1} = imageWoman; 
USupAdapted{3} = imageScrambled; 
USupAdapted{5} = imageMan; 

end

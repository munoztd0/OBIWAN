function [basLiking,CSminusLiking,CSplusLiking] = extractLiking (PavCheck)


liking = num2cell(PavCheck.ratings);
matrix = [PavCheck.imagesName, liking];
matrix = sortrows(matrix,1);

basLiking = cell2mat (matrix (1,2));
CSminusLiking = cell2mat(matrix (2,2));
CSplusLiking = cell2mat(matrix (3,2));

end
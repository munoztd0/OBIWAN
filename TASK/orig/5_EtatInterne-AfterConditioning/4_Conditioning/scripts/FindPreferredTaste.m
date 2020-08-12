function PreferredTaste = FindPreferredTaste(participantID)
url='D:\Projects\gusto\PIT-EvaProject\Liking\data';
Filename=[url,'\liking' num2str(participantID) '.mat'];
load(Filename)
PreferredTaste = Results.PreferredTaste;
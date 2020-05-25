openfunction oSet(relay)
% oSet(relay) : demande ? positionner un relai sur 'On'
% relay = le No du relais ? positionner
%
% La fonction oCommit() doit ?tre appel?e pour que les changements d'?tat
% enregistr?s en m?moire se r?percutent sur les relais

calllib('olphac','relaySet',relay);

function oClose()
% oClose() : Clôture une session avec l'olphactomètre.
calllib('olphac','relayClose');
unloadlibrary('olphac');
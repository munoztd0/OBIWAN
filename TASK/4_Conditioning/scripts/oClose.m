function oClose()
% oClose() : Cl�ture une session avec l'olphactom�tre.
calllib('olphac','relayClose');
unloadlibrary('olphac');
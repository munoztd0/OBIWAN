function oInit(port,has4Banks)
% oInit(port,has4Banks) : Ouvre une session d'olpfactomètre
% port = le numero du port COM virtuel qui commande les relais
% has4Banks = 'true'  pour une unité à 32 relais,
%             'false' pour une unité à 16 relais
%
% La session doit être fermée avec oClose() à la fin de l'experiance,
% sans quoi ca plante le port série

loadlibrary('proXR_relays','proXR_relays.h','alias', 'olphac');
calllib('olphac','relayInit',port,has4Banks);

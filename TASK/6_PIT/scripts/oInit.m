function oInit(port,has4Banks)
% oInit(port,has4Banks) : Ouvre une session d'olpfactom�tre
% port = le numero du port COM virtuel qui commande les relais
% has4Banks = 'true'  pour une unit� � 32 relais,
%             'false' pour une unit� � 16 relais
%
% La session doit �tre ferm�e avec oClose() � la fin de l'experiance,
% sans quoi ca plante le port s�rie

loadlibrary('proXR_relays','proXR_relays.h','alias', 'olphac');
calllib('olphac','relayInit',port,has4Banks);

function oClear(relay)
% oClear(relay) : demande � positionner un relai sur 'Off'
% relay = le No du relais � positionner
%
% La fonction oCommit() doit �tre appel�e pour que les changements d'�tat
% enregistr�s en m�moire se r�percutent sur les relais

calllib('olphac','relayClear',relay);

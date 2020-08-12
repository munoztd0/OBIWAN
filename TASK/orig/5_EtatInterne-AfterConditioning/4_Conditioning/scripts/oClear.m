function oClear(relay)
% oClear(relay) : demande à positionner un relai sur 'Off'
% relay = le No du relais à positionner
%
% La fonction oCommit() doit être appelée pour que les changements d'état
% enregistrés en mémoire se répercutent sur les relais

calllib('olphac','relayClear',relay);

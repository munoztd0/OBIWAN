function oSet(relay)
% oSet(relay) : demande à positionner un relai sur 'On'
% relay = le No du relais à positionner
%
% La fonction oCommit() doit être appelée pour que les changements d'état
% enregistrés en mémoire se répercutent sur les relais

calllib('olphac','relaySet',relay);

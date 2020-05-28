function oStimulus(lr,stim)
% oStimulus(lr,stim) : demande à l'olphactomètre de se mettre dans l'état
% d'inter_stimulation (flux d'air sans odeur)
% lr = 0 pour la narine gauche, 1 pour la narine droite
% stim = le numero du stimulus
%
% La fonction oCommit() doit être appelée pour que les changements d'état
% enregistrés en mémoire se répercutent sur les relais

calllib('olphac','switchToStim',lr,stim);
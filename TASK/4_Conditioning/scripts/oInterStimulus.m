function oInterStimulus(lr)
% oInterStimulus(lr) : demande � l'olphactom�tre de se mettre dans l'�tat
% d'inter_stimulation (flux d'air sans odeur).
% lr = 0 pour la narine gauche, 1 pour la narine droite
%
% La fonction oCommit() doit �tre appel�e pour que les changements d'�tat
% enregistr�s en m�moire se r�percutent sur les relais

calllib('olphac','switchToISI',lr);
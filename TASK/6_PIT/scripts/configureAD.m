function configureAD(channel,gainIndex)
% gainIndex significations :
%   0: +/-5V
%   1: +/-2.5V
%   2: +/-1.25
%   3: +/-0.625V(only Rev.A)
%   4: +/-10V
global AdvantechGlob;
p = AdvantechGlob.instantAiCtrl.Channels(channel + 1);
p.ValueRange = AdvantechGlob.ValueRanges(gainIndex + 1);
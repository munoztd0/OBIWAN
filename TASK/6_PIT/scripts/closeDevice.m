function closeDevice()
global AdvantechGlob;
if isempty(AdvantechGlob)
    clear global AdvantechGlob;
    error('Advantech device not opened');
end
AdvantechGlob.instantAiCtrl.Dispose();
clear global AdvantechGlob;


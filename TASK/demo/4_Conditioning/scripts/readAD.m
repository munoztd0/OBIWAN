function val = readAD()
global AdvantechGlob;
val = zeros(1,AdvantechGlob.channelCount);
errorCode = AdvantechGlob.instantAiCtrl.Read(...
    AdvantechGlob.startChannel,...
    AdvantechGlob.channelCount, AdvantechGlob.data); 
if BioFailed(errorCode)
    throw Exception();
end
for j=0:(AdvantechGlob.channelCount - 1)
    val(j+1) = AdvantechGlob.data.Get(j);
end
end

function result = BioFailed(errorCode)
result =  errorCode < Automation.BDaq.ErrorCode.Success && ...
    errorCode >= Automation.BDaq.ErrorCode.ErrorHandleNotValid;
end
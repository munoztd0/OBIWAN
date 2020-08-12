function openDevice()
global AdvantechGlob;
AdvantechGlob.BDaq = NET.addAssembly('Automation.BDaq');
AdvantechGlob.deviceDescription = 'USB-4711A,BID#0'; 
AdvantechGlob.startChannel = int32(0);
AdvantechGlob.channelCount = int32(1);
AdvantechGlob.instantAiCtrl = Automation.BDaq.InstantAiCtrl();
try
    % Step 2: Select a device by device number or device description and 
    % specify the access mode. In this example we use 
    % AccessWriteWithReset(default) mode so that we can fully control the 
    % device, including configuring, sampling, etc.
    AdvantechGlob.instantAiCtrl.SelectedDevice = Automation.BDaq.DeviceInformation(AdvantechGlob.deviceDescription);
    AdvantechGlob.data = NET.createArray('System.Double', AdvantechGlob.channelCount);
    AdvantechGlob.ValueRanges =...
        AdvantechGlob.instantAiCtrl.Features.ValueRanges;
catch e
    clear global AdvantechGlob;
    error(['Cannot open device ',AdvantechGlob.deviceDescription]);
end

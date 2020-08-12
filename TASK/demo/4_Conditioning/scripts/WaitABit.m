function tFunction = WaitABit (var)

startT = GetSecs();
%recond how long does this function take
timer = GetSecs()-var.time_MRI;
while timer < var.ref_end
    timer = GetSecs()-var.time_MRI;
end
tFunction = GetSecs()-startT;
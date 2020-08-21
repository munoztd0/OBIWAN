08/12/2016
the existing edfmex was crashing Matlab for Julien (Matlab R2015a 64-bit on Windows 7 Ultimate).

Followed the steps described by SR Brian (08-10-2016 post on this thread: https://www.sr-support.com/showthread.php?2600-Import-of-EDF-file-into-Matlab-2)

got edfmex code from GitHub: https://github.com/HukLab/edfmex

>> makeHeader
Warning: Warnings messages were produced while parsing.  Check the functions you intend
to use for correctness.  Warning text can be viewed using:
 [notfound,warnings]=loadlibrary(...) 
> In loadlibrary (line 359)
  In makeHeader (line 50) 
Warning: The data type 'FcnPtr' used by function edf_set_log_function does not exist. 
> In loadlibrary (line 431)
  In makeHeader (line 50) 
Building with 'Microsoft Windows SDK 7.1 (C++)'.
MEX completed successfully.
>> mex -largeArrayDims edfmex.cpp edfapi64.lib
Building with 'Microsoft Windows SDK 7.1 (C++)'.
MEX completed successfully.


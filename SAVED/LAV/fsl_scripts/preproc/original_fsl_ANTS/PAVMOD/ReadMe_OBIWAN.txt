1. run_prepForICA: Does brain extraction on the anatomicals & functionals (just one scan, the actual bet is done later in melodic). Also creates the fieldmaps and does brain extraction on them.

2. run_ICA: Runs melodic on each functional session to compute the components we will remove in the next step (this can take a long time depending on the number of volumes and how noisy the data is). Also does brain extraction on the functionals (0.3 by default).

3. run_ANTsAnatomical: Roughly aligns the T2 to the T1 (using flirt), and computes the warp into a standard space using ANTs (this takes a looong time).

4. run_cleanICA: Computes the ICA features and uses the classifier to label and remove bad components. 

5. run_unwarp: Then fieldmaps are realigned with functionals and applied to functional scans to unwarp.

6. run_ANTsCoreg: Uses ANTs to move the T2 and functional scans into standard space. 
	
7. run_smoothFunctional: Smooths the functional scans, and unzips the compressed image files for use in SPM.

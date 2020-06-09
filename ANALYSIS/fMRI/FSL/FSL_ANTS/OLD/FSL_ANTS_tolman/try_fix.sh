#!/bin/bash                                                                                                                                                                                 

# pull in the subject we should be working on                                                                                                                                               
subjectID=01
runID=02

echo "Preparing subject ${subjectID} session ${runID}"

# the subject directory                                                                                                                                                                     
subT2=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/T2_reoriented_brain.nii.gz                                                                                                  
# Directory containing functionals, high-res reference scans, and field-maps                                                                                                                
funcDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/RUN_${runID}.ica/
echo "${funcDir}"

# Directory with run-specific files                                                                                                                                                         
runDir=/home/evapool/PAVMOD/DATA/brain/ICA_ANTS/${subjectID}/RUN_${runID}/
# the component classification rejection threshold                                                                                                                                          
threshold=10
# the dwell time for fugue unwarping                                                                                                                                                        
dwellTime=0.00054

###################                                                                                                                                                                         
# classify components as artifact/signal, remove artifacts                                                                                                                                  
# generates filtered_func_data_clean in the ICA directory                                                                                                                                   
echo "started classification at $(date +"%T")"
# the classifier path                                                                                                                                                                       
classifierPath=/home/shared/fix/classifiers/FIX_giovanniCoins_jeffCasinoUSA.RData
# classify components (approx 30 min)                                                                                                                                                       
# will generate a label file at the specified threshold called fix4melview_FIX_giovanniCoins_jeffCasinoUSA_thr<threshold>.txt                                                               
echo 'run dir: ${runDir}'
echo 'class path: ${classifierPath}'
echo 'thresh: ${threshold}'

/usr/local/fix/fix -c ${funcDir} ${classifierPath} ${threshold}
echo "Classification done at $(date +"%T")"
# remove bad ones                                                                                                                                                                           
#/usr/local/fix/fix -a ${funcDir}fix4melview_FIX_giovanniCoins_jeffCasinoUSA_thr${threshold}.txt -m
echo "finished cleanup at $(date +"%T")"

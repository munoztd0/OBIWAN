#!/bin/bash
home=$(eval echo ~$user)

codeDir="${home}/REWOD/CODE/ANALYSIS/fMRI/MVPA/PYmvpa"
taskID="hedonic"
model="MVPA-04"

# in order
#MVPA_script="mvpa_calc.py"  # radius2
#MVPA_script="mvpa_second.py"  # radius2
# either got to SPM to do the quick second level or:
#MVPA_script="mvpa_perms_1st.py"  #voxel2
#MVPA_script="mvpa_perms_2nd.py"  #fwe at 0.1  removded '24',
#MVPA_script="mvpa_debug.py" 
MVPA_script="grid_search.py"  


pythonSubmit="${home}/REWOD/CODE/ANALYSIS/fMRI/dependencies/mvpa_oneSubj.sh"

# Loop over subjects
 for subjectID in 01 #02 03 04 05 06 07 09 10 11 12 13 14 15 16 17 18 20 21 22 23 24 25 26 # 
    do
			#qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=00:40:00,pmem=4GB -M david.munoz@etu.unige.ch -m e -l nodes=1 -q queue1 -N ${model}_s${subjectID}_${taskID} -F "${subjectID} ${taskID} ${model} ${codeDir} ${MVPA_script}" ${pythonSubmit}
            #qsub -I -o ${home}/REWOD/ClusterOutput -j oe -l walltime=00:40:00,pmem=4GB -m n -l nodes=1 -q queue2 -N ${model}_s${subjectID}_${taskID} -F "${subjectID} ${taskID} ${model} ${codeDir} ${MVPA_script}" ${pythonSubmit}
            qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=44:40:00,pmem=16GB -M david.munoz@etu.unige.ch -m n -l nodes=1 -q queue1 -N ${model}_s${subjectID}_${taskID} -F "${subjectID} ${taskID} ${model} ${codeDir} ${MVPA_script}" ${pythonSubmit}
            #qsub -o ${home}/REWOD/ClusterOutput -j oe -l walltime=4:40:00,pmem=4GB -M david.munoz@etu.unige.ch -m e -l nodes=1  -q queue1 -N ${GLM}_s${subj}_${task} -F "${subj} ${codeDir} ${matlab_script}" mriqc ~/REWOD/ ~/REWOD/MRIQC participant
            
done

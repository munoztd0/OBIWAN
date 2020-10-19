
SmoothScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/smoothFunc.sh
CopyAnatomicalsScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/copyAnatomicalsClean.sh

# Loop over subjects
#01 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30


#for subjID in control100
for subjID in control100 control102 control105 control106 control107 control108 control109 control112 control113 control114 control115 control116 control118 control119 control120 control121 control122 control125 control127 control128 control129 control130 control131 control132 control133

do
	# copy anatomical scans to CLEAN
#	qsub -o /home/OBIWAN/ClusterOutput -j oe -l nodes=1,walltime=0:30:00,pmem=4GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N copyAnat_${subjID} -F "${subjID}" ${CopyAnatomicalsScript}

	for sessionID in second
	do

		# Loop over runs smooth and unzip for SPM use
		for taskID in hedonicreactivity
		do
				# spawn session jobs to the cluster after the subject level work is complete
	       qsub -o /home/OBIWAN/ClusterOutput -j oe -l nodes=1,walltime=0:30:00,pmem=4GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N smoothing_${subjID}_${sessionID}_${taskID} -F "${subjID} ${sessionID} ${taskID}" ${SmoothScript}
				#qsub -o /home/REWOD/ClusterOutput -j oe -l nodes=1,walltime=0:30:00,pmem=4GB -M david.munoz@etu.unige.ch -m e -q batch -N smoothing_${subj}_${run} -F "${subj} ${run}" ${sessionScript}

		done
	done
done

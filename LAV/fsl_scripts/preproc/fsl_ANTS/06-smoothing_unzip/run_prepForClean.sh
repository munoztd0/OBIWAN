
SmoothScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/06-smoothing_unzip/smoothFunctional.sh
AnatomicalScript=/home/OBIWAN/ANALYSIS/fsl_scripts/preproc/fsl_ANTS/06-smoothing_unzip/anatomicalClean.sh


#for subjID in control100
for subjID in control100 control102 control105 control106 control107 control108 control109 control112 control113 control114 control115 control116 control118 control119 control120 control121 control122 control125 control127 control128 control129 control130 control131 control132 control133

do
	# copy anatomical scans to CLEAN
#	qsub -o /home/OBIWAN/ClusterOutput -j oe -l nodes=1,walltime=0:30:00,pmem=4GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N copyAnat_${subjID} -F "${subjID}" ${AnatomicalScript}

	for sessionID in second
	do

		# Loop over runs smooth and unzip for SPM use
		for taskID in hedonicreactivity
		do
				# spawn session jobs to the cluster after the subject level work is complete
	       qsub -o /home/OBIWAN/ClusterOutput -j oe -l nodes=1,walltime=0:30:00,pmem=4GB -M lavinia.wuensch@etu.unige.ch -m e -l nodes=1 -q queue1 -N smoothing_${subjID}_${sessionID}_${taskID} -F "${subjID} ${sessionID} ${taskID}" ${SmoothScript}

		done
	done
done

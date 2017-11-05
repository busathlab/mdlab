#!/bin/bash

#################################
### FOR USE ONLY WITH TSM LAB ###
###     MGLEED 29 May 2014    ###
#################################

### Define these variables ###

#Is this a water simulation or a 2kqt simulation? (water/2kqt)
export type=2kqt

#Is this for a dynamics script or a post-processing script? (0 if dynamics, 1 if post-processing script)
export simtype=1

#Which values of lambda would you like to simulate? (If for post-processing, ensure match in lambda vars near script end)
export lambdas=( ".05" ".125" ".5" ".875" ".95" )
export numlambdas=5

#Drug ID's for TSM (mutate drug1 to drug2); e.g. use 035 for Amt and 150 for Rim
export drug1=035
export drug2=150

#For dynamics only...Is this a restart? (0 if heating, 1 or more for restart level)
export rst=1

#For post-processing only...What was the last restart number performed?
export lastrestart=1

#Random-number-generator seed (optional)
export iseed=21951

#######################################################
# Shouldn't need to change anything beyond this point #
#######################################################

submitscript=batch.submit
# Create submission scripts via here-document
cat <<"EOF" > $submitscript
#!/bin/bash

#SBATCH

cd "$SLURM_SUBMIT_DIR"

module purge
module load charmm

if [ $simtype == 0 ]; then
	export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE
	mpirun $(which charmm) drug1:$drug1 drug2:$drug2 iseed:$iseed rst:$rst L:${L} type:$type < $INFILE > $OUTFILE
else
	$(which charmm) numlambdas:$numlambdas drug1:$drug1 drug2:$drug2 lambda4:$lambda4 lambda5:$lambda5 lambda1:$lambda1 lambda2:$lambda2 lambda3:$lambda3 OUTFILE:$OUTFILE lastrestart:$lastrestart type:$type < $INFILE > $OUTFILE
fi

exit 0

EOF

chmod 770 $submitscript

if [ $simtype == 0 ]; then
	if [ $rst == 0 ]; then
		export htrst=heat
		wallhours=1
	else
		export htrst=restart
		wallhours=120
	fi
	for submission in $(seq 0 $(($numlambdas - 1))); do
		export L=${lambdas[$submission]}
		export INFILE=tsm.${htrst}_${type}.str
		export OUTFILE=log/log.tsm_150_${type}_${rst}_${L}		
		echo "Submitting ${type} lambda=${L} restart=${rst}"
	
		if [ $type == water ]; then
			sbatch -J "fe.${rst}.${L}.${type}" -e "log/slurm/fe.${rst}.${L}.${type}.e%j" -o "log/slurm/fe.${rst}.${L}.${type}.o%j" -N1 -n8 --mem-per-cpu=2G -t${wallhours}:00:00 ${submitscript} 	
		else
			##BILAYER SIMULATION NEEDS LOTS OF RESOURCES...
			sbatch -J "fe.${rst}.${L}.${type}" -e "log/slurm/fe.${rst}.${L}.${type}.e%j" -o "log/slurm/fe.${rst}.${L}.${type}.o%j" -N1 -n12 --mem-per-cpu=2G -t${wallhours}:00:00 ${submitscript}
		fi
	done
else
	export lambda1=${lambdas[0]}
	export lambda2=${lambdas[1]}
	export lambda3=${lambdas[2]}	
	export lambda4=${lambdas[3]}
	export lambda5=${lambdas[4]}
	
	export INFILE=tsm.post_processing.str
	export OUTFILE=log/log.tsm.post_processing.${type}.str
	#sbatch -J "pp.${type}" -e "log/slurm/pp.${type}.e%j" -o "log/slurm/pp.${type}.o%j" -N1 -n1 --mem-per-cpu=2G -t10:00:00 ${submitscript} 
	./${submitscript}
	
	#create output file
	echo "fixing output file"
	#find first line of interest
	tail -n +`grep -n "plot files" ${OUTFILE} | sed -e "s/:/ /" | awk '{print $1}' | head -n 1` ${OUTFILE} > output/postp/${drug2}_${type}_tmp.txt
	#cut out lines not of interest
	head -n `grep -n CHARMM output/postp/${drug2}_${type}_tmp.txt | sed -e "s/:/ /" | awk '{print $1}' | head -n 1` output/postp/${drug2}_${type}_tmp.txt | head -n -2 | tail -n +4 > output/postp/${drug2}_${type}.txt
	rm output/postp/${drug2}_${type}_tmp.txt
	echo "Done. Processed TSM data in output/postp/${drug2}_${type}.txt"
fi

rm $submitscript

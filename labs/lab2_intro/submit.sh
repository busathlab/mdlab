#!/bin/bash

## VARIABLES ##

infile=myfile.str
outfile=myfile.str.log

parallel=0 #run CHARMM in parallel? enter yes=1 no=0 (use 0 if using loops)

## SUBMIT ##

module load charmm
if [ $parallel == 0 ]; then
	$(which charmm) < $infile > $outfile
else
	export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE # exports a variable to charmm to use all available processors
	mpirun $(which charmm) < $infile > $outfile
fi
exit 0
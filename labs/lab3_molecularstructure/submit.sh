#!/bin/bash

## VARIABLES ##

infile=alpha.str
outfile=alpha.str.log

parallel=0 #run CHARMM in parallel? enter yes=1 no=0 (use 0 if using loops)

## SUBMIT ##

export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE
module load charmm
if [ $parallel == 0 ]; then
	$(which charmm) < $infile > $outfile
else
	mpirun $(which charmm) < $infile > $outfile
fi
exit 0

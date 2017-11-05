#!/bin/bash

## VARIABLES ##

infile=build_snap25.str
outfile=build_snap25.log

parallel=1 #run CHARMM in parallel? enter yes=1 no=0 (use 0 if using loops)

## SUBMIT ##

export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE
module load charmm
if [ $parallel == 0 ]; then
	$(which charmm) < $infile > $outfile
else
	mpirun $(which charmm) < $infile > $outfile
fi
exit 0
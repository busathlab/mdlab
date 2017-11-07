#!/bin/bash

#SBATCH --time=8:00:00   # walltime
#SBATCH --ntasks=16   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=2G   # memory per CPU core

# Launch CHARMM 
module purge
module load charmm
mpirun $(which charmm) < charmm.eq.str > output/charmm/charmm.eq.str.log
#!/bin/bash

#SBATCH --time=8:00:00   # walltime
#SBATCH --ntasks=16   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=2G   # memory per CPU core

# NAMD variables
export namddir=/fslhome/mgleed/software/namd/exec/NAMD_Git-2017-11-04_Linux-x86_64-multicore

# Run NAMD 
$namddir/namd2 +setcpuaffinity `numactl --show | awk '/^physcpubind/ {printf "+p%d +pemap %d",(NF-1),$2; for(i=3;i<=NF;++i){printf ",%d",$i}}'` namd.eq.inp > output/namd/namd.eq.log 
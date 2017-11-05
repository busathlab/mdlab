#!/bin/bash

#SBATCH --time=00:30:00   # walltime
#SBATCH --ntasks=4   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=1024M   # memory per CPU core
#SBATCH -J "homology"   # job name
#SBATCH --gid=busathlab

#edit these...
inputDirectory=ZZZ		# do not include forward slash
inputFile=ZZZ
export channeltype=ZZZ 	# channel type to simulate (should match file names)
export firstres=ZZZ 	# needs to reflect the first residue's ID in $channeltype_a.pdb

#leave these...
workdir=$(pwd)
export OMP_NUM_THREADS=$SLURM_CPUS_ON_NODE
cd $inputDirectory
module load charmm
mpirun $(which charmm) channeltype:$channeltype firstres:$firstres  < $inputFile > ../log/${inputFile}_${channeltype}.log
cd $workdir
exit 0

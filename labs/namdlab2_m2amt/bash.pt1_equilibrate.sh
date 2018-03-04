#!/bin/bash

#SBATCH --time=18:00:00   # walltime
#SBATCH --ntasks=24   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --gres=gpu:4
#SBATCH --mem=64G   # memory per CPU core

# Add a channel backbone tilt restraint to the equilibration scheme
if [ -f charmm-gui/namd/membrane_lipid_restraint.namd.col_backup ]; then
	cp charmm-gui/namd/membrane_lipid_restraint.namd.col_backup charmm-gui/namd/membrane_lipid_restraint.namd.col
else 
	cp charmm-gui/namd/membrane_lipid_restraint.namd.col charmm-gui/namd/membrane_lipid_restraint.namd.col_backup
fi
cat <<EOT >> charmm-gui/namd/membrane_lipid_restraint.namd.col
colvar { 
	name bb_tilt
	tilt { 
		atoms {
			atomsFile          restraints/bb_rmsd.ref
			atomsCol           B 
			atomsColValue      1.0 
		}
		refPositionsFile      restraints/bb_rmsd.ref
		refPositionsCol       B
		refPositionsColValue  1.0    
		axis (0.0, 0.0, 1.0) 
	} 
} 

harmonic {
	colvars bb_tilt
	centers 0
	forceConstant 1
}
EOT
	
# NAMD variables

# Run NAMD 

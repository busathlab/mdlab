#!/bin/bash

# CHARMM variables
export drugsegid=
export pdbid=
export drugname=
export topparloc=/fslhome/mgleed/fsl_groups/busathlab/compute/toppar_c36_aug14

# Run CHARMM 
module purge
module load charmm 
mkdir -p output
$(which charmm) topparloc:$topparloc drugsegid:$drugsegid pdbid:$pdbid drugname:$drugname < charmm.adddrug.str > output/charmm.adddrug.str.log 
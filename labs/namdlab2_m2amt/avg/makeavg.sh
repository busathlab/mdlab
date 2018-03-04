#!/bin/sh

#~~~~~~~~~~~~~~~~
# Mitchell Gleed 17 Sep 2014
# DESCRIPTION
#  Creates an average structure from PDB file and aligns to backbone of structure of interest (M2)
# REQUIREMENTS
#  1. Must have a directory labelled by in gui_m2bilayers from CHARMM-GUI membrane builder (OPM pdb ok)
#  2. Must have a directory labelled by protein in gui_m2bilayers/rcsb_models from CHARMM-GUI PDB reader (Must be RCSB pdb)
#~~~~~~~~~~~~~~~~

# usage
if (( $# != 1 )); then {
  echo "usage: $0 <PDB ID>"
  exit -1
}; fi
export pdbid=${1,,}

# find out how many models
count=0
track=0
while [ $count -le 50 ]; do
	if [ -d rcsb_models/$pdbid/nmr_models/model_${count} ]; then
		let "track = track + 1"		
	fi
	let "count = $count + 1"
done
export track

# change to model 1 directory
dir=$(pwd)
cd rcsb_models/$pdbid/nmr_models/model_1

# make average structure
cat <<EOF > makeavg.str
*title
*

ioformat exte
set topparloc /panfs/pan.fsl.byu.edu/scr/grp/busathlab/toppar_c36_aug14
stream @topparloc/load_toppar.str
!stream @topparloc/load_protein.str

read psf xplor card name step1_pdbreader.xplor_ext.psf
open write unit 22 file name ../avg.dcd

Trajectory iwrite 22 nfile $track
* $track models from $pdbid written to dcd
*

set m 1
label loop
read coor card name ../model_@{m}/step1_pdbreader.crd

if @m .eq. 1 then
	coor copy comp
else
	defi backbone sele segid PRO* .and. (TYPE N .OR. TYPE CA .OR. TYPE C .or. TYPE O) END
	coor orie rms sele backbone end
endif

traj write
!print coor
incr m
if m le $track goto loop

close unit 22
rewind unit 22

open read file unit 51 name ../avg.dcd

coor dyna first 51 nunit 1 sele all end

write coor card name ../avg.crd
* crd
*
write coor pdb name ../avg.pdb
* pdb
*
write psf card name ../avg.psf
* psf
*


!! ENABLE THESE LINES TO ORIENT TO OPM MEMBRANE POSITION
read coor comp card name ../../../../${pdbid}/step5_assembly.crd

defi backbone sele segid PRO* .and. (TYPE N .OR. TYPE CA .OR. TYPE C .or. TYPE O) END

coor orie rms sele backbone end

write coor card name ../../../../${pdbid}/avg_oriented.crd
* crd oriented
*
write coor pdb name ../../../../${pdbid}/avg_oriented.pdb
* pdb oriented
*
write psf card name ../../../../${pdbid}/avg_oriented.psf
* psf
*

EOF
module purge
module load compiler_intel/13.0.1
module load mpi/openmpi-1.6.5_intel-13.0.1
charmmexec=/panfs/pan.fsl.byu.edu/scr/grp/busathlab/software/charmm/builds/c37b1_xxlarge_intel_mkl_domdec_fslop_impi
$charmmexec < makeavg.str > log.makeavg.str

cd $dir


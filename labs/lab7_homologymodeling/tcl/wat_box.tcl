# solvate a protein inside a water box 
# buffer is for additional Angstroms in all dimensions around protein
# to submit type: source 'file name' in the VMD Tk console interface
# make sure you are in the correct folder 


set psf xs31n.psf
set pdb xs31n.pdb
set buffer 5
set outputfiles s31n_wb

package require solvate
solvate $psf $pdb -t $buffer -o $outputfiles

resetpsf

mol new ${outputfiles}.psf
mol addfile ${outputfiles}.pdb
readpsf ${outputfiles}.psf
coordpdb ${outputfiles}.pdb

set everyone [atomselect top all]

puts "CENTER OF MASS IS: [measure center $everyone weight mass]"
puts "MINMAX IS: [measure minmax $everyone]"


# select atoms of a protein for rmsd calculation

set sel_resid [[atomselect top "protein and alpha"] get resid]
# selection, gets the residue numbers of all alpha-carbons in the protein and save this list of residue numbers in the variable $sel_resid
rmsd_residue_over_time top $sel_resid
# calling procedure to calculate rmsd for the selection
# data is printed to residue_rmsd.dat and procedure sets the value of the user field of all atoms of the residue to the computed rmsd value
# user values allow visual construction of the protein in VMD

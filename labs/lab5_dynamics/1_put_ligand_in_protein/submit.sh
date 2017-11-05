#!/bin/bash

infile=combine_protein_lig.inp
outfile=combine_protein_lig.out

module load charmm

$(which charmm) < $infile > $outfile

exit 0

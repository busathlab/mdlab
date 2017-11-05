#!/bin/bash

infile=solvator.inp
outfile=solvator.out

module load charmm

$(which charmm) < $infile > $outfile

exit 0

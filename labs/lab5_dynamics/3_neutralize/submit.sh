#!/bin/bash

infile=neutralize.inp
outfile=neutralize.out

module load charmm

$(which charmm) < $infile > $outfile

exit 0

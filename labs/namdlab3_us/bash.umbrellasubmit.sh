#!/bin/bash

# Simulation variables 
	# You will EXPORT these for use within this script and in CHARMM, NAMD, VMD, etc.
	
	# suggested approach: run through the configuration files and decide which values/variables you would like to have passed from the main submission script, then ensure they are added here
	
	# ex: channel PDB name, system PSF/NAMD coor file location, Unit cell dimensions file location, drug name, drug segid, drug PSF/Coor/carbon definitions file location
	# ex: number of simulation steps, start of reaction coordinate, increment for reaction coordinate, end of reaction coordinate, colvars harmonic bias force constant
	export topparloc=/panfs/pan.fsl.byu.edu/scr/grp/busathlab/toppar_c36_aug14	
		
# Process variables 
	# compute the total number of umbrella windows on the reaction coordinate, you will need this value for your loop 
	
	
# Loop 
	# create a loop to go through all of the umbrella windows and call a function at every iteration
	# you can loop through an array of umbrella positions (see arrays section in lab), start at zero and end if < total number of umbrella windows, etc.
	for ((  )); do 	
		# get the current umbrella position based on the count in the loop (arithmetic)
	
		# convert your umbrella position variable from an unformatted string to a decimal with a specific length (e.g. 0.1 -> 000.100) 
		
		# call your submission function 
		
	done	
	
# Function
	# the function does all the heavy lifting of the script 
	SUBMIT () {
	
	# process parameters		
		# create an output filename pattern by combining variables (e.g. 2kqt_alm034_000.100)
		
		# create specific output directory for the new output filename 
		mkdir -p output/$outputPattern/
		
	# modify the colvars file 
		# copy the original colvars restraint file to a new file
		# since the new file is unique and each umbrella window will have its own, you'll need to use the new output filename pattern you set above 
		
		# you'll be using VMD to create unique restraint files for each umbrella window, it may be a good idea to set the filenames now so you can substitute them in the colvars file. # these files don't actually exist yet (these are the output of your VMD script) but colvars needs to know where they will be 
		export drugRestraintFileLocation=
		export backboneRestraintFileLocation=
		
		# find and replace parts of the newly copied colvars configuration file, as colvars will not accept environment variables like CHARMM/VMD/NAMD 
		# you'll need to do this for the drug cage restraint file location and the backbone restraint file location, as these will be unique to the simulation.
		# you'll also need to replace the Z component of the dummy atom position to be the desired position (current umbrella position) if you're performing umbrella sampling of the drug along the channel axis
		# see the lab handout for the `sed` command 
	
	
	# pre-emptively create your input file for WHAM
		# the format for the WHAM input file is that every line follow this pattern: `/path/to/timeseries/file loc_win_min spring`
		# should be something like the following, depending on how you name your variables and organize your files: 
		echo "output/$outputPattern/$outputPattern.colvars.traj $umbrellaPosition $colvarsForceConstant" >> output/${channel}_${drugName}_whamInput.inp 
		# as written, the above will append to the file if it already exists, or create a new file if it doesnt. Ensure this file does not already exist before running this script. Or you could probably make a clever `if` statement if you don't want to worry about it. 
	
	
	# run the code 
		# add the drugs and create comparison sets `
		# make sure your output file names, etc. aren't hard-coded in these files!
		./bash.pt2_adddrug.sh
		./bash.pt3_compsets.sh
		
		# request a node with `sbatch` and perform the simulation for the current umbrella window
		# make sure your output file names, etc. aren't hard-coded in these files!
		sbatch bash.pt4_simulation.sh
	}
	


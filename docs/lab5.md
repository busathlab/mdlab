## LAB 5: INTRODUCTION TO DYNAMICS
###### by by [Dr. David Busath](http://busathlab.byu.edu/) and Matt Durrant

---

#### Objectives:
- Build a system, including building a water box, neutralization, and configuration of the ligand.
- Heat a system in preparation for a dynamics simulation.
- Perform a short dynamics simulation
- Analyze the simulations with simple analysis tools in VMD.

---

The molecular dynamics simulations you will perform will allow you to analyze of the effect of an electric field on the protein configuration of the **Luciferase enzyme**. Luciferase is an enzyme that produces bioluminescence in fireflies through converting luciferin and ATP into oxyluciferin and AMP, releasing a photon of light as oxyluciferin returns to ground state. The luciferase that we will be analyzing is found on PDB.org under the identifier **2D1S**. Its crystal structure contains a luciferyl-AMP intermediate within its active site.

Dr. Brian Mazzeo at BYU has conducted several experiments where he analyzed the effect of an electric field on luciferase fluorescence. His experiments are currently inconclusive, but dynamics simulations could certainly offer further insight. The dynamics simulations you perform in this lab should demonstrate how the protein and ligand react to a strong electric field.

### 1. Molecular Dynamics Background
Energy minimizations are designed to find the energy wells for static molecules based only on the potential energy. **Molecular dynamics** allow you to also look at changes that increase the entropy of an entire system, and provides a much more flexible search of conformational space. We will further explore entropy in the lab on perturbational techniques later in the course.

Dynamics runs typically take a long time. In research, we commonly write CHARMM scripts that do the calculation for us and leave them running for weeks at a time. This lab will not take that long. It is important that you look over the example stream file and understand it, but not that you understand all of the variables set in the dynamics command. Many of these commands are preserved from script to script. In fact, many have found that the easiest way of writing a CHARMM script is to use an old one as a template. That is what is expected for you to do here. 

Dynamics simulations have a few common outputs including the following file types:
1. **.DCD**: These are the files with the Dynamics CoorDinates. They tend to take up a lot of memory.
2. **.RST**: These are the ReSTart files. They contain info (coordinates,  velocities, and periodic cell information) for continuing the dynamics from this point.
3. **.CRD**: Dynamics runs save the final CooRDinates of each sub-section to CRD files.

Molecular dynamics simulations are typically broken down into three phases (typically in three separate simulations): 
1. Heating
2. Equilibration
3. Production (Simulation)

#### Heating
Simulations begin with heating--the temperature is increased, in this case, from 0 K to 300 K in 3000 steps of dynamics. In this phase, a random velocity is assigned to each of the atoms in the molecule corresponding to the current temperature. This temperature is increased incrementally as the run progresses. You are not limited to 300 K. You could heat to 1000 K if desired. Some people do this as a way to search areas of conformational spaces that are separated by high energy barriers. One could also take a molecule at 1000K and heat it with negative temperature increments back down to 300 K. This is called **simulated annealing** and is similar to minimization. We will stick with standard heating for the purposes of this lab.

#### Equilibration
Equilibration comes next. Why is this needed? As you give atoms kinetic energy, the bonds will stretch and compress, angles will bend back and forth, etc. If we gave the molecule kinetic energy and let it go, we would find that some of this energy will actually become potential energy. This is exactly what physicists are talking about when they mention the thermodynamic principle of energy equipartition. In our case the net effect is that energy goes sloshing back and forth from kinetic to potential causing the temperature to fluctuate for the molecule. When the conformation or configuration of the system changes, the potential energy changes causing a shift in the kinetic energy, and hence, the temperature. To correct for this you will run an equilibration run. This periodically measures the temperature and scales the velocity back to the equilibration temperature (300K). After a while, this will get the large fluctuations to decrease, but you cannot ever get them to go below a certain level. This is normal and even realistic, as temperature is an average quantity anyway.

A good way to measure equilibration is to track the root-mean-square-deviation of the molecule(s) of interest. Once significant deviations have "plateau'd", so to speak, the system is ready for production simulations and data tracking / analysis. 

#### Production
The production phase of molecular dynamics is often just a continuation of the equilibration phase, but now the data is kept and analyzed as the system is properly equilibrated. 

The main drawback of molecular dynamics is the amount of time required to perform simulations. Most reactions take place on the microsecond or millisecond time scale, which requires a substantial amount of computing power and resources to effectively simulate for most applications.

### 2. Building the System
A crucial step in performing dynamics simulations is to properly set up your system. This includes solvation (surrounding the protein in generated water molecules), neutralization (adding ions to give the system a net charge of 0), and performing energy minimizations. The complexity of this process depends on the complexity of the dynamics simulation you wish to perform.

#### Prepare the Protein and Ligand
The "combine_protein_lig.inp" script inside the directory "1_put_ligand_in_protein" is a simple input script that combines the protein and the ligand in one coordinate file and performs some minimizations on the system. Open the script and answer the following question:

> **Question 1**: Describe this script. What are its inputs? What is being manipulated and why? What is the output?

Make sure the submission script’s input and output files are designated correctly and execute the submit script. The output is a CRD and PSF that contain the protein with the ligand in the active site. Feel free to view the output in VMD.

#### Solvation
This is a very simplified solvation script. The 100x100 angstrom water box has already been generated by [CHARMM-GUI](http://charmm-gui.org/). You can generate your own water box in CHARMM, but using the CHARMM-GUI can speed things up a bit. Make sure the solvation script refers to the psf and crd you generated previously. Open "solvator.inp" and take a look at the script. You’ll notice a deletion command that is written as follows:

```fortran
delete atom sort -
select .byres. (resn TIP3 .AND. type oh2 .and. -
((.not. (resn TIP3 .OR. hydrogen)) .around. 2.8)) end
```

> **Question 2**: What is this deletion doing? Why is this important?

Execute the submission script to solvate the molecule.

> **Question 3**: How many water molecules did you generate?

#### Neutralization
Dr. Mazzeo performed his experiments in a solution with 0.2M ammonium sulfate. For the purpose of our experiment, we’ll be using potassium chloride. Using CHARMM-GUI, it was determined that 108 KCl molecules will result in a 0.2M concentration. However, the protein carries a net charge of +1, so a total of 109 Cl- ions are necessary to neutralize the system.

Run the "neutralize.inp" script. This script streams 3 additional subscripts: "watervars.str", "ioncoor.str", and "watercolor.str". These three scripts identify 217 water molecules to delete through randomly generated numbers, making room for the ions to be added. The water ions are then deleted, and the ions replace the waters’ former positions with 2 exceptions: 2 Cl- ions are added within the protein to take the place of chloride ions that were found in the original pdb script.

### 3. Dynamics

#### Heating
The system must be heated to room temperature prior to simulation. Open the folder "4_minimize_heat" in WinSCP and open the submit file "batch.submit". This file submits your script to the Fulton supercomputer. The line `#SBATCH -N1 -n16 --mem-per-cpu=2G -t10:00:00 -C 'm7'` designates several important settings for your submission. `–N1` refers to the number of nodes that you’ll run your script on. Generally speaking, the more nodes you request the faster your script will run. `–n16` refers to the total number of processors requested across all nodes. `–mem-per-cpu` requests the amount of RAM per CPU, which is usually kept at 1G or 2G. `–t10:00:00` designates the amount of time you anticipate your script to run. `-C ‘m7’` designates that we’ll be running our scripts on the m7 partition of the supercomputer (see [sbatch documentation](https://slurm.schedmd.com/sbatch.html)).

> This lab was written in 2014--you may have to choose a new partition to run on or simply delete the `-C` distinction. You may find the [FSL submission script generator](https://marylou.byu.edu/documentation/slurm/script-generator) to be helpful

Open the input file "minimize_heat.inp". Scroll down to the `! CRYSTAL` portion of the script. This command generates an infinite crystal of our system. This will allow the system to remain confined to a cubic structure, and the outer edges of the cube will factor in the Van der Waals of the molecules that are within 14 angstroms of the outer edge.

> **Question 4**: Describe the command `crystal defi cubi 100.0 100.0 100.0 90.0 90.0 90.0`. What do you think each item designates?

View the `! CONSTRAINTS` portion of the script. Three constraints will be applied in this script. We’ll initially apply a harmonic constraint on the protein, to ease the impact of the electric field. `PULL EFIELD 1E9 XDIR 1.0 SELE ALL END` ([cons.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/cons/)) creates our 1E9-volt electric field constraint in the X-direction, which is applied to the whole system. Finally, we must apply a center-of-mass constraint to the protein, which will prevent the charged luciferase enzyme from migrating through the water box as a result of the electric field.

View the `! MINIMIZATION` portion of the script.

> **Question 5**: What kind of minimizations are being performed and how many steps of each?

View the `! HEAT SYSTEM TO 300` segment of the script. You can see that two files are opened for writing: 0.rst and 0.dcd. After these files are opened, our heating script follows:

```fortran
dynamics cpt leap verl strt nstep 40000 time 0.0015 -
iunrea -1 iunwri 31 iuncrd 32 -
isvfrq 2000 nsavc 200 nsavv 0 -
inbfrq -1 nprint 250 iprfrq 0 ntrfrq 100 -
pcon pgam 25 pmass 500 pref 1.0 surface tension 0.0 -
ihtfrq 2 teminc 0.06 -
imgfrq 50 ixtfrq 1000 cutim 14 -
iasors 0 iasvel 1 iscvel 1 iseed 1 -
firstt 0.0 finalt 300.0
```

There are several values we need to understand when running this heating script ([dynamc.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/dynamc/)):

- `dynamics cpt leap verl strt`: this begins our dynamics simulation as a constant pressure and temperature (cpt) leap verlet simulation.
- `nstep 40000`: this designates the number of steps to be performed.
- `time 0.0015`: this designates the length in time (in picoseconds) of a single step, or how long a simulation is allowed to move before the velocities of the system are recalculated and adjusted. .0015 picoseconds, or 1.5 femtoseconds.
- `nsavc 200`: this determines the number of steps before the coordinates are saved to the .dcd file
- `iunwri 31`: this will write our RESTART file to the open unit 31. Restart files are essential for restarting our simulations from where our previous simulation finished off.
- `iuncrd 32`: this will write our .dcd file to the open unit 32.
- `pcon`: this command and its subsequent values designate that the simulation will run under constant pressure.
- `firstt 0.0 finalt 300.0`: this will heat our script from 0.0 K to 300.0 K.

> **Question 6**: How many picoseconds of simulation would be carried out with the current script?

Now run the script. Submit your script to the supercomputer in the UNIX console by typing `sbatch batch.submit`.

You can view the queue status of your simulation by typing in the command line `watch squeue –u [username]`. This script will take several hours to complete, if you do not make any changes to the submit script.

#### Equilibration
We are now going to start the equilibration phase. Open the folder "5_simulate", and the input file "1E9_sim". You’ll notice that this file is very similar to the heating script, without the minimizations. The differences are primarily in the dynamics simulation. Notice the differences in the dynamics settings:

```fortran
dyna cpt leap restart nstep 100000 timestep 0.0015 -
nprint 100 iprfrq 5000 ntrfrq 5000 -
iunrea 30 iunwri 31 iuncrd 32 -
nsavc 1000 nsavv 0 -
imgfrq 50 ixtfrq 1000 cutim 14 -
pcons pint pref 1.0 pmass 500 pgamma 0 -
hoov reft 300 tmass 2000.0 tbath 300 firstt 300 finalt 300
```

> **Question 7**: What are the differences between this simulation and the heating script? Ask your TA what these differences mean, or look them up.

You’ll notice that there are various folders within "5_simulate". This is necessary to organize the output files of our simulation. To perform a long simulation we have to pause the simulation and restart it from where we left off. This is to decrease the amount of consecutive wall time on the supercomputer, and to protect us from having to restart the entire simulation should an error occur.

Now prepare the submission script for equilibration. If you want to perform this simulation yourself, the equilibration should take a few days to complete, depending on the resources you request. Luckily, we have the finished product already available to you in the directory `charmmlab/lab_files/luciferase_output`.

### 4. Analysis
We will use VMD to perform an analysis of the Root-Mean-Square Deviation (RMSD), as well as graph the distance between two residues over time.

#### RMSD Analysis
In WinSCP (or scp transfer program of your choice), transfer the "system_min.psf", "1.crd", and "1.dcd" files onto your local computer. When complete, open VMD on your computer. Go to `File > New Molecule`. Load "1.crd", be sure to specify that the file contains CHARMM coordinates in the drop down menu. Load "system_min.psf" and "1.dcd" into the molecule.

Once all the frames are loaded, go to `Extensions > Analysis > RMSD Visualizer Tool`. In the new window, type `all segid PROA` in the atom selection dialogue box. Next, click `ALIGN` and then `RMSD`. Select `Plot Result.`

> **Question 8**: Describe the data that you see. What causes the changes in RMSD?

#### Distance between Atoms over Time
This is another easy analysis that graphs the distance between atoms over time. Create a bond in VMD between any atom in the ligand and an atom near it in the surrounding luciferase pocket. Then go to `Graphics > Labels`, select your bond, click the `Graph` tab, and Click the `Graph` Button.

> **Question 9**: Describe the data that you see, and propose a possible conclusion.

**[Lab 6](https://busathlab.github.io/mdlab/lab6.html)**

**[Return to home page](https://busathlab.github.io/mdlab/index.html)**
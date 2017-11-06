## NAMD LAB 1: INTRODUCTION TO NAMD AND THE COLLECTIVE VARIABLES MODULE
###### by [Mitch Gleed](https://www.linkedin.com/in/mitchell-gleed-65a8b03b/)

---

#### Objectives:
- Learn how to launch NAMD on FSL
- Learn how to edit NAMD configurations
- Implement a basic restraint using the Collective Variables module
- Perform equilibration and production simulations of Leptin in solvent using NAMD 
- Analyze Collective Variables output to determine adequacy of equilibration

---

> Those going through these NAMD labs should either have completed all the CHARMM labs or otherwise have a strong knowledge of CHARMM and Linux commands. CHARMM will be used often for system setup and coordinate manipulation, while NAMD will be used mostly for simulation.

In this lab we will be studying the [leptin protein](https://pdb101.rcsb.org/motm/149), a anorexigenic hormone produced by adipose cells. Patients with type-2 diabetes mellitus have not only insulin resistance, but also leptin resistance, which can drive hunger. A lot of research has been as is being done on leptin in the fight against the obesity epidemic.

Since the peptide is small, it serves as a good starting point for learning NAMD, as simulations don't require too much time to complete.

> You may find it helpful to use WinSCP with integrated Notepad++ support and use split windows on a screen or dual monitors for this lab, though it certainly isn't required. 

### 1. Compare CHARMM and NAMD equilibration protocols
We will use our background in molecular modeling and dynamics with CHARMM to compare, side-by-side, CHARMM stream files to NAMD configuration files to learn how NAMD functions.

Begin by copying the lab files to your personal directory, in order to prevent overwriting the original files. You will see that the namd_lab1 directory contains PDB, PSF, CRD, and XPLOR PSF files for Leptin; Bash files for executing files and submitting jobs to the scheduler; CHARMM stream files for equilibration and production dynamics; and NAMD configuration files that perform the same function. The directory "namdrestraints" contains files important for the Collective Variables Module, or colvars, which we will dive into briefly. The "output" directory is divided into output for CHARMM and NAMD respectively.

Begin by opening "charmm.eq.str" and "namd.eq.inp" side-by-side, using either two terminal windows with `vi` or two Notepad++ windows. We will go through the equilibration phase of these scripts together, and the production phase scripts you will compare and run on your own. 

Before digging into these files, take a brief overview of each. What patterns do you notice? Do you see any familiar patterns in NAMD? 

One large distinction is that CHARMM scripts are very order-dependent--commands are executed chronologically. On the other hand, the NAMD configuration file is really a large "definition" file in which you describe the starting conditions of a run, and order of parameters matter less. This is somewhat of an oversimplification, but it sheds light on some of the advantages/disadvantages of each. 

Another advantage of NAMD is that the configuration files are written in TCL, so you can use as much TCL code as you like in the configuration file (for calculations, etc.). VMD command line is also based on TCL, making integration of the two seamless.

#### Topology and Parameters 
Typically among the very first things in any CHARMM script is loading topology and parameter files, and it won't take you long to find the analogous location in the NAMD configuration file.

###### CHARMM:

```fortran
! Read topology and parameter files
	set topparloc /panfs/pan.fsl.byu.edu/scr/grp/busathlab/toppar_c36_aug14
	stream @topparloc/load_toppar.str
```

###### /panfs/pan.fsl.byu.edu/scr/grp/busathlab/toppar_c36_aug14/load_toppar.str 
```fortran 
* Stream file for topology and parameter reading
* Modified by Mitchell Gleed 22 Oct 13
*

! protein topology and parameter
open read card unit 10 name @topparloc/top_all36_prot.rtf
read  rtf card unit 10

open read card unit 20 name @topparloc/par_all36_prot.prm
read para card unit 20 flex

! lipids
open read card unit 10 name @topparloc/top_all36_lipid.rtf
read  rtf card unit 10 append

open read card unit 20 name @topparloc/par_all36_lipid.prm
read para card unit 20 append flex

! CGENFF
open read card unit 10 name @topparloc/top_all36_cgenff.rtf
read rtf card unit 10 append

open read card unit 20 name @topparloc/par_all36_cgenff.prm
read para card unit 20 append flex

stream @topparloc/toppar_water_ions.str
```

###### NAMD:

```tcl
# Force-Field Parameters
paraTypeCharmm     on;
parameters          $topparloc/par_all36_prot.prm
parameters          $topparloc/par_all36_lipid.prm
parameters          $topparloc/par_all36_cgenff.prm
parameters          $topparloc/par_all36_water_ions.prm
```

Notice NAMD depends on parameter files, but, unlike CHARMM, it does not require topology files! CHARMM PSF files do not, by default, contain atom connectivities, etc. that are described in topology files, so CHARMM must load these in. However, NAMD uses XPLOR PSF files, which do contain topologies of the molecules for each system, making the topology files redudant in NAMD. 

#### PSF and Coordinates
Now let's compare how coordinates and PSF's are loaded:

###### CHARMM:

```fortran
! Read PSF
	open read unit 10 card name leptin.psf
	read psf  unit 10 card xplor

! Read Coordinates
	open read unit 10 card name leptin.crd
	read coor unit 10 card
```

###### NAMD:

```tcl
structure          leptin.xplor.ext.psf
coordinates        leptin.pdb
```

What a relief, NAMD doesn't have the trouble Fortran units! However, only one set of coordinates can be loaded in NAMD, unlike CHARMM where you can append coordinates and PSF's. In other words, your system needs to be completely set up and ready before running NAMD. 

Another important difference is that CHARMM can use PDB or CRD formatted coordinate files, while NAMD uses PDB format coordinates or NAMD binary .coor files. And, as discussed previously, CHARMM can read both XPLOR and standard PSF's, while NAMD requires XPLOR PSF's. 

#### Periodic Boundaries and Molecule Wrapping
Next on the comparison is how CHARMM and NAMD set up periodic conditions. 

###### CHARMM:

```fortran
! Setup PBC (Periodic Boundary Condition)
	crystal defi cubi 72 72 72 90.0 90.0 90.0
	crystal build cutoff 14 nope 0
! Image centering by residue
	IMAGE BYRESID XCEN 0 YCEN 0 ZCEN 0 sele resname TIP3 end
	IMAGE BYRESID XCEN 0 YCEN 0 ZCEN 0 sele ( segid SOD .or. segid CLA ) end
```

###### NAMD:

```tcl
# Periodic Boundary conditions
cellBasisVector1	*REPLACE*	0.0			0.0;
cellBasisVector2	0.0		*REPLACE*	0.0;
cellBasisVector3	0.0		0.0			*REPLACE*;
cellOrigin		0.0			0.0		0.0;

wrapWater           on;
wrapAll             on;
wrapNearest        off;
```

Given your knowledge of CHARMM, it should be trivial to figure out what values belong in place of `*REPLACE*`, especially when the crystal type is a cube. See the NAMD user guide section on [Periodic Boundaries](http://www.ks.uiuc.edu/Research/namd/2.12/ug/node33.html) for more information.

One difference between CHARMM and NAMD is that CHARMM gives more flexibility in what atoms are wrapped or centered using selection syntax. NAMD provides options to wrap water molecules or all molecules around periodic boundaries. These options should not affect the simulation in any drastic way, but they will affect how trajectories and output appear, and may influence time series coordinate information.

#### Non-bonded options and Particle Mesh Ewald

###### CHARMM:

```fortran
! Nonbonded Options
	nbonds atom vatom vfswitch bycb -
		ctonnb 10.0 ctofnb 12.0 cutnb 16.0 cutim 16.0 -
		inbfrq -1 imgfrq -1 wmin 1.0 cdie eps 1.0 -
		ewald pmew fftx 72 ffty 72 fftz 72 kappa .34 spline order 6
	energy
```

###### NAMD:

```tcl
exclude             scaled1-4 
1-4scaling          1.0
switching            on
vdwForceSwitching   yes;
cutoff              *REPLACE*;
switchdist          10.0;
pairlistdist        16.0;
stepspercycle       20;
pairlistsPerCycle    2;

# PME (for full-system periodic electrostatics)
PME                yes;
PMEGridSpacing      1.0	               # lets NAMD determine the PME dimensions automatically
PMEInterpOrder       *REPLACE*;                # interpolation order (spline order in charmm)


```

Again, CHARMM wins with flexibility and amount of options, as evidenced here when adjusting non-bonded options and energy. However, NAMD simplifies the process significantly. Given the CHARMM comparison, can you figure out the values of the two instances of `*REPLACE*`? 

Particle Mesh Ewald lengths are also required to be input manually in CHARMM, while in NAMD, the integers are computed automatically (though they can be input manually if desired).

#### Minimization

Another drastic change is how minimization is handled in CHARMM vs NAMD. 

###### CHARMM:

```fortran
mini SD   nstep 50 nprint 5
mini ABNR nstep 50 nprint 5
```

###### NAMD:

```tcl
minimize 10000
```

If you desire a careful minimization protocol, it would be best to do it in CHARMM. I will list a few of the main differences I have observed:
- CHARMM minimization is excluded from the DCD trajectories by default, though you can make trajectories with SD minimization, if desired. NAMD includes minimization coordinates in the output DCD file by default.
- You can specify the methods of minimization in CHARMM, while NAMD uses a "sophisticated conjugate gradient and line search algorithm."
- You can apply restraints just for minimization and release them for equilibration dynamics in CHARMM in one script, while multiple scripts are required to do this in NAMD. 

> I'm not sure why CHARMM-GUI, the program that provided these scripts, chose to do 100 total steps of minimization with CHARMM and 10,000 steps of minimization with NAMD. 

#### Dynamics

One of the nicer features of NAMD is how simplified the dynamics process is, especially compared to the complicated `DYNA` commands of CHARMM. However, ease vs. flexibility comes into play here, as usual. 

###### CHARMM:

```fortran
	set nstep 25000
	set temp 310
	
	shake bonh param fast
	
	open write unit 12 card name output/charmm/leptin_eq.rst
	
	DYNA VVER start timestep 0.001 nstep @nstep -
		nprint 1000 iprfrq 1000 ntrfrq 1000 -
		iunread -1 iunwri 12 iuncrd -1 iunvel -1 kunit -1 -
		nsavc 0 nsavv 0 -
		nose rstn tref @temp qref 50 ncyc 10 firstt @temp
	
	open write unit 10 card name output/charmm/leptin_eq.pdb
	write coor unit 10 pdb
	
	open write unit 10 card name output/charmm/leptin_eq.crd
	write coor unit 10 card
	close unit 10
	
	open write unit 40 card name output/charmm/leptin_eq.xtl
	write title unit 40
	* set xtla ?xtla
	* set xtlb ?xtlb
	* set xtlc ?xtlc
	*			
```

###### NAMD:

```tcl
set temp           *REPLACE*;
set outputname 	   output/namd/leptin_eq;
outputName         $outputname;
firsttimestep        0;
restartfreq        500;
dcdfreq           1000;
dcdUnitCell        yes; 
xstFreq           1000;
outputEnergies     125;
outputTiming      1000;

...
									   
# Integrator Parameters
timestep            2.0;               # fs/step
rigidBonds          all;               # Bound constraint all bonds involving H are fixed in length
nonbondedFreq       1;                 # nonbonded forces every step
fullElectFrequency  1;                 # PME every step

# Constant Temperature Control ONLY DURING EQUILB
reassignFreq        500;               # reassignFreq:  use this to reassign velocity every 500 steps
reassignTemp        $temp;

...

# Pressure and volume control
useGroupPressure       yes; 
useFlexibleCell        no;
useConstantRatio       no;

langevin                on
langevinDamping         1.0
langevinTemp            $temp
langevinHydrogen        off

# constant pressure
langevinPiston          on
langevinPistonTarget    1.01325
langevinPistonPeriod    50.0
langevinPistonDecay     25.0
langevinPistonTemp      $temp

...

run 25000
```

For the equilibration phase, both CHARMM and NAMD are performing simulation with the NPT ensemble, hence the `DYNA VVER` command by CHARMM. Again, notice here that NAMD is essentially a list of variable definitions, and the `run` command at the end reads these. You can perform `run` as many times as you like without having to repeat code! Also, by specifying `outputName` in NAMD, all of your output files will have that pattern and be created automatically, which is significantly easier than CHARMM.

Another thing to notice is that NAMD uses the timestep 2.0. CHARMM is capable of a 2.0 timestep, but is known to be less stable than NAMD at such a large timestep, especially during the heating/eq phase. This is another significant advantage of NAMD over CHARMM in improving quantity of sampling.

### 2. Collective Variables Module

Let's start by considering how CHARMM implements constraints, in a simple fashion using `SELECT` and `CONS HARM`. 

###### CHARMM constraints:

```fortran
	define PROT sele ( segid PROA ) end
	
	define BB   sele ( ( type C   .or. type O   .or. type N   .or. type CA ) .and. PROT ) end
	define SC   sele .not. BB .and. .not. hydrogen .and. PROT end
	
	cons harm force 1.0 sele BB end
	cons harm force 0.1 sele SC end
```

This approach allows for a *huge* amount of flexibility compared to NAMD. NAMD has no feature like the CHARMM `SELECT` function. However, let's not discount NAMD yet!

#### About Colvars 

The **Collective Variables Module (Colvars)** is how restraints are implemented in NAMD, and it is an extremely powerful, useful tool. It is an open-source module separate from NAMD that NAMD adopted several years ago. [It is also used in LAMMPS and VMD](https://colvars.github.io/). Updates and optimizations are performed continuously, and, in my opinion, it is the most invaluable part of NAMD. You can implement center-of-mass, RMSD, planar, distance, dihedral, etc. restraints; generated time series automatically; generate correlations automatically; implement moving biases (steered molecular dynamics); and much more. [Look here to see all the possibilities](https://colvars.github.io/colvars-refman-namd/colvars-refman-namd.html). 

With Colvars, you can have comparison sets automatically align to restrained atoms to correct for axial deviations. For example, if channel axis of a transmembrane protein deviates from the Z axis, and a drug inside the channel has a restraint along the Z axis applied, the restraint will be corrected as if the channel were along the Z axis throughout the simulation.

Compared to CHARMM, it isn't very easy to implement restraints, but the number of features provided by the Colvars module makes it arguably superior.

Collective variables are used for measurement, and harmonic forces can be applied to collective variables to make restraints. For example, you can use the module to measure the distance between two atoms of interest, and you can also apply a harmonic restraint to it to keep those two atoms at a desired distance.

#### Using Colvars 
To use Colvars, you need a separate configuration file where the variables are defined. You also need the following lines in your NAMD configuration file, where [colvars config file] is the location of the configuration file:

```tcl
colvars on
colvarsConfig [colvars config file]
```

For the equilibration portion of this lab, that file is `namdrestraints/namd.restraintsetup_eq.col`. Open the file and examine the contents. 

At the start of the file, `Colvarstrajfrequency` determines how often time series data is output for all of the collective variables. `Colvarsrestartfrequency` is the frequency with which restart information is written. 

###### Collective variable definition 

A collective variable is defined by `colvar` with a name and a type, the type of which has nested brackets. There are more many more options that can be included here, but for simplicity, these are all that will be discussed here. 

The first colvar in this file is named `bb_rmsd`. The atom selection to be included in the colvar is found within a PDB-formatted file, `atomsFile`. Open `namdrestraints/bb_rmsd.ref` and you will see what this means:

```fortran
REMARK  GENERATED BY CHARMM-GUI (HTTP://WWW.CHARMM-GUI.ORG) V2.0 ON NOV, 04. 2017. JOB
REMARK  INPUT GENERATION                                                              
REMARK   DATE:    11/ 4/17     16:46:36      CREATED BY USER: apache                  
ATOM      1  N   ILE     3      20.590   3.971  -2.837  1.00  1.00      PROA
ATOM      2  HT1 ILE     3      20.217   4.634  -3.567  1.00  0.00      PROA
ATOM      3  HT2 ILE     3      20.931   3.145  -3.375  1.00  0.00      PROA
ATOM      4  HT3 ILE     3      21.455   4.386  -2.426  1.00  0.00      PROA
ATOM      5  CA  ILE     3      19.568   3.496  -1.910  1.00  1.00      PROA
ATOM      6  HA  ILE     3      18.826   2.966  -2.492  1.00  0.00      PROA
ATOM      7  CB  ILE     3      20.167   2.515  -0.900  1.00  0.00      PROA
ATOM      8  HB  ILE     3      20.602   1.643  -1.449  1.00  0.00      PROA
ATOM      9  CG2 ILE     3      21.252   3.201  -0.094  1.00  0.00      PROA
ATOM     10 HG21 ILE     3      20.847   3.958   0.612  1.00  0.00      PROA
ATOM     11 HG22 ILE     3      22.038   3.663  -0.721  1.00  0.00      PROA
ATOM     12 HG23 ILE     3      21.777   2.450   0.541  1.00  0.00      PROA
ATOM     13  CG1 ILE     3      19.078   1.964   0.016  1.00  0.00      PROA
ATOM     14 HG11 ILE     3      18.277   1.505  -0.610  1.00  0.00      PROA
ATOM     15 HG12 ILE     3      18.604   2.767   0.631  1.00  0.00      PROA
ATOM     16  CD  ILE     3      19.581   0.924   0.989  1.00  0.00      PROA
ATOM     17  HD1 ILE     3      20.241   1.367   1.767  1.00  0.00      PROA
ATOM     18  HD2 ILE     3      20.142   0.122   0.460  1.00  0.00      PROA
ATOM     19  HD3 ILE     3      18.731   0.449   1.525  1.00  0.00      PROA
ATOM     20  C   ILE     3      18.819   4.601  -1.162  1.00  1.00      PROA
ATOM     21  O   ILE     3      17.616   4.487  -0.926  1.00  1.00      PROA
ATOM     22  N   GLN     4      19.514   5.677  -0.810  1.00  1.00      PROA
ATOM     23  HN  GLN     4      20.508   5.662  -0.750  1.00  0.00      PROA
ATOM     24  CA  GLN     4      18.871   6.779  -0.103  1.00  1.00      PROA
```

The column immediately to the left of PROA is column "B" and to the left of that is column "A". Notice that all the protein backbone atoms have a value of "1" in the "B" column. Not coincidentally, this is the value of `atomsColValue` in our restraint configuration file. Therefore, all atoms with a value of "1" in the "B" column will be included in the collective variable. 

The `refPositionsFile` and the two parameters beneath it work in a similar fashion, but rather than tell the module which should be included in the restraint, they give the reference coordinates. For the `rmsd` type of collective variable, this is analagous to a comparison set in CHARMM, where atoms in `refPositionsFile` with column "B" equal to "1" identify the coordinates to compute RMSD from. 

The VMD command line is the easiest way to create PDB reference files for use by the Collective Variables Module, and that will be demonstrated in a future lab. Otherwise, using a text editor that supports vertical editing, such as Notepad++ (column mode), can make manual edits feasible. 

###### Applying a harmonic restraint to a collective variable 

Next in the file is a block labeled `harmonic`. Here, a harmonic force with a constant of `forceConstant` centered at `centers` is applied to the colvar `colvars`; i.e., a 1.0 force constant is applied to bb_rmsd with a center of 0 (to keep the RMSD near 0).

If desired, multiple colvars could be listed within the same harmonic block. In this case, there are two harmonic blocks because two different force constants are applied to the protein backbone and protein side chains.

### 3. Equilibrate

Now that the basic usage of NAMD and the collective variables module have been explained, let's get to simulating!

The CHARMM equilibration file is set and ready to go, so we will get that simulation started and running and then work on finishing the NAMD configuration file. Open "bash.eq_charmm.sh" and ensure the SBATCH parameters are as desired, save and quit, and then run `sbatch bash.eq_charmm.sh`. Ensure the job starts and runs using the command `watch squeue -u [username]`, replacing [username] with your username (to exit this view, press Control+C).

Now that the CHARMM job is running, open "namd.eq.inp" and fill in any remaining `*REPLACE*` instances. Use the "charmm.eq.str" file for reference, if needed. Take another run through the script to get an idea of how the configuration file works, now that you've learned about it. 

When you are confident the file is ready, open "bash.eq_namd.sh". In this file you will see the variable `namddir`, which shows where the NAMD executable resides. The next line shows how to launch NAMD. The basic pattern is `namd2 [inputFile] > [outputFile]`, but the command shown here is optimized for this particular build of NAMD has has been benchmarked on FSL to be the best NAMD build for single-node jobs. (Therefore this would not work if ``--nodes`` were set to greater than 1). Running NAMD on multiple nodes or on GPU nodes will be covered in future labs.

Once you have familiarized yourself with how to launch NAMD, ensure the SBATCH parameters are as desired, save and quit, and then run `sbatch bash.eq_namd.sh`.

Check on the status of the jobs with `watch squeue -u [username]` again. If they are still running, go ahead and move on to the next section and come back later to answer the following questions: 

> **Question 1**: Are you satisfied with the amount of equilibration performed? Plot the data in the file `output/namd/leptin_eq.colvars.traj` and include a snapshot of your diagram in your submission to the TA. 

> **Question 2**: After addressing the previous question, provide an explanation for the drastic change in the pattern of Y. (Hint: Carefully examine the timestep it occurs near.)

### 4. Dynamics 

If the CHARMM run has completed, go ahead and open "bash.production_charmm.sh", ensure the SBATCH parameters are as desired, save and exit, and run `sbatch bash.production_charmm.sh`. Otherwise, return to this after editing the NAMD production files.

Open "namd.production.inp" and examine the contents. Notice there are a lot more `*REPLACE* areas to be filled. Use whatever scripts necessary to fill these in. Also notice the difference between equilibration and production:

```diff
- # Constant Temperature Control ONLY DURING EQUILB
- reassignFreq        500;
- reassignTemp        $temp;
```

For this portion of the lab, you will also need to open and adjust "namdrestraints/namd.restraintsetup_production.col" to create a center-of-mass restraint between the protein backbone and the coordinate origin with a force constant of 1.0 and width of 0.   

Finally, adjust the final command in "bash.production_namd.sh". Use the submission script for the equilibration phase for reference. Keep the SBATCH paramters the same as the CHARMM production script. When you are satisfied, execute `sbatch bash.production_namd.sh`. 

Check on the status of the jobs with `watch squeue -u [username]`. Once they have completed, answer the following questions:

> **Question 3**: How much faster did the simulation run with NAMD? Refer to the logs from both the NAMD production run and CHARMM production run.

> **Question 4**: Plot the bb_rmsd colvar from the production run and include a snapshot of the diagram in your submission to the TA.

**[NAMD Lab 2](https://busathlab.github.io/mdlab/namd_lab2.html)**

**[Return to home page](https://busathlab.github.io/mdlab/index.html)**



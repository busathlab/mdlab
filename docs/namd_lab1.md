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

### 1. Equilibration
We will use our background in molecular modeling and dynamics with CHARMM to compare, side-by-side, CHARMM stream files to NAMD configuration files to learn how NAMD functions.

Begin by copying the lab files to your personal directory, in order to prevent overwriting the original files. You will see that the namd_lab1 directory contains PDB, PSF, CRD, and XPLOR PSF files for Leptin; Bash files for executing files and submitting jobs to the scheduler; CHARMM stream files for equilibration and production dynamics; and NAMD configuration files that perform the same function. The directory "namdrestraints" contains files important for the Collective Variables Module, or colvars, which we will dive into briefly. The "output" directory is divided into output for CHARMM and NAMD respectively.

Begin by opening "charmm.eq.str" and "namd.eq.inp" side-by-side, using either two terminal windows with `vi` or two Notepad++ windows. We will go through the equilibration phase of these scripts together, and the production phase scripts you will compare and run on your own. 

Before digging into these files, take a brief overview of each. What patterns do you notice? Do you see any familiar patterns in NAMD? 

One large distinction is that CHARMM scripts are very order-dependent--commands are executed chronologically. On the other hand, the NAMD configuration file is really a large "definition" file in which you describe the starting conditions of a run, and order of parameters matter less. This is somewhat of an oversimplification, but it sheds light on some of the advantages/disadvantages of each. 

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

##### NAMD:

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
cellBasisVector2	0.0			*REPLACE*	0.0;
cellBasisVector3	0.0			0.0			*REPLACE*;
cellOrigin          0.0			0.0			0.0;

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

Again, CHARMM wins with flexibility and amount of options, as evidenced here when adjusting non-bonded options and energy. However, NAMD simplifies the process significantly. Given the CHARMM comparison, can you figure out what should go in the stead of `*REPLACE*`? 

Particle Mesh Ewald lengths are also required to be input manually in CHARMM, while in NAMD, the integers are computed automatically (though they can be input manually if desired).

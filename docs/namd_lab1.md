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

#### Topology and coordinates 
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


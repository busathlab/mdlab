## NAMD LAB 3: LIGAND UMBRELLA SAMPLING IN A PROTEIN-BILAYER SYSTEM 
###### by [Mitch Gleed](https://www.linkedin.com/in/mitchell-gleed-65a8b03b/)

## WORK IN PROGRESS

---

#### Objectives:
- yes
- no

---

**To complete this lab, you must have completed the [previous lab](https://busathlab.github.io/mdlab/namd_lab2.html).**

The purpose of this lab is to provide an introduction to umbrella sampling using NAMD. You will use the system you created and equilibrated from CHARMM-GUI in the previous lab and perform umbrella sampling of a drug of choice in that system. 

See [this CHARMM lab](https://busathlab.github.io/mdlab/lab6.html) for a background and discussion of umbrella sampling and the potential of mean force.

### 1. Reaction coordinate

From the previous lab, we have an equilibrated system of M2 protein embedded in a DMPC lipid bilayer, surrounded by 0.15 M NaCl in water. We investigated what happens when you insert a drug into the protein channel and let the system simulate for a period of time. We plotted the change in protein backbone structure (RMSD) over time and the drug adamantane cage position (Ang) along the channel axis over time. Instead of changes over time, we will now investigate intrinsic properties of the M2 channel with respect to a drug. 

Among the many possible reaction coordinates to investigate, here are two examples:
- Drug **tilt** with respect to the channel axis. At which orientations does the drug have the the lowest free energy within the channel?
- Drug **position** with respect to the channel axis. At what locations along the channel axis does the drug have the lowest free energy?

Our lab investigated the free-energy profile of amantadine in 2KQT (wild-type Amt-bound M2) using two-dimensional umbrella sampling in which both reaction coordinates were investigated. (What orientation does the drug adopt most freely at different positions along the channel axis, and what positions along the channel axis does the drug have the lowest free energy?) You can read more about that study [here](http://busathlab.byu.edu/Portals/135/Gleed%20et%20al%202015.pdf) (see Fig. 4).

This lab will investigate the free-energy profile of amantadine at different axial distances within the 2L0J M2 protein channel (2nd example above), though you may adapt the protocol to investigate other drugs, other M2 channels, or other reaction coordinates.  

### 2. Umbrella sampling workflow

Let's go over the general approach of how we will accomplish umbrella sampling in this lab using our files from the previous lab.

There are hundreds of different ways that the umbrella sampling protocol can be performed. If you are experienced and more comfortable with Python, C++, etc., you could technically do most of the template replacement, submission, and data aggregation presented here. For the purposes of the lab we will use `bash` for our code, the default Linux interpreter. You do not have to follow the methods described here if you are comfortable with coding and prefer other methods.

Here is a chart demonstrating the general workflow:
![alt text](https://github.com/busathlab/mdlab/raw/master/images/namd03_f01.PNG "Figure 1")

One approach to accomplishing this is using a master submission script. The master submission script contains all of the variables of interest and defines the reaction coordiante of interest. Its function is to loop over all of the simulation configuration files (CHARMM, VMD, NAMD, etc.; the files in the middle column of *Figure 1*) providing environment variables specific for each window along the reaction coordinate. The submission script carefully manages filenames so the output data can be intelligently extracted for analysis in WHAM.

An analysis script can be run after the simulations complete that extracts the meaningful output data and prepares files for WHAM. 

One recommended method to prepare the simulation scripts is to modify them to use environment variables wherever possible. Some scripts, like colvars, do not use environment variables, so other methods such as find and replace (using the `sed` command in `bash`) can be utilized to accomplish the same goal.

### 3. 










**[Return to home page](https://busathlab.github.io/mdlab/index.html)**
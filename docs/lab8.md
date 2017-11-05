## LAB 8: FREE-ENERGY PERTURBATION
###### by Mitch Gleed

---

#### Objectives:
- Understand the TSM perturbation syntax and methodology
- Perform TSM simulations of amantadine and rimantadine in water
- Compare ΔG from water TSM simulations to given ΔG’s from channel TSM simulations to obtain ΔΔG’s for amantadine and rimantidine.
- Analyze TSM trajectories in VMD

---

> In order to complete this lab, you must use Marylou, the BYU supercomputer.

In this lab, you will integrate the skills you have developed and the knowledge you have gained so far this semester to study the M2 proton channel of the Influenza A virus. Upon completion of this lab, you should be able to accomplish the following objectives:

### 1. Background
The M2 proton channel of the influenza viral membrane is a key component involved in viral replication. When the channel is blocked by channel inhibitors, such as Amantadine or Rimantadine, the virus cannot replicate. In mutant forms of the virus such as S31N, these drugs are no longer effective due to amino-acid changes in the M2 channel. Understanding the M2 channel is, therefore, essential in searching for new, effective anti-viral drugs.

Figure 1: a) Superior and lateral views of the M2 proton channel. b) Various adamantyl derivatives.

![alt text](https://github.com/busathlab/mdlab/raw/master/images/08_f01.png "Figure 1")

#### Free-energy Perturbation
In the umbrella sampling lab you were introduced to the idea of determining free energy along a reaction coordinate. This lab, however, focuses on determining free energy in a system using **free-energy perturbation**.

In practice, ΔG is usually calculated by comparing a difference in energy for a molecule of interest as conditions in the system change. However, in free-energy perturbation, ΔG is determined by keeping the system conditions constant and changing the molecule of interest into another molecule via piecewise mutations. For example, one might determine the ΔG for Drug A by comparing Drug A in water and Drug A in the M2 channel. The same effect can be accomplished by comparing Drug A in water to Drug B in water. 

Figure 2: Determining ΔG

![alt text](https://github.com/busathlab/mdlab/raw/master/images/08_f02.png "Figure 2")

#### TSM
CHARMM has two methods of performing free-energy perturbation, the first is using the command `PERT`, and the second is using the command `TSM` ([pdetail.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/pdetail/), [perturb.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/perturb/)). We will use **TSM** (thermodynamic simulation method) free-energy perturbation in this lab to compare the relative ΔΔG’s of amantadine (labeled ALM-035) and rimantadine (labeled ALM-150).

TSM operates using degrees of mutation, termed lambda, for which a percentage of Drug A is compared to a percentage of Drug B. The values of lambda used in this lab are 0.05, 0.125, 0.500, 0.875, and 0.95. Using thermodynamic perturbation, midpoints between the lambdas, as well as endpoints 0 and 1, can be predicted, giving ΔG at the following points:

| Lambdas               |
| --------------------- |
| λ = 0.0 (100% Drug A) |
| λ = 0.05              |
| λ = 0.0875            |
| λ = 0.125             |
| λ = 0.3125            |
| λ = 0.5               |
| λ = 0.6875            |
| λ = 0.875             |
| λ = 0.9125            |
| λ = 0.95              |
| λ = 1.0 (100% Drug B) |

### 2. TSM for Drugs in M2
Before we can use the free-energy perturbation method, the systems we need to simulate must first be created. Fortunately, the systems you will be simulating are provided in the lab. Once you have obtained good systems for simulation, you will (1) heat, (2) equilibrate and perform TSM, and (3) execute a post-processing script to interpret TSM data.

For the purposes of this lab, you will not perform any simulations of the drugs in the M2 channel. Rather, you will simulate the drugs in water and compare your results to M2 results that are given to you in the `charmmlab/lab_files/lab_files/tsm_output` directory.

Open the "tsm_output" directory described above and examine the contents (do not edit any of the files here, and do not copy the directory to your personal directory). The output directory contains the output .crd, .dcd., restart, tsm, and .xtl files from the TSM scripts for the drugs in the M2 channel (2kqt).

The lab directory you will be working with (labeled "perturbation") can be found in the charmmlab directory where the other labs are stored. In this directory you will find CHARMM scripts (prefix=tsm), a customized submission script (submit.sh), and four directories. The output directory here corresponds to the tsm_output directory and will be filled by data from your personal submissions. The alm folder contains the .pdb’s, .prm’s, and .rtf’s of the drugs you will be simulating, as well as stream files defining cage atoms. The prep directory contains coordinate files and others essential to the lab, but these will not require editing. Finally, the log directory will contain log files from your CHARMM scripts. Copy the perturbation lab directory to your personal directory.

This lab utilizes a multi-purpose submission script tailored for the lab. As you perform research, there will be many occassions where you will need to submit up to thousands of analogous simulations with similar, but varying parameters. Invoking a Linux shell script can help to submit these scripts in bulk. Open the file "submit.sh" and look over the contents. You don’t need to know what every Linux command means, but acquaint yourself with the variables, for you will need to adjust them later. When `export` is used, a variable is passed for use by another script--in this case to a procedurally generated file via a Linux [here document](https://bash.cyberciti.biz/guide/Here_documents), which submits commands and parameters to a compute node on the supercomputer. The loops and if tests that follow cause the submission to be performed multiple times depending on the values set in the variables section. The here-doc section contains a line `#SBATCH`, without which the file could not be submitted to the scheduler (not to be mistaken for a Linux comment). It loads the required environments using `module load charmm` and finally invokes CHARMM following the general pattern below:

```bash
mpirun $(which charmm) [variables to pass] < [input] > [output]
```

- `mpirun` invokes the default Message Passing Interface (MPI) parallel environment
- `$(which charmm)` is a variable stored that points to the CHARMM executable in the supercomputer apps directory, set when loading the CHARMM module. When MPI is not invoked with mpirun, CHARMM will run in serial.
- `[variables to pass]` is an optional list of variables to send to CHARMM in the format variable:value.
- `[input]` is the name of the file to send to CHARMM, usually a .str or .inp file.
- `[output]` is the name of the file to write CHARMM output to, usually called a log file.

#### Heating
Open the file labeled "tsm.heat_2kqt.str." This file is the CHARMM script used to heat the drugs in the 2KQT model of the M2 proton channel in a lipid bilayer. You should be familiar with many of the commands seen in this script from previous labs. You will also notice the use of **absolute references** and pathnames, rather than the usual **relative references**, to allow CHARMM to access the files from any directory on the supercomputer. Variables not defined in the CHARMM script are passed from "submit.sh", as described previously. Use what you’ve learned in the previous labs to understand what each command is doing in this script, and consult the CHARMM documentation or the TA’s if necessary.

> **Question 1***: What are the dimensions of the crystal for this protein system?

> **Question 2***: You will notice a couple of lines that use the CHARMM command `DEFINE`. Do you remember what this command does? Describe what it influences later in the script.

The file labeled "tsm.restart_2kqt.str" takes restart information from the previous script and continues the simulation using CPT dynamics for equilibration.

#### Production & TSM
In most cases, we would allow further time for equilibration before performing production dynamics, but for the purposes of this lab we will assume the system is equilibrated after heating.

Production dynamics is performed in a step-wise fashion using **restart files**. You can imagine the way restart files are used just like working on a lengthy project in a word processor. It is ideal to save often and pick up your work where you previously saved, rather than completing it all at once without saving at all during the process.

> **Question 3**: In theory, you could use one script and one submission and extend the production dynamics process to a longer amount of time. However, this is often an impractical solution. Name two reasons that you can think of that make the use of restart files advantageous.

The file labeled "tsm.restart_2kqt.str" in your lab directory is the script that would be used to extend equilibration time for the system and perform TSM calculations. Restart scripts can be made to take more than a day to complete on the supercomputer--for this reason you will not be required to edit or submit this script. The coordinate files, dcd files, tsm files, and more from the 2KQT simulations are found in the tsm_output directory in the lab_files directory from earlier. Now that you’ve familiarized yourself with the restart and heating scripts, answer the following question:

> **Question 4**: What variable is passed to the CHARMM script from the shell to allow the restart script to load the output files from the heating script? What would the value of the variable need to be for the second restart after the first post-heating restart?

#### Post-Processing
TSM’s output files in `charmmlab/lab_files/tsm_output/tsm/` are not in a format readily understood for analysis. For this reason, TSM has its own CHARMM post-processing method that it employs to give a printout of ΔG. You will find in your lab directory a file named "tsm.post_processing.str." This script loads up TSM output files with a loop, calculates midpoints based on given lambdas, processes the TSM output files with `TSM POST PSTAck 10 PLOT`. The submission script, "submit.sh," sorts the TSM data using Linux commands depending on the variables the user sets at the start of the file. The postp folder contains the organized output data for analysis with programs such as Excel. Delta A (which in this case really means ΔG) is the free-energy data you are interested in, Delta E is the change in energy, and Delta S is the change in entropy.

### 3. TSM for Drugs in Water
Now that you have familiarized yourself with how to heat, equilibrate, and analyze TSM simulations for drugs in the M2 channel, **_perform these same steps for drugs in water_**. This is a necessary in order to determine the free-energy of binding, ΔΔG, given by the difference in ΔG between the channel and water. The submit.sh script needs only small adjustments, the batch.submit and tsm.post_processing files need no adjustment, and two CHARMM input files for water (with the same naming pattern) will need to be made. You may copy a lot of the code from the 2KQT heat and restart scripts (by copy-pasting or using the cp command), but you will need to make adjustments to ensure they work properly for the drug-water systems.

Notice the minimization methodology for M2 will not apply to drugs in water, so create your own minimization procedure (don’t overthink this). You only need to perform one restart, but you may perform more than one if you desire. Depending on the usage of the supercomputing clusters available on the "Current Utilization" graphs on the [marylou.byu.edu home page](https://marylou.byu.edu/), you may desire to adjust the sbatch command at the end of the submit.sh script to improve your odds at entering the queue and getting compute resources or to accelerate the simulations (see "Heating" in the Introduction to Dynamics lab for more information). Use all of your available resources, scripts, and output to figure out how to do this with as little help from the TA’s as possible.

### 4. Analysis
The data analysis for this lab takes place in two parts. You will begin with a graphical analysis of data and then finish with a visual analysis of the system in equilibrium.

#### Statistical Analysis
Import the post-processing output files for the drug in protein and the drug in water (found in tsm_files) into the statistical program of your choice (Excel, Matlab, etc.) and compute the ΔΔG’s (protein minus water) for amantadine and rimantadine (refer to the background section).

> **Question 5**: Which drug has a lower ΔΔG? By how much?

Prepare a scatterplot showing ΔΔG per value of lambda and include it in your lab writeup.

#### Visual Analysis
Open `charmmlab/lab_files/tsm_output/crd/` and select the coordinate file for the 2kqt system in equilibrium. Load this file in VMD (be sure to specify CHARMM coordinates) and add the corresponding DCD file to the molecule. Press play and inspect the molecule and its trajectory. Use labels and the representations `SEGID M2A M2B M2C M2D` and `RESNAME L035 L150` to help you find the channel and the drugs. Answer the following questions:

> **Question 6**: Toward which terminus (N or C) does the drug orient in M2 while in equilibrium?

> **Question 7**: What amino acids do you find nearest to the drug while the system is in equilibrium?

Feel free to explore the molecule more and see what other interactions may be occurring.

> **Question 8**: Name two things you could change in the scripts or in your methods to collect more accurate and reliable TSM data.

**[Return to home page](https://busathlab.github.io/mdlab/index.html)**
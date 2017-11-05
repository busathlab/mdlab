## LAB 6: UMBRELLA SAMPLING
###### by [Dr. David Busath](http://busathlab.byu.edu/)

---

#### Objectives:
- Learn to perform umbrella sampling of two water molecules in a vacuum
- Understand the theory behind free-energy profiles, umbrella potential, and weighted-histogram analysis
- Introduce to the `correl` function in CHARMM and create a time series
- Plot a potential of mean force

---

In the Energy Minimization and Introduction to Dynamics labs, you learned about performing molecular dynamics and the idea of applying constraints. Here, we will use a constraint to hold two "room temperature" water molecules apart at different distances ranging from 2.2 to 5.0 Å. To keep it very simple, the environment will simply be a vacuum, but the same principles apply in condensed matter simulations.

The constraint used for this kind of assessment is called an **umbrella potential**, probably because it holds the system under the umbrella of a particular region of the reaction coordinate (or perhaps because the parabolic potential usually used is like an upside-down umbrella--we don’t know for sure where the term originated). Sampling obtained under the umbrella of this constraining force is called umbrella sampling. The goal is to look for bias in the sample positions along the reaction coordinate that would reflect a slope in the underlying free energy profile.

In a system with two TIP3 water molecules, a hydrogen bond exists between the two TIP3 waters. The ideal distance between the two oxygens is about 2.8 angstroms. The interaction energy approaches zero when the two oxygens are more than 4.0 angstroms apart. We will take the O-O distance as the reaction coordinate for the formation of the hydrogen bond in the water-dimer and sample the free energy profile along this reaction coordinate.

### 1. Theory--Potential of Mean Constraint Force Method
The free energy profile along a reaction coordinate is equal to the reversible work of moving along that coordinate, which takes into account both the potential energies of all reactants as they move along the reaction coordinate, and also how interactions between reactants and of each reactant with the environment affects the representation (distribution) of different configurations in the relevant ensemble of configurations. Frames from a constrained molecular dynamics simulation can be taken as a reasonably representative ensemble of configurations for a point along the reaction coordinate when all of the frictional and ballistic effects of relative reactant movements are null.

The force required to hold the reactants at that point on the reaction coordinate is called the **Constraint Force**, Fc. It is equal but opposite to the force that the system is applying to the reactants. Let’s think of the constraint force holding two reactants at a particular separation as if it were being applied to one atom, the test or ith atom, and think of the other as one of the atoms of the system, it being a reference point for the distance to the ith atom. In each configuration, the constraining force is: ![alt text](https://github.com/busathlab/mdlab/raw/master/images/06_f01.jpg "Figure 1")

Integration of the mean force applied by the system to the test reactant along the reaction coordinate dimension gives the work of moving along the reaction coordinate. The free energy is the energy available to do work. Equivalently, the work of moving along the reaction coordinate, from infinite separation to the reaction position, ξb, under the influence of the Mean Force is the free energy profile. ![alt text](https://github.com/busathlab/mdlab/raw/master/images/06_f02.jpg "Figure 2")

The type of free energy being calculated depends on the ensemble conditions used to produce the simulation trajectory. If constant pressure and temperature conditions were used, the free energy is considered a Gibbs free energy, ΔG. If constant volume and temperature conditions were used, it is considered a Helmholtz free energy, ΔA.

We will use this Potential of Mean Constraint Force method in this lab. It is important to point out that the Potential of Mean Constraint Force is NOT equivalent to the Mean Constraint Potential, which depends on the force constant of the constraint used in a non-linear fashion. The constraint energy is reported by CHARMM in the log file, but to get the mean force for integration, you must analyze your data in two steps. You will do this in an Excel spreadsheet.

First, you will calculate the average distance between reactants (water oxygens) from each umbrella and compute, knowing the force constant, k=KMIN=KMAX, the constraint force on the test atom relative to the reference atom. These will be extracted from your logfile using the unix command, grep (get the representation), which prints to standard output any line containing the string fed to grep as an argument.

Next you will use numerical integration to compute the work to move from the ξ represented by one umbrella to that represented by the next. This is not too hard: you just multiply the average of the constraint forces at the two values of ξ by the difference in ξ. The hardest part is rationalizing the sign, but you can make sure you have it right by intuition. The sum of each of the increments in work is the free energy profile. In our simulations, we will not use constant volume nor constant pressure, so it is not a Gibbs or Helmholtz free energy. The ensemble we will use is the semicanonical ensemble, and we believe that the free energy is just referred to as the free energy.

For completeness, we will also describe next a closely related approach that is often used with umbrella sampling. Used with an equivalent data set, it gives a smoother but comparable free energy profile. You can read it later. For now, skip to the instructions in Part III. Then come back and answer question 1 for your writeup.

### 2. Theory--Weighted Histogram Analysis Method
For a canonical ensemble the Helmholtz free energy is give by: `A(ξ) = -kBT ln ρ(ξ)`, where ρ(ξ) is the probability density along the reaction coordinate ξ.

When an umbrella potential (also called "auxiliary window potential") `U(ξ) = k (ξ- ξ0)^2` is introduced, the free energy could be rewritten as:
`A(ξ) = -kBT ln[ρ*(ξ)] - U(ξ) - Ci`, where `ρ*(ξ)` is the biased probability density and can be determined from the dynamic simulation trajectory. Because `U(ξ)` is a known function, `A(ξ) + Ci` can be calculated for each window.

> **Question 1**: Why do we have to use the umbrella potential at all if all we need is to figure out the probability density `ρ(ξ)`?(Hint: it has to do with how long it would take to get an infinite number of configurations for the canonical ensemble and the steepness of the underlying free energy profile).

Due to the limited computer time and power we compute a series of segments of A(ξ) that overlap each other. Each A(ξ) covers a small portion of the whole ξ range. These overlapping regions are then combined to form a continuous free energy function. This requires the determination of differences in the constants, Ci, for the windows. In practice, this has often been accomplished by shifting one free energy fragment up or down to optimize its overlap with that of the adjacent window. Alternatively, the free energy difference between ith and jth window potential [Ci - Cj] can instead be computed directly from the dynamics trajectory information. Then the constant Ci for each window is calculated by the following equation, leaving only one arbitrary constant Cl, which is usually set to zero:

```
Ci = [Ci - Ci-l] + … + [C3 – C2] + [C2 – C1] + C1
```

### 3. Molecular Dynamics with Umbrella Sampling
Copy the directory for this lab to your personal directory. The skeleton of the CHARMM dynamics script is found in "ww.str_SKELETON". It is missing several key components. Your job is to fill in those components to make the file work. They are represented in the file as ########. You will copy this file to ww.str and then edit ww.str to be usable.

Let’s walk through it. After opening the necessary rtf and parameter files, it sets up a loop. In each pass through the loop, a new segment consisting of a water dimer is generated. The oxygen positions are set (at a goodly distance from prior dimers) and the umbrella potential to hold the oxygens at a separation, ξ counter is applied. The `NOE` command block is used to apply the umbrella potential constraint. The important thing here is the `ASSIGN` command which applies a constraint to the two atom selections ([cons.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/cons/)).

After the loop finishes, the hydrogen positions for all of the water molecules are built using HBUILD. This positions the hydrogens in their ideal locations, given the parameters for the water molecule and the forces from other molecules in the system. The spacing between dimers is sufficient that no interactions with neighbor dimers are included in the energy. Finally, the system is minimized, heated, equilibrated, and simulated. At the end, the coordinates (both CHARMM and PDB format) and PSF files are written for the post-analysis and visualization.

> **Question 2**: What is the force constant `k` (the umbrella potential defined as `U(ξ) = k (ξ – ξ0)^2` ) during minimization?

> **Question 3**: If you want to do some more samples, say 5.0-5.5 angstrom with an increment of 0.1 angstrom, what changes would you make?

As we warned, there are several #########’s in the script. These are the parts of our stream file you need to contribute. Your job is to select the two oxygens in the `ASSIGN` commands and finish the rest of the dynamics commands. The molecular dynamics simulation should do 0.5 picoseconds of heating, 0.5 picoseconds of equilibration and 1 picosecond of simulation. I want you to create 500 frames in the "simul.dcd" file. This is going to be a nice test of your understanding of those awesome `DYNA` keywords ([dynamc.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/dynamc/)).

Notice, we are sampling the whole reaction coordinate with equal spacing, and we are using the same constraint strength all the way through. This is OK for the purpose of this lab. But for a real project, one might have to explore different constraint strengths and sampling spacings for different regions. Of course you are very welcome to change those parameters and explore whether you can get better results.

Work on those #########s, replace them with correct codes, save the final stream file as "ww.str" and **attach it with your report to the T.A. at the end of the lab.**

If you are on Marylou, edit the batch.submit script to include proper input file name and then execute ww.str using `sbatch batch.submit`. You can check the end of the log file to see if it’s done, using the command `tail -n 40 [log filename]`

OK, you are now creating a DCD files with the dynamics for 57 independent water pairs, some RST files and a log file. We need the DCD files for post analysis but not the RST and log files. So remove them after you finish correcting your stream file with the `rm *.rst` command. 

> Using the rm command in conjunction with the wildcard (`*`) is very unforgiving. `*.rst` refers to all files ending in ".rst". If you use the `*` by itself, it will refer to every file in your directory! When you remove a file in Linux, the file is gone!

### 4. Post-simulation Analysis
The DCD file you just created contains 500 simulation frames, each with 57 dimers at 100 Å separations. The stream file "rww.str_SKELETON" is designed to read the dcd file and output the average O-O distance (which is our ξ) for each dimer to the log file. Read the "rww.str_SKELETON" file. The only thing you need to do in order to change this skeleton into your "rww.str" is to identify the boundaries of the one loop in the file, so that you are clear on the flow of the routine, just like what you did with ww.str_SKELETON.

This routine introduces you to the `CORREL` facility, a CHARMM facility that is very powerful for use in MD trajectory analysis (correl.doc). It allows you to create a time series for nearly any measurable of interest. A `MANTIME` facility can also be invoked to manipulate the time series, for instance to get a correlation function between two measurables. Hence the name `CORREL`. But we will not use `MANTIME` here. We just want to extract the separations between water oxygen atoms for each pair. To do this, we create a time series for each pair with 500 values in each series. `Maxseries` tells `CORREL` how many of these time series it should create. For data storage purposes, we also have to tell `CORREL` to set aside enough values in the array for information on each of the atoms in the dimer and the code stating that it is the distance between them we want. This requires the formation of a datastructure with 3 positions for each time series, which is provided with the `Maxseries` keyword.

After the `CORREL` facility is initiated with the first `CORREL` command allocating memory, we next define the items we want for each time series using the `ENTER` command. We can do this in a loop because standard charmm commands can be executed by the `CORREL` facility. The first argument to `ENTER` is the name of the time series for future writing or manipulation purposes. Here, we use the user-defined variable, `count`, to increment the time series names in the loop. Next, we specify the class of time series: distance for a series of distances between two atom selections. Finally, we select the atoms to be used, using a simplified select syntax, similar to the situation for other commands (`IC SEED` and `CONS DIHE`).

After creating the time series, we load them with data using the trajectory command, which, in the `CORREL` facility, reads through the previously opened dcd file and extracts all the data specified in the time series. As a side benefit, the average and RMSD for each series is reported in the log, which we can use directly for our Excel spreadsheet in a moment.

Again, go to the CHARMM dictionary or the CHARMM documentation and look up the new commands,`CORREL`, `CORREL ENTER`, and `CORREL TRAJECTORY`, and try to understand what we’re doing. By now you should have developed the habit of going to the CHARMM User’s Guide and CHARMM Dictionary whenever you need them. ([correl.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/correl/))

1. When you finish replacing the ######### in your personal version of rww.str run it with CHARMM as described earlier.
2. After you get the log file, check what the final lines look like to ensure it completed without any errors. Then use the following Linux shell command to extract each of the lines containing a time series average (i.e. containing the string "Average") and store them in "averages.dat": `grep Average [log filename] > averages.dat`
3. Now, download "averages.dat" to your personal computer and open the file with Excel, accepting the default fixed spacing between columns. Delete all the unneeded columns, keeping just the index number, the average, and the umbrella position. Now, create three new columns to the right of these three: one for the constraint force (kcal/mol-Å), one for the increment in work (kcal/mol), and one for the integral (sum) of the work increments (kcal/mol).

The first constraint force column will require that you calculate the mean constraint force from the difference between the mean separation and the desired separation using `Fc = kΔx`. You can create the equation for the first cell and then fill the rest of the column by clicking the dot in the lower right hand corner of the first cell and dragging down to the end of the column.

The second work increment column requires that you calculate the mean of the forces from the current and next row, and then multiply it by the change in separation for the two rows. After you have the sign right, again, fill down.
Finally, the third PMF column requires that the incremental work for each row be added to the previous row’s accumulation. I prefer to do this from the bottom up, because I want my reference free energy to be that of infinite separation.

Plot the PMF (integrated work, Kcal/mol) against ξ (average separation, Å) using the Insert Chart option in Excel. Include your spreadsheet as an attachment to your writeup when you are done. Your results should be similar to the figure below.
![alt text](https://github.com/busathlab/mdlab/raw/master/images/06_f03.PNG "Figure 3")

> **Question 4**: How do you explain the shape of the PMF?

If you have extra time, you might be interested in comparing the PMF to the adiabatic map for the water dimer. An adiabatic map is a plot of the potential energy (usually after optimization) as a function of position along the reaction coordinate. "Adiabatic" refers to the fact that there is no heat in the system: it is perfectly cold (in other words, there is no dynamic averaging of thermal fluctuations, the temperature is 0 K). The adiabatic map is usually quite similar to the dynamic average potential energy profile. The difference between these and the free energy profile must be due to entropy effects. If you wish, you can modify your code to get the adiabatic map for the water dimer (and/or the dynamic average potential energy) and plot it on the same plot as the free energy profile for comparison. If you are really ready to pass this course, you should be able to do this without assistance!

Email your answers to the questions and a copy of your "ww.str" and your excel spread sheet to your TA.

**[Lab 7](https://busathlab.github.io/mdlab/lab7.html)**

**[Return to home page](https://busathlab.github.io/mdlab/index.html)**
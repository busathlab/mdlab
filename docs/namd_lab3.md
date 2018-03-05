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

There are hundreds of different ways that the umbrella sampling protocol can be performed. If you are experienced and more comfortable with Python, C++, etc., you could technically do most of the template replacement, submission, and data aggregation presented here. For the purposes of the lab we will use bash for our code, the default Linux interpreter. You do not have to follow the methods described here if you are comfortable with coding and prefer other methods.

Here is a chart demonstrating the suggested general workflow:
![alt text](https://github.com/busathlab/mdlab/raw/master/images/namd03_f01.png "Figure 1")

One approach to performing umbrella sampling with this workflow is using a "master" submission script. The submission script contains all of the variables of interest and defines the reaction coordiante of interest. Its function is to loop over all of the simulation configuration files (CHARMM, VMD, NAMD, etc.; the files in the middle column of *Figure 1*) providing environment variables specific for each window along the reaction coordinate. The submission script carefully manages filenames so the output data can be intelligently extracted for analysis in WHAM.

An analysis script can be run after the simulations complete that extracts the meaningful output data and execute WHAM.

### 3. Design the protocol 

That's pretty much it! We have provided a couple skeleton scripts containing some suggested pseudocode to help guide you, but now that you've made it this far in the course you should be able to perform most of this on your own.

> **ASSIGNMENT**: Perform umbrella sampling on a reaction coordinate of your choice with a drug of your choice in the equilibrated M2 CHARMM-GUI system from the previous lab. 
- Your simulations begin by adding the drug to the protein-bilayer system equilibrated in the first step of the lab. (`namdlab2_m2amt/charmm-gui/namd/step6.6_equilibration.coor` and `namdlab2_m2amt/charmm-gui/step5_assembly.xplor_ext.psf`). Your starting structure is __not__ the drug-protein-bilayer structure from the final step of the previous lab.
- You should simulate between 6 and 10 umbrella windows, at any resolution you desire, though we recommend some proximity for meaningful results. (E.g. drug positions no more than 1 angstrom apart)
- Each umbrella window should be simulated for at least 0.5 ns (250,000 steps with a 2fs timestep). 
- Pass your output data to WHAM and plot the free-energy profile of your reaction coordinate. **Submit the plot to your TA.**
- You are permitted to achieve this by whatever means you choose. You could either manually adjust each of the files and perform the simulations one-by-one (easier if you are extremely cautious with your file handling and well-organized), create a modified manual submission script with a lot of careful copy-pasting, or create a master submission script with loops (recommended).

The two scripts we have provided you (which you are not *required* to use, but would probably be helpful) are listed below. They each contain some basic comments and pseudocode to help get you started:
- `bash.umbrellasubmit.sh` - master submission script 
- `bash.analyzeumbrellas.sh` - post-simulation analysis script that runs WHAM, discussed later 

You will need the following files from the previous lab in your current lab directory. You may rename any of them as you prefer:
- `amt/`
- `alm/`
- `charmm-gui/`
- `charmm.adddrug.str`
- `colvars.production.inp`
- `namd.production.inp` 
- `vmd.compsets.inp` 
- `bash.pt2_adddrug.sh`
- `bash.pt3_compsets.sh`
- `bash.pt4_simulation.sh`

To save some time, below is some code you can execute within the current lab's directory to copy these files from the previous lab, if you keep each of the lab directories within a directory together. Otherwise just modify the code to suit your directory structure.
```shell 
cp ../namdlab2_m2amt/charmm.adddrug.str .
cp ../namdlab2_m2amt/colvars.production.inp .
cp ../namdlab2_m2amt/namd.production.inp . 
cp ../namdlab2_m2amt/vmd.compsets.inp . 
cp ../namdlab2_m2amt/bash.pt2_adddrug.sh .
cp ../namdlab2_m2amt/bash.pt3_compsets.sh .
cp ../namdlab2_m2amt/bash.pt4_simulation.sh .
cp -r ../namdlab2_m2amt/alm .
cp -r ../namdlab2_m2amt/avg .
cp -r ../namdlab2_m2amt/charmm-gui .
```

One tip to start, make sure to use variables anywhere you have filenames within your configuration files **(CHECK ALL OUTPUT FILES!)**. You do not want to perform your whole umbrella sampling protocol to find out all of the output files have the same name and overwrite each other! For good-practice's sake, you might also choose to use variables for any parameter that may potentially be of interest as some point, such as temperature, number of simulation steps, etc. If you were already using environment variables in the last lab, you will be a step ahead.

Refer to the next section of the lab for helpful bash tips and guidance.

### 4. Bash review and other helpful hints

#### Variables

To set a variable in bash, just use the `=` sign. To create a variable named `channel` equal to `2l0j`, just do `channel=2l0j`. To refer to that variable in the script, add a `$` in front of the variable name. 

One headache-saving tip is to use variables when defining other variables. Here's an example of using multiple variables to define a pattern.
```shell 
export pdbid=2l0j
export runCount=1
export inputFilePattern=${pdbid}_${runCount}
```
You can then call `$inputFilePattern` within a script to load `$inputFilePattern.psf`, `$inputFilePattern.crd`, etc.

#### Environment variables 

In bash, variables stay within the environment of the bash script being run unless the `export` function is used. Let's review how to use environment variables in each program.

**CHARMM**
1. Use `export variableName=variableValue` in the bash script.
2. Add `variableName:$variableName` to the CHARMM run command. (see the end of `bash.pt2_adddrug.sh`). Alternatively you can skip `1.` and do `variableName:variableValue`, but other programs will not have access to this variable.
3. In the CHARMM script being run, you can simply refer to the variable with `@variableName`.

**NAMD/VMD**
1. Use `export variableName=variableValue` in the bash script.
2. In the NAMD/VMD script being run, use `$::env(variableName)` to refer to the environment variable.

**Colvars does not use environment variables**. You will need to somehow tell colvars to use these variables, though. One option is to use a colvars "template" file, put unique words in the place of the values you would like to substitute, copy the template within the submission loop with `cp`, and then perform a find/replace with `sed` as described below.

#### Find / Replace with `sed`
There are multiple ways to do Find / Replace in Linux. One utility capable of find/replace is `sed`. 

The following command will replace all occurences of `YES` in `foo.txt` with `NO` in a new file called `bar.txt`: 
```shell 
sed "s,YES,NO," foo.txt > bar.txt
````

The following command will replace all occurences of `DRUGPOSITION` with the value of the variable `drugposition` and save changes to the same file: 
```shell 
sed -i "s,DRUGPOSITION,${drugposition}," output/colvars.${outputPattern}.inp
```

Advanced substitutions involving punctuation, special characters, ignoring case, etc. are possible but a bit more complex. See the [`sed` documentation](https://www.gnu.org/software/sed/manual/sed.html) for more information. 

#### Arithmetic

Arithmetic is a significant limitation of bash, so other utilities are used to perform the math. 

Here are two different ways to assign the sum of the exported variables `reactionCoordinateStart` and `reactionCoordinateIncrement` to the variable `umbrellaWindow`:

```shell
export umbrellaWindow=`perl -E 'say ($ENV{reactionCoordinateStart}+$ENV{reactionCoordinateIncrement})'`
```

```shell 
export umbrellaWindow=`echo "( $reactionCoordinateStart + $reactionCoordinateIncrement )" | bc`
```

`perl` is better for more advanced calculations and the `echo ... | bc` method is a bit easier for very basic calculations.

Here's another example of using `perl` to compute the arccosine of the exported bash variable `cos`, converting to degrees, and assigning it to the bash variable `umbrellaTiltDegrees`:

```shell
export umbrellaTiltDegrees=`perl -E 'use Math::Trig; say acos($ENV{cos})*180/pi'`
```

#### Number formatting

For analysis purposes and automation, managing your decimal places and floating zeros is important. For ease in the analysis stage, it may be helpful to you to be consistent with number length and decimal places.

`printf` is a common cross-platform utility for formatting a variety of data types. To redefine the variable `umbrellaWindow` with a current value of 2.5 to a new value of 002.500:

```shell
umbrellaWindow=`printf "%07.3f" $umbrellaWindow`
```

Breaking down the formatting argument, `%07.3f`:
- the `7` means to format the output with a minimum of 7 characters (if the output is less than 7, it will add blank spaces to the right to equal 7 characters, by default)
- the `0` before the 7 means to use leading zeros to make the minimum of 7 characters instead of blank spaces to the right.
- the `3f` means to use the float data type (6 decimal precision) and to limit the decimal places to 3.

[Here is a helpful resource for learning more about formatting with printf](https://www.computerhope.com/unix/uprintf.htm).

#### Echo

The `echo` command writes its arguments to the standard output. It is an essential tool for a variety of reasons. Here are a few:
- Determining that calculations are performed properly.
- Passing output to other commands. The second arithmetic approach described earlier is an example of this.
- Outputting data to a file
- Troubleshooting loops 

Here is an example of using echo to write the value of a variable `umbrellaWindow` to a new file `window.txt`:
```shell 
echo $umbrellaWindow > window.txt 
```
If the file `window.txt` already exists, it will be overwritten. If you desire to append to the file instead, use two angular quote brackets `>>`:
```shell 
echo $umbrellaWindow >> window.txt 
```

Find more information [here](https://www.computerhope.com/unix/uecho.htm).

#### Loops 
There are multiple types of loops and multiple ways of performing each loop in bash. 

**For Loop**. A `for` loop is used to execute a list of commands and iterates through a series.

Let's use an example of iterating through umbrella windows with a for loop.
```shell 
export reactionCoordinateStart=3
export reactionCoordinateIncrement=0.5
export reactionCoordinateStop=6
# calculate number of umbrella windows 
totalWindows=`perl -E 'say 1+($ENV{reactionCoordinateStop}-$ENV{reactionCoordinateStart})/$ENV{reactionCoordinateIncrement}'`

for (( windowCount=0; windowCount<$totalWindows; ++windowCount )); do 
	export windowCount=$windowCount
	umbrellaWindow=`perl -E 'say ($ENV{windowCount}*$ENV{reactionCoordinateIncrement}+$ENV{reactionCoordinateStart})'`
	echo "current umbrella window is $umbrellaWindow" # check the calculation and the loop counter 
done	
```

The output of above snippet is:
```shell 
current umbrella window is 3
current umbrella window is 3.5
current umbrella window is 4
current umbrella window is 4.5
current umbrella window is 5
current umbrella window is 5.5
current umbrella window is 6
```

Here is a description of the `for` statement in the above example:
1. `windowCount=0`: Start with a value of `0` for `windowCount`. 
2. `windowCount<$totalWindows`: Continue running the loop until `windowCount` is no longer less than `totalWindows` 
3. `++windowCount`: Increment `windowCount` by 1 for every loop iteration 

`windowCount` is used within the loop as a multiplication factor for the variable `reactionCoordinateIncrement`; their product is added to the variable `reactionCoordinateStart` to give the value of `umbrellaWindow`. In the case of a distance reaction coordinate, `umbrellaWindow` would represent the desired location of the drug along the channel axis to be used for that particular simulation.

**While Loop**. A `while` loop is used to execute a list of commands as long as a condition is met. These are used less frequently than `for` loops, but they have utility. Let's recreate the same outcome of the previous `for` loop using a `while` loop:

```shell 
windowCount=0
while (( windowCount < $totalWindows )); do
	export windowCount=$windowCount
	umbrellaWindow=`perl -E 'say ($ENV{windowCount}*$ENV{reactionCoordinateIncrement}+$ENV{reactionCoordinateStart})'`
	echo "current umbrella window is $umbrellaWindow" # check the calculation and the loop counter 
	((windowCount += 1))
done
```
The while loop above performs the code until the condition `windowCount < $totalWindows` is false. The line `((windowCount += 1))` increments `windowCount` within the loop, similar to how the for loop increments it with `++windowCount` within the `for` statement.

Other uses for `while` loops uses include performing code until a certain time of day, until a scheduled job starts, etc. Often the command `sleep` is used in conjunction with a while loop so the code isn't performed constantly.

[Here is a helpful resource for learning more about loops](http://tldp.org/LDP/abs/html/loops1.html).

#### If statements

The `if` command evaluates a conditional statement and performs code depending on the status of the condition. 

For example, if you want to see if the output file already exists before running a simulation, you could do something like this:
```shell 
if [ -f output/${outputPattern}.log ]; then
	echo "file exists already, exiting script"
	exit 0
else 
	echo "file does not exist"
fi 
```
The `-f` argument within the conditional statement (in brackets) denotes a boolean for a file that returns true or false. In a sense, the conditional statement is reduced, to true or false (so if the file exists, it would be like `if true; then ...`

Here is an `if` statement that compares two variables:
```shell 
if [ $windowCount < $totalWindows ]; then 
	echo "the current umbrella window count is less than the total number of umbrella windows"
fi 
```

Here is an `if` statement that is used to interpret input from the user from the command line:
```shell 
echo "The total number of umbrella windows to be simulated is $totalWindows, do you wish to continue? (y/n)"
read proceed # waits for user input 
if [[ $proceed == Y || $proceed == y || $proceed == Yes || $proceed == yes ]]; then 
	echo -e "Proceeding with submission..." 
	sleep 1
else
	echo -e "Terminating script"
	sleep 1
	exit 0
fi
```
Notice the use of the `||`, which are "OR" in boolean logic. `&&` is the "AND" operator.

See [this site](https://linuxacademy.com/blog/linux/conditions-in-bash-scripting-if-statements/) if you'd like to learn more.

#### Arrays 

An array is a variable that contains multiple values. 

When setting up a reaction coordinate, for example, you could set variables named `reactionCoordinateStart`, `reactionCoordinateIncrement`, and `reactionCoordinateStop` and use arithmetic to pass the umbrella window position to the simulation program. An alternative would be to use a variable array, with umbrella window positions manually entered in.

```shell 
reactionCoordinate=( "-5" "-4" "-3" "-2" )
```

To get the value of the 3rd value in the array, `-3`, use `${reactionCoordinate[2]}`. You use `2` in the brackets because in the Linux shell, the first array position is defined at position zero, so the third value in the array would be at position two.

To loop through all the elements of the `reactionCoordinate` array:
```shell 
for (( count=0; count<${#reactionCoordinate[@]}; count++ )); do 
	echo ${reactionCoordinate[$count]}
done
```

The output of the above snippet is:
```shell 
-5
-4
-3
-2
```

For more information, visit [this site](http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_10_02.html).

#### Functions

Functions are reusable snippets of code that can be called at different points within a script. We will not go into great detail on functions, but simple functions can be very useful.

The general formatting of a function is `functionName () { }` with the function code placed within the braces. To execute a function, just do `functionName`. Some prefer to name all functions in all caps for improved script readability.

Here is an example of calling a function named `SUBMITFUNCTION` within a `for loop`, similar to example from the `for` loop section earlier:

```shell 
export pdbid=2kqt 
export drugid=alm034
export reactionCoordinateStart=3
export reactionCoordinateIncrement=0.5
export reactionCoordinateStop=6
# calculate number of umbrella windows 
totalWindows=`perl -E 'say 1+($ENV{reactionCoordinateStop}-$ENV{reactionCoordinateStart})/$ENV{reactionCoordinateIncrement}'`

for (( windowCount=0; windowCount<$totalWindows; ++windowCount )); do 
	export windowCount=$windowCount
	export umbrellaWindow=`perl -E 'say ($ENV{windowCount}*$ENV{reactionCoordinateIncrement}+$ENV{reactionCoordinateStart})'`
	SUBMITFUNCTION
done	

SUBMITFUNCTION () {
	export umbrellaWindow=`printf "%07.3f" $umbrellaWindow`
	export outputPattern=${pdbid}_${drugid}_${umbrellaWindow}
	echo "outputPattern is $outputPattern"
	mkdir -p output 
	mkdir -p output/${outputPattern} 
	# etc ...
}
```

The output for the above snippet would be as follows:
```shell 
outputPattern is 2kqt_alm034_003.000
outputPattern is 2kqt_alm034_003.500
outputPattern is 2kqt_alm034_004.000
outputPattern is 2kqt_alm034_004.500
outputPattern is 2kqt_alm034_005.000
outputPattern is 2kqt_alm034_005.500
outputPattern is 2kqt_alm034_006.000
```

Calling `SUBMITFUNCTION` within the loop improves readability of the script. 

Furthermore, if you wanted to test out the script before running through the loop, you could comment out the `for` loop, manually enter the parameter of interest, and call SUBMITFUNCTION.

```shell
... 
# for (( windowCount=0; windowCount<$totalWindows; ++windowCount )); do 
# 	export windowCount=$windowCount
# 	export umbrellaWindow=`perl -E 'say ($ENV{windowCount}*$ENV{reactionCoordinateIncrement}+$ENV{reactionCoordinateStart})'`
# 	SUBMITFUNCTION
# done	
export umbrellaWindow=3
SUBMITFUNCTION 
...
```


### 5. Submitting 

The scheduler submission script from last lab, `bash.pt4_simulation`, is written to utilize full GPU nodes. While you may keep this in your workflow as-is, the number of GPU nodes is very limited and it may be easier to either request portions of GPU nodes or full non-GPU nodes instead. Adjust the requested time and resources as you see fit [according to available resources](https://marylou.byu.edu/documentation/resources). 

**Example full GPU node request**. This is what is used in lab 2. If GPU node [utilization is low](https://marylou.byu.edu/utilization/) and you have a *low volume* of jobs and need them done as quickly as possible, this is a good scheme. Based on `m8g` architecture.
```shell 
#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=24   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --gres=gpu:4
#SBATCH --mem=64G   # total memory
...
# Run NAMD 
module purge
module load compiler_gnu/6.4
module load cuda/8.0
export dir=/fslhome/mgleed/software/namd/exec/NAMD_Git-2017-11-04_Linux-x86_64-multicore-CUDA
$dir/namd2 +p${SLURM_CPUS_ON_NODE} +idlepoll +devices $CUDA_VISIBLE_DEVICES $inputFile > $outputFile
```

**Example 1 GPU per GPU node request**. This requests 1/4th of the GPU node. If GPU node [utilization is low](https://marylou.byu.edu/utilization/) and you have a *medium-to-high volume* of jobs, this is a good scheme. Based on `m8g` architecture.
```shell 
#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=6   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --gres=gpu:1
#SBATCH --mem=16G   # total memory
...
# Run NAMD 
module purge
module load compiler_gnu/6.4
module load cuda/8.0
export dir=/fslhome/mgleed/software/namd/exec/NAMD_Git-2017-11-04_Linux-x86_64-multicore-CUDA
$dir/namd2 +p${SLURM_CPUS_ON_NODE} +idlepoll +devices $CUDA_VISIBLE_DEVICES $inputFile > $outputFile
```

**Example multiple non-GPU node request with `mpi` and infiniband**. If the GPU nodes [are being hogged](https://marylou.byu.edu/utilization/), utilization of the non-GPU nodes is low, and you have a *low volume* of jobs, this is a good scheme. Jobs will run across multiple nodes. `m7` has 16 cores per node, `m8` and `m9` have 24 cores per node. (3/2018)
```shell 
#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=64   # number of processor cores (i.e. tasks)
#SBATCH --nodes=4   # number of nodes
#SBATCH --mem-per-cpu=2G   # memory per CPU core
#SBATCH -C 'ib'
...
# Run NAMD 
module purge 
module load namd/2.12_openmpi-1.8.5_gnu-5.2.0
mpirun $(which namd2) $inputFile > $outputFile
```

**Example single non-GPU node request**. If the GPU nodes [are being hogged](https://marylou.byu.edu/utilization/), and you have a *high volume* of jobs to get through, this is a good scheme. `m7` has 16 cores per node, `m8` and `m9` have 24 cores per node. (3/2018)
```shell 
#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=16   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=2G   # memory per CPU core
...
# Run NAMD 
export dir=/fslhome/mgleed/software/namd/exec/NAMD_Git-2017-11-04_Linux-x86_64-multicore
$dir/namd2 +setcpuaffinity `numactl --show | awk '/^physcpubind/ {printf "+p%d +pemap %d",(NF-1),$2; for(i=3;i<=NF;++i){printf ",%d",$i}}'` $inputFile > $outputFile
```




### 6. Analysis with WHAM 






**[Return to home page](https://busathlab.github.io/mdlab/index.html)**
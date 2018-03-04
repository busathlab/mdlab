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

Here is a chart demonstrating the suggested general workflow:
![alt text](https://github.com/busathlab/mdlab/raw/master/images/namd03_f01.png "Figure 1")

One approach to performing umbrella sampling with this workflow is using a "master" submission script. The submission script contains all of the variables of interest and defines the reaction coordiante of interest. Its function is to loop over all of the simulation configuration files (CHARMM, VMD, NAMD, etc.; the files in the middle column of *Figure 1*) providing environment variables specific for each window along the reaction coordinate. The submission script carefully manages filenames so the output data can be intelligently extracted for analysis in WHAM.

An analysis script can be run after the simulations complete that extracts the meaningful output data and execute WHAM.

### 3. Design the protocol 

That's pretty much it! We have provided a couple skeleton scripts containing some suggested pseudocode to help guide you, but now that you've made it this far in the course you should be able to perform most of this on your own, even if you were to do it all manually without special scripts. 

The two scripts we have provided you are listed below, and they each contain some basic comments and pseudocode to help get you started:
- `bash.umbrellasubmit.sh` - master submission script 
- `bash.analyzeumbrellas.sh` - post-simulation analysis script that runs WHAM, discussed later 

Copy the following from the previous lab into the current lab directory. You may rename any of them as you prefer:
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

To save some time, below is some code you can execute within this lab's directory to grab these files from the previous lab, if you keep each of the lab directories within a directory together. Otherwise just modify the code to suit your directory structure.
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

One tip to start, make sure to use environment variables anywhere you have filenames within your configuration files. You do not want to perform your whole umbrella sampling protocol to find out all of the output files have the same name and overwrite each other! For good-practice's sake, you might also choose to use environment variables for any parameter that may potentially be of interest as some point, such as temperature, number of simulation steps, etc. If you were already using environment variables in the last lab, you will be a step ahead.

Refer to the next section of the lab for helpful `bash` tips and guidance.

### 4. `bash` review and other helpful hints


### 5. Submitting 

The scheduler submission script from last lab, `bash.pt4_simulation`, is written to utilize full GPU nodes. While you may keep this in your workflow as-is, the number of GPU nodes is very limited and it may be easier to either request portions of GPU nodes or full non-GPU nodes instead. Adjust the requested time as you see fit. 

**Example full GPU node request** This is what is used in lab 2. If GPU node [utilization is low](https://marylou.byu.edu/utilization/) and you have a *low volume* of jobs and need them done as quickly as possible, this is a good scheme. Based on `m8g` architecture.
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

**Example 1 GPU per GPU node request** This requests 1/4th of the GPU node. If GPU node [utilization is low](https://marylou.byu.edu/utilization/) and you have a *medium-to-high volume* of jobs, this is a good scheme. Based on `m8g` architecture.
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

**Example single non-GPU node request** If the GPU nodes [are being hogged](https://marylou.byu.edu/utilization/), and you have a *high volume* of jobs to get through, this is a good scheme. `m7` has 16 cores per node, `m8` and `m9` have 24 cores per node. (3/2018)
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
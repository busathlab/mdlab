## LAB 2: INTRODUCTION TO CHARMM

#### Objectives:
- Learn basic commands with Linux Bash
- Get comfortable with the rudiments of CHARMM 
- Create a simple polypeptide in CHARMM and perform minimization

### 1. Linux Basics
Molecular dynamics simulations often require very large amounts of computational power. Because of this, CHARMM was written with the capability to use more than one processor at a time. This is part of the reason why CHARMM was written to run on the Unix or Linux operating system instead of the Windows operating system. 

For those of you that are not familiar with Linux and Linux text editors, this section should give you a crash-course that will enable you to complete your labs.

> For Windows users, we suggest you download PuTTY, WinSCP, and Notepad++, all of which can be found at [Ninite](https://ninite.com/).

For this and future labs, we will be using the BYU Supercomputer, also known as MaryLou, which is run by the [Fulton Supercomputing Lab](http://marylou.byu.edu). You should either use a personal supercomputing account or an account associated with the lab, if available. To login, see the following information taken from the FSL documentation:

> Interaction with the supercomputer is typically performed with command line tools. The command line tools can be run via a command prompt, also known as a shell. SSH is used to establish a secure shell with the supercomputer.

> Windows [Using PuTTY:] Enter hostname: `ssh.fsl.byu.edu`. Click "connect" and enter your username and password when prompted. Once connected you can run commands.

> Linux and Mac OS have SSH built-in. The terminal can usually be found in one of three locations: Applications -> Utilities, Applications -> Accessories, or Applications -> System Tools. This opens a command prompt on the local system, you must now connect to ssh.fsl.byu.edu. Run `ssh $username@ssh.fsl.byu.edu` where $username is your username. Once connected you can run commands.

Change directories into your directory using the `cd` command. You can list the contents of your directory using the `ls` command. Navigate to the compute partition of the supercomputer where the busathlab group files are stored by executing `cd fsl_groups/busathlab/compute/`. Create a directory for yourself using `mkdir [username]` (substitute [username] with your preferred personal directory name).

> DO NOT perform the labs within the lab source directories--use your personal directory! Doing so will overwrite the original files, and the originals will need to be recovered before use by other lab members.

For all of the labs in this course, you will copy the lab source files to your newly created personal directory. Follow this general procedure for this lab and future labs:
 
From the compute directory, navigate to the charmmlab directory. (See path above if you are navigating from the default home directory.) Use the `ls` command to display the contents of the directory. Copy the folder for today’s lab by executing the command `cp -r lab2_intro/ ../[username]/`, again, substituting [username] with your personal directory name.

> If you don’t feel confident with the Linux commands, seek help from the TA’s  or the instructor. If you find yourself struggling or wanting to be more confident with the Linux command line, you are welcome to try out the helpful [command-line tutorial on Code Academy](https://www.codecademy.com/learn/learn-the-command-line) outside of the lab time.

If you navigate to your personal directory, you will find the lab2_intro directory has been copied into your directory. Change into this new lab directory, and you should see the files that you will need to complete this lab. You will also need to write some new files from scratch. To do this you will need to understand how to use a Linux text editor.

#### Vi
Like Windows, Linux has many different options for editing text. Unlike Windows, however, these editors do not rely on the mouse. The Linux text editor **vi** hardly uses the mouse at all. To open vi type "vi filename" in the command line of your Linux shell and push enter. There are two modes in vi, command mode and insert mode. The default mode is command mode.  In command mode, you use the keyboard to enter commands. For example `:w` writes the revised version of the file to disk (using the filename you opened with the vi command); `:w "filename"` is like using "save-as" in Windows: it stores you’re file under a new name without disturbing the original.  Most of the time you will be using **insert mode** to enter text.  To enter insert mode push the `i` key. To exit insert mode, so that you can save your file and quit vi, push the `esc` key. When editing using vi, scroll using the up/down arrows or page-up/page-down on the keyboard. *Scrolling with the mouse does not work!*

Here is an example of how to use vi to enter in a new file and save it: first type `vi myfirstfile` to open a new file named "myfirstfile". Next enter insert mode, so that you can enter text, by pushing `i`. Now type some text and note how the backspace and delete keys work. Once you are done entering text, exit insert mode to return to command mode in order to save your file. Exit insert mode by pushing `esc`. To save your file, enter `:w` (you don’t have to specify a name because you already named it myfirstfile when you opened it). Once your file is saved, enter `:q` to quit vi. If you want to quit without saving changes, use `:q!`. If you just want to quit AND save changes, enter `:wq`. To quickly escape, enter `ZZ`.

In the shell command line, list the contents of your directory with the `ls` command to verify that you created a new file. The long listing (`ls -l`) can be helpful as it gives more info.

### 2. CHARMM Basics

CHARMM is a command line program. This means that it is runs from a shell window with typed commands. Each command can be typed into the command line one at a time or each command can be read from a script file (commonly referred to as a **stream file** and given the extension ".str"). Like computer languages, CHARMM has a certain vocabulary and syntax to be learned. Some syntax in CHARMM is forgiving. For example, CHARMM commands can be truncated to their first four letters. Also, empty lines and multiple spaces between commands or pieces of commands are know as white space and are ignored by CHARMM.

Other syntax in CHARMM, however, is extremely sensitive.  For example, if you tell CHARMM to open a file, the filename will be converted to all lower case unless you put the name in quotes. This can be a problem because Linux is case sensitive. This means that if you want to open the file "MyFile," and you leave off the quotes, CHARMM will look for the file "myfile" which is not the same as "MyFile" in Linux. To see how CHARMM commands are used, we’ll start off by creating a simple polypeptide, finding its energy, and applying an energy minimization to it. Rather than typing each of these series of commands in one at a time, we will create a stream file that contains all of the options.

> One useful practice to avoid case issues is to keep all of your file names completely in lower case and keep your code all in lower case.

CHARMM doesn’t even enter into the picture until we are completely finished with the script, at which time we’ll invoke CHARMM. Remember, as you type in the commands explained in this section, that you’re only using the editor program, and that no calculations have taken place until the script is submitted.  

Using vi, open a new file named "ptrpmin.str". This will be where your script will be written.

> The [CHARMM online documentation](https://www.charmm.org/charmm/documentation/by-version/) offers a list of available commands and options. See [Basic Usage](https://www.charmm.org/charmm/documentation/basicusage/) for a detailed description on CHARMM syntax, structure, and organization.

#### Writing CHARMM scripts
All CHARMM scripts begin with a title. This is useful later in identifying old scripts. Title lines begin with an asterisk. (Also in non-title lines, exclamation points can be used to initiate comments.) The title must finish with a line consisting of only one asterisk, so enter:
```
* To create poly-tryptophan and calculate its energy
*
```

> For your learning purposes, avoid "copy-pasting" the code in these labs. Typing in code in different contexts interleaves learning practices that forces your brain to understand patterns and learn more efficiently, while "copy-pasting" is merely reading.

CHARMM already knows what atoms and amino acids look like, and how to connect them (i.e., atom masses and charges, bond angles and strengths, etc. are stored in the topology and parameter files).  In the next lab, we’ll learn how to write an Residue Topology File (RTF) that creates an amino acid from scratch; for now, let’s use the ones the CHARMM programmers wrote. In order for you to make reference to a TRP residue, CHARMM must have first called up all these pre-calculated residue structure and parameter files. The instructions for calling up this stored information have already been written for you in a file called "TOPPARM.STR."

Any CHARMM commands can be stored in a file and read into CHARMM by using the STREAM command ([miscom.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/miscom/)).  Your first instruction to CHARMM should be:
```
STREAM TOPPARM.STR
```
> Filenames enclosed in quotes, such as "TOPPARM.STR," are case-sensitive in CHARMM. This means that if the filename is truly TOPPARM.STR and you type in "topparm.str," it won’t work.

Now we’re ready to build our 5-mer of tryptophan. The command `READ SEQUENCE` ([struct.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/struct/)) tells CHARMM to read a sequence of residue topologies from the RTFs previously loaded. We specify `CARD` because the sequence is going to be a list of ASCII characters. `READ SEQUENCE` is always followed by 
1. A title (prefaced by asterisks, just like before) 
2. The number of residues, and 
3. The residue names

Now we’ve primed CHARMM for the next command, `GENERATE`, which constructs one segment in the **Principle Structure File (PSF)** from the residues we specified with `READ SEQUENCE`. `GENERATE` must be followed by a name for the segment, which in this case is `PTRP`. A segment is any group of residues. Imagine modeling hemoglobin, for example, which has four separate subunits. Each subunit would be a different segment. Once all four segments (monomers) are generated, the PSF would contain the whole protein.  Water and salt segments might be added to create the proper environment. Organic solvent, lipid, DNA, ligand molecules, or sets of such molecules are other common segments. If we want internal coordinate (IC) tables set up, which we do, the option `SETUP` must also be specified after `GENERATE`. These internal coordinate tables are "empty" until CHARMM reads the `IC PARAMETER` ([intcor.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/intcor/)) command, which fills the IC tables with values from the parameter table which we opened and read previously.

In order to compute the Cartesian coordinates in the next step, the relation of the structure to the origin (0,0,0) must be specified. The `IC SEED` command places the first atom specified at the origin, the second on the x axis, and the third in the x-y plane, using bond lengths and bond angles from the IC table.

`IC BUILD` computes the Cartesian coordinates from the data in the internal coordinate tables (which we just filled, thanks to `IC PARAMETER`).

It appears like that would be the end of things, except for the cleanup crew in the form of `IC PURGE`. This command deletes the IC table entries which contain undefined atoms. Remember that each residue includes an amino-terminus and a carboxyl-terminus. Now, connecting these residues with peptide bonds is going to get rid of some hydogens and oxygens, but `IC PARAMETER` doesn’t know that--it gives us bond and energy information for those extra atoms, too.  `IC PURGE` gets rid of this junk.

Now we want to see the result of our troubles so we ask CHARMM to show us what the IC table looks like, with the command `PRINT IC`. The information in the IC table is presented in columns labeled below, where I, J, K, and L are atom names, R stands for bond length, T stands for theta (angle), and PHI is the dihedral angle.

```
I   J   K   L   R(I-J or I-K)   T(I-J-K or I-K-J)   PHI   T(J-K-L)  R(K-L)
```

If an asterisk (*) is present in front of the third atom name, this indicates an improper dihedral in the "PHI" column and R (I-K) and T (I-K-J) are to be used.

The whole set of commands needed to build the PSF for the segment called PTRP and then print the contents of the IC table looks like this:

```
READ SEQUENCE CARD
* Sequence for poly-tryptophan
* 5
TRP TRP TRP TRP TRP GENERATE PTRP SETUP IC PARAMETER
IC SEED 1 CA 1 C 2 N
 
IC BUILD IC PURGE

PRINT IC
```

> Later, after you execute your CHARMM script, come back to these questions.

> **Question 1:**  From the contents of the IC table, what is the angle between 1 CG, 1 CD2, and 1 CE2? What is the length of the bond between 4 CD2 and 4 CG? (Clue: is there a bond between those two atoms? If not, why not?)

We said at the outset that we were interested in finding the energy of this peptide. Typing `ENER` ([energy.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/energy/)) will calculate the potential energy--you will learn how in future labs, so for now we will leave it at that. But an important parameter in calculating energy is the cutoff distance for non-bonded interactions. In other words, how far apart do two atoms have to be before their effect on each other is deemed ‘negligible’ and ignored? The following three commands will compute the potential energy three times, each time with different parameters:

```
ENER
ENER CUTNB 5.0 CTONNB 4.0 CTOFNB 4.5
ENER CUTNB 8.0 CTONNB 6.5 CTOFNB 7.5
ENER CUTNB 15.0 CTONNB 11.0 CTOFNB 14.0
```

In the first line we just type `ENER`. CHARMM would use the default values.

> **Question 2:** From the information that follows the ENER commands in your log file, what is the total energy in each case? What is the largest contributor to the energy? (Ignore the "WARNING" messages for now.)

CHARMM potential energy computation depends on the cutoff parameters. The bigger these parameters the more pairs of atoms are included in the computation. But that does NOT necessarily mean a bigger energy (why?).

**"Energy minimization"** and "geometry optimization" are synonymous terms for algorithms that change the coordinates of the peptide (i.e., its shape) to result in a lower potential energy structure. Because we are going to change the coordinates of the peptide, let’s keep a copy of the original structure in the **comparison set**, which is a secondary coordinate file where active coordinates can be kept in CHARMM ([corman.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/corman/)):

```
COORDINATE COPY COMP`
```

One method of minimization which will be discussed in lectures to come is Adopted-Basis Newton-Raphson (ABNR) ([minimiz.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/minimiz/)). The following command instructs CHARMM to perform 25 steps of ABNR minimization on our PTRP:

```
MINIMIZE ABNR NSTEP 25 NPRINT 1
```

> **Question 3**: Judging from the lines that follow the `MINIMIZE` command, what does the command `NPRINT` do?

CHARMM has temporarily stored the original coordinates of poly-TRP (in the COMParison coordinate set) and the coordinates of the new minimized structure (in the MAIN coordinate set). If we had CHARMM run this script and then finish, both sets of coordinates would be lost, unless we save them to permanent, humanly readable files on disk. To do this we have to start by designating a **FORTRAN logical unit number** ([miscom.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/miscom/)). This unit number could be any number from 1 – 99, but don’t use 5 or 6. These are standard input (the keyboard) and standard output (the monitor). Don’t use the same unit number twice in a script unless the first unit is closed or you want to write again to the same file. We also specify that the file type will be ASCII, with the keyword CARD. Then we name the file, adding the suffix ".CRD" as we do with any set of coordinates. We haven’t actually saved the coordinates to this file yet; we’ve just named it. To save coordinates to any unit, the command is WRITE COOR, or in the case of coordinates stored in the COMP set, WRITE COOR COMP. Then, just to be neat, we close the unit. If you forget this on occasion, CHARMM’s sub-program RDTITL will do it for you.

```
OPEN WRITE UNIT 10 CARD NAME "ptrp.crd" WRITE COOR COMP UNIT 10 CARD
CLOSE UNIT 10

OPEN WRITE UNIT 20 CARD NAME "ptrpmin.crd" WRITE COOR UNIT 20 CARD
CLOSE UNIT 20
```

How did poly-tryptophan change upon ABNR minimization? To find out we should compare the two coordinate sets, both in Cartesian coordinates and in internal coordinates. The command to calculate the difference between the internal coordinates (preminimization minus postminimization) is:

```
IC DIFF
```

The command to calculation the difference between Cartesian coordinates (preminimization minus postminimization) is:

```
COOR DIFF
```

Now, to print out these differences to the log file, we print out the MAIN Cartesian coordinate set and the IC table, just like we did above to print the coordinates themselves. The original coordinates in these two tables have all been replaced by differences in the coordinates!

```
PRINT COOR PRINT IC
```

> **Question 4**: Judging from the IC table here and above (before minimization), what changed in the structure?
 
> **Question 5**: The structure seems to be shrinking, but not much. (To see this, check the change in distance between two atoms on opposite ends of the peptide). Why? (Hint: think about the absence of solvent or other molecules in the environment.)

10.	Finally, be sure to tell CHARMM that your stream file is finished:

```
STOP
```

11.	Now save your file and exit vi. We will next run the script in CHARMM.

#### Running scripts
To submit a CHARMM script, open the "submit.sh" file and change the value of "infile" to the name of your script. You can also change the value of "outfile" to the name of the file you will store CHARMM’s log. Save the modified file and return to the shell command line. Now all you have to do to submit your script is type `./submit.sh` and push enter. This will submit your job. When CHARMM is done, you will notice that there is a new log file from CHARMM in your working directory.

> If you encounter permission errors when attempting to use the `./` command on a script, use `chmod 774 [filename]` to grant r/w/e privileges to you and your group.

In our stream file, we asked CHARMM to give us some information such as coordinates and energies. These values are recorded in a **log file**. Log files contain not only the information that you requested, but also all the interaction between different subprograms in CHARMM. You’ll recognize your own ptrpmin.str commands showing up as part of these conversations.

With the log file open, go back and answer questions 1-5, then finish the remaining questions.

> **Question 6**: What are the components of the energy? Does the system have any kinetic energy? 

> **Question 7**: What changed in coordinates and potential energies upon minimization of PTRP?

CRD files: Open "ptrp.crd" and "ptrpmin.crd." Again, if they don’t open, you might try holding ‘Ctrl’ while clicking on the file name. Review the structure of the coordinate files, noting how they compare to the output in the logfile from PRINT COOR and notice how the x, y, and z coordinates changed for a few of the atoms.

To finish, send an email to your TA containing the answers to the questions in the lab.

> This isn’t required, but remember how we said CHARMM is a command-line program? If you’re feeling ambitious, you can try out CHARMM on the command line on MaryLou by executing, from the Linux command line, module load charmm and then $(which charmm). You can now perform commands in CHARMM and view output on the fly! (remember to start with a title!)

**[Lab 3](https://busathlab.github.io/mdlab/lab3.html)**

**[Return to home page](https://busathlab.github.io/mdlab/index.html)**
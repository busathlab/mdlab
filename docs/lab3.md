## LAB 3: MOLECULAR STRUCTURE MANIPULATION
###### by Dr. David Busath

---

#### Objectives:
- Learn how to prepare a structure ready for simulations and visualization
- Understand how to use wildcards, `SELECT`, variables, arrays, `DEFINE`, conditional statements, loops
- Use `IC EDIT` to edit internal coordinates 
- Understand the basics of troubleshooting / debuggging
- Learn good coding practices
- Be able to interpret an residue topology file (RTF)
---

### 1. Basic Commands

The Introduction to CHARMM lab previewed how to create molecules from scratch, using `READ SEQUENCE`, `GENERATE`, `IC PARAMETERS`, and `IC BUILD` in CHARMM. Unfortunately, it’s not often that a structure made straight from an RTF is in a biologically relevant form.

As has been mentioned previously, the language of CHARMM consists of many one- or two-word commands. You already know `OPEN`, `CLOSE`, `WRITE COOR`, and the commands needed to build a PSF. In this lab, we take you through a few more of the absolute basics. After you have learned these commands, you can start writing programs in CHARMM. Again, if you ever have any questions about these or any other commands, your first stop should be the [CHARMM Documentation](https://www.charmm.org/charmm/documentation/).

#### Wildcards
In both UNIX and CHARMM, the asterisk `*` can sometimes be used as a wildcard to mean "any set of characters." See the definition of `SELECT...END` below for an example of the wild card in CHARMM.

#### Selections
Imagine having a structure consisting of several segments, but wanting to apply the ENERGY command to only one, or wanting to know the COOR DIFF between only certain atoms in a structure. The set of atoms to which most commands are applied can be shrunk with an **atom selection** using the `SELECT` command ([select.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/select/)). You can specify the subset by using the keywords `ATOMS`, `SEGID` (segment name), `ISEG` (segment number), `RESN` (residue name), or another keyword. Here we use the `SELECT ATOM` command, which is always followed by

1. The segment ID
2. The residue ID 
3. The atom name (though the documentation says type)
4. `END` 

Selections are passed as arguments to various commands within CHARMM. A selection argument of all atoms of a segment called SEG1 for example, would be as follows:

```fortran
SELECT ATOM SEG1 * * END
```

> When two selections are called for, the entire `SELECT...END` command must be repeated twice. To select all atoms of the first residue of SEG1 for the first selection, and second residue of SEG1 for the second selection, the command would be `SELECT ATOM SEG1 1 * END SELECT ATOM SEG1 2 * END`.

#### Variables
There will be occasions when you will need to use a **variable** in a CHARMM script. The `SET` command assigns a value to a variable. For instance, `SET dist 15.3` gives the variable named "dist" a value of 15.3. When you wish to use the value of a variable where CHARMM is expecting a number, you use the variable with a `@` sign in front of it. CHARMM then reads the command containing the variable, as though it contained the value of that variable. An example of this is demonstrated in the following sequence of commands:

```fortran
SET unlucky 13
OPEN READ UNIT 10 CARD NAME "SPIFFY@unlucky.CRD"
```

The command will then be interpreted by CHARMM as:

```diff
- OPEN READ UNIT 10 CARD NAME "SPIFFY@unlucky.CRD"
+ OPEN READ UNIT 10 CARD NAME "SPIFFY13.CRD"
```

> Sometimes variable substitution errors might occur due to quotation marks, multiple names, etc. In cases where you can't figure out why a variable isn't substituting properly, try "protecting" the variable with brackets: `@{variable}`

Variables can also be SET to the values of other internal CHARMM variables. For example, `SET TEMP ?ENER` would set the variable "TEMP" to the total potential energy computed most recently. The command `SET TEMP MINIMIZED` would set the variable "TEMP" to contain the word (or string, for you programmers) "MINIMIZED."

You can manipulate the values stored in variables using `INCR` and `DECR`. The syntax for both of them is the command, the variable name, and the amount to add or subtract. The following command will add 10 to the value stored in number so that the final value of "number" is 10:

```fortran
SET number 0
INCR number 10
```

#### Variable Arrays
Charmm also supports referencing variables in an array-like fashion. For example, if you set a variable with a constant prefix and integer suffix, you can access various variable values later using an `@` in front of the variable name prefix followed by `@@` and the array index you wish to access. Here is an example:

```fortran
SET segName1 M2A
SET segName2 M2B
SET segName3 M2C
SET segName4 M2D
SET index 3

COOR STAT SELE SEGNAME @segName@@index END 
```

In the above example, four sequential variables with the prefix "segName" are set to four different strings. To access the third string in the sequence, or array, of variables, a variable "index" is set to "3". Invoking `@segName@@index` gets the third variable in the array. The final command would be interpreted as follows:

```diff
- COOR STAT SELE SEGNAME @segName@@index END 
+ COOR STAT SELE SEGNAME M2C END 
```

#### Save Selections with `DEFINE`
The `DEFINE` command can be used to save a selection for use throughout a script. For example:

```fortran
DEFINE WATEROXYGENS SELE TYPE OH2 END 
```

This defines a selection named "WATEROXYGENS" to be all of oxygens with the atom type OH2. This definition can then be used later, such as in this example (interpreted):

```diff
- COOR STAT SELE WATEROXYGENS END 
+ COOR STAT SELE TYPE OH2 END 
```

#### Conditional Statements and Boolean Logic
Often conditional statements and loops are handy in CHARMM scripts ([miscom.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/miscom/)). If you have some experience with FORTRAN or the C programming language, the ideas are the same.

Sometimes you only want to run a command if a certain condition is true. Let’s say you minimize your structure for 200 steps of ABNR, and then you want to minimize it again if the total energy is greater than a given value (say, -100 kcal/mol). In this case you could use an if statement. Here’s how you could do it:

```fortran
MINIMIZE ABNR NSTEP 200
SET MYENERGY ?ENER
IF MYENERGY GT -100 MINIMIZE ABNR NSTEP 200
```

`IF` is always followed by 
1. A variable (not preceded by a "@")
2. A conditional
3. A reference (either a value or another variable proceeded by a "@")
4. A CHARMM command

The condition in this example is given by the (`GT`) operator. If the value stored in `MYENERGY` is greater than -100, then CHARMM will execute 200 more steps of minimization. If the value stored in MYENERGY is not greater than -100, then CHARMM will skip over the additional minimization. Besides "greater than", `GT`, we could use the conditionals `EQ` ("equal to"), `NE` ("not equal to"), `GE` ("greater than or equal to"), `LT` ("less than"), or `LE` ("less than or equal to"). To add conditions, you can use the `.and.` operator or `.or.` operator depending on what is desired. 

> See [this guide](https://www.tutorialspoint.com/fortran/fortran_operators.htm) for more information on boolean operators.  

Here is a more complex example of boolean operators that demonstrates one way to define selections for the protein backbone and sidechains:

```fortran
define PROT sele ( segid PROA .or. segid PROB .or. segid PROC .or. segid PROD ) end
define BACKBONE sele ( type C   .or. type O   .or. type N   .or. type CA ) .and. PROT end
define SIDECHAINS sele (.not. BACKBONE) .and. (.not. hydrogen) .and. PROT  end
```

The first definition chooses atoms with the segment ID of PROA, PROB, PROC, or PROB. The second chooses any atoms of type C, O, N, or CA that also fall within the PROT definition. The third selects any atoms that are not selected by the BACKBONE definition, are not hydrogen atoms, and are selected by the PROT definition.

#### Loops
A loop is a piece of a program designed to repeat itself many times ([miscom.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/miscom/)). Loops can be created using the `GOTO` and `LABEL` commands. 

`LABEL` designates the beginning of a loop, and is always followed by the name of the loop. 

`GOTO` is the command that allows for the repetition (iteration) of the loop. `GOTO` must also be followed by the name of the labeled line that CHARMM is to be directed to. 

If we wanted to minimize a structure again and again until the potential energy was less than -100, a loop could be used. Once the energy went below -100, the conditional would not be met, and CHARMM would ignore the GOTO command and go on to the next line. The code would look like this:

```fortran
LABEL LOOP1
MINIMIZE ABNR NSTEP 200
SET MYENERGY ?ENER
IF MYENERGY GT -100 GOTO LOOP1
```

What if we wanted to minimize our structure 200, then 300, then 400 times? We could attack the problem by using 3 different parameters:

```fortran
SET 1 200
SET 2 300
SET 3 400
MINIMIZE ABNR NSTEP @1
MINIMIZE ABNR NSTEP @2
MINIMIZE ABNR NSTEP @3
```

But if we want to increase the number of steps by 100 until the number reached 10000, it would take a long time to enter in all of the commands. Instead of typing 100 commands, you could use a loop:

```fortran
SET n 200
LABEL min_loop
MINIMIZE ABNR NSTEP @n
INCR n BY 100
IF n LE 10000 GOTO min_loop
```

> Loop statements do not work with CHARMM running in parallel across multiple processors. On jobs where this is unavoidable, you must nest the loop within another script and use the `STREAM` command.

> **Question 1**: What would happen if the SET command were inside the loop?

#### Editing internal coordinates with `IC EDIT`
As you might guess, `IC EDIT` ([intcor.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/intcor/)) is used to edit internal coordinates. The command can be followed by as many lines as desired, with each containing 
1. The keywords DIST, ANGLE, or DIHEDRAL
2. An atom selection of two, three, or four atoms for DIST, ANGL, or DIHE, respectively, taking the form `residuenumber atomname` 
3. A value in angstroms or degrees for the distance, angle, or dihedral. 
4. `END` 

Improper dihedrals, as in the IC table, are indicated by an asterisk before the third atom specification. To change the length of a bond (`DISTANCE`) to 2.0 angstroms, for example, `IC EDIT` is used in the following manner:

```fortran
IC EDIT
DIST 3 N 3 C 2.0
END
```

#### Writing to text files with `WRITE TITLE`
Sometimes CHARMM won’t let you write to a file unless it has a title first. Other times you really need the title, to include information about the data in the file. `WRITE TITLE` ([miscom.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/miscom/)) is always followed by the information you want at the top of the file, preceded by asterisks:

```fortran
WRITE TITLE
* This is where you describe the file
*
```

`WRITE TITLE` really gets useful when you want to report the values of internal CHARMM variables not normally reported in the format you want. Imagine doing several energy calculations on different structures, and wanting a concise, sequentially numbered list of the energies. Inside a loop, you might write:

```fortran
WRITE TITLE
* @num ?ENER
*
```

This will write the value of CHARMM variable "num" followed by the potential energy of the current structure to standard output, which is the monitor--unless it was redirected to an output file in the CHARMM command line, (or unless you have opened a file on a unit for writing, as exemplified in line 22 of ALPHAHLX.STR below, and you have specified the unit number in the WRITE TITLE line; but don’t bother with this approach for now).

### 2. Sample Scripts
> **Question 2**: Look at the two scripts on the following pages (ALPHA.STR and ALPHAHLX.STR). The numbers at the far left are for convenience and should not appear in the CHARMM-ready script. Wherever the number at the far left is bold and underlined, tell what that command is doing and, where applicable, what sort of information is contained in the file it makes reference to. (Lab 2 may be helpful here.)

Lines 1-6 are the content of "TOPPARM.STR," the function of which was discussed in Lab 2. Make note of them since you’ll need them in Question 3.

```fortran
************************ALPHA.STR************************
* Copyright 1988 Polygen Corporation
*This input file constructs an alpha helix for polyalanine
*
1 OPEN READ UNIT 11 CARD NAME ~/top_all27_prot_lipid.rtf
2 READ RTF UNIT 11 CARD
3 CLOSE UNIT 11
4 OPEN READ UNIT 11 CARD NAME ~/par_all27_prot_lipid.prm
5 READ PARA UNIT 11 CARD
6 CLOSE UNIT 11
7 READ SEQUENCE CARD
8 * Polyalanine
9 *
10 11
11 ALA ALA ALA ALA ALA ALA ALA ALA ALA ALA ALA
12 GENERATE HELX SETUP
13 IC PARAMETERS
14 SET FSTRES 2 ! First residue to be modified.
15 SET LSTRES 10 ! Last residue to be modified.
16 SET PHI -57.0
17 SET PSI -47.0
18 OPEN READ UNIT 18 CARD NAME "ALPHAHLX.STR"
19 STREAM UNIT 18
20 IC SEED 1 N 1 CA 1 C
21 IC BUILD
22 OPEN WRITE UNIT 40 CARD NAME "ALPHAHLX.PDB"
23 WRITE COOR PDB CARD UNIT 40
24 STOP
```

```fortran
***********************APHAHLX.STR****************************
* Copyright 1988 Polygen Corporation
* This stream file edits the internal coordinate table by defining
* the phi and psi angles to be an alpha helix for a range of residues (CHARMM
* variables FSTRES to LSTRES)
*
! Define variables for residues before and after current residue
1 SET RES @FSTRES
2 CALC NXTRES = @RES+1
3 CALC PRERES = @RES-1
4 LABEL START
! Invoke IC EDIT mode, and define phi and psi dihedral angles
! for an alpha helix
5 IC EDIT
6 DIHE @PRERES C @RES N @RES CA @RES C @PHI
7 DIHE @RES N @RES CA @RES C @NXTRES N @PSI
8 END
! Increment counters and check for last specified residue
9 INCR PRERES BY 1
10 INCR RES BY 1
11 INCR NXTRES BY 1
12 IF RES LE @LSTRES GOTO START
```

With the previous scripts as a model, answer the following question.

> **Question 3**: After the first iteration of the loop in ALPHAHLX.STR (just after line 11), what are the values of `FSTRES`, `LSTRES`, `RES`, `NXTRES`, and `PRERES`? How would CHARMM interpret lines 6 and 7 of "ALPHAHLX.STR" (what would the command look like after CHARMM substituted values for the parameters)?

> **Question 4**: Why is ALPHA.STR set up to modify the dihedrals of residues 2 through 10 and not 1 or 11? (Hint: What would happen in ALPHAHLX.STR if res1 had been set to 1 or res2 had been set to 12?)

> **Question 5**: How would you change this script to build a 3-10 helix with 14 ALA residues, given that in this sort of helix, φ = -49 and ψ = -26? How is it different from an α-helix?

Copy the files for this lab into your personal directory. ALPHA.STR and ALPHAHLX.STR have been provided for you, with the line numbers omitted. Run ALPHA.STR with CHARMM to create alphahlx.pdb. Import this PDB into VMD and examine it. Create the 3-10 helix PDB file (change ALPHA.STR to make "3_10.STR" which in turn creates "3_10.PDB"). Import this "3_10.PDB" into VMD. *Examine the difference between 3-10 and α-helices and describe them in your answer to Question 5.*

### 3. Debugging
#### Fatal Errors
If the writer of a stream file makes a mistake somewhere, CHARMM will often stop before finishing the task. If this happens, there will be a message about 15 lines from the end of the ".LOG" file saying, `Execution terminated due to the detection of a fatal error.` The process of reading the ".LOG" file and trying to decipher what the problem is called debugging, and it consumes most of the lab time of every computer scientist in existence and most molecular modelers too. To witness this gruesome spectacle, read "ALPHA_MESSED.STR." You will find this file after you run ALPHA.STR. It will be with all of the other job files. This is the same program as the one you commented in Question 2, but if you look carefully at line 23 you’ll see a mistake (`SETR` should be `SET`). Save "ALPHA_MESSED.STR" and rename a copy to "MESSED.STR," and run it.

When "MESSED.STR" is finished, read the log file. The last lines, below the one starting `MAXIMUM SPACE USED IS…`, are normal information lines given in every log file whether CHARMM has abnormally terminated or not. The "fatal error" message just above them is what we’re interested in: `Unrecognized command: SETR.` If we were writing a stream file, this message would tell us that something was wrong with the `SETR` command in line 23. We’d have to go back to the stream file, change that command to `SET`, and run our script again. Of course, if our change was also incorrect, then CHARMM would stop this time as well. When debugging, it is often necessary to repeat this process many times in order to execute the file correctly. The most common bugs are often simple typos. For this reason, it is a good idea to take your time when typing scripts.

#### Warning Levels and `BOMLEV`
In this context of bugs and fatal errors, it’s important to take a minute to talk about `BOMLEV`. We just saw CHARMM die when it hit a mistake in "MESSED.STR." CHARMM doesn’t die every time it reads something wrong. In the Introduction to CHARMM lab, for example, CHARMM didn’t think that our choice of non-bonded cutoffs was appropriate, so it gave us a "WARNING" (check "TRPMIN.LOG" from last week if you don’t remember this). In fact, every error in CHARMM programming has a `BOMLEV` ([miscom.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/miscom/)) associated with it, ranging from 5 to -5. The negative levels are pretty severe and the positive, not so bad. In "MESSED.STR" you can see that an unrecognized command is level 0. The command `BOMLEV` dictates at what level error CHARMM crashes. Right now `BOMLEV` is set at the default, zero.

Managing your`BOMLEV` is sort of a tricky business, and you can be content to use 0 for now. To show you a bit of the complexity involved, first, correct line 23 of "ALPHA_MESSED.STR." Then, change line 29 from "ALPHAHLX.STR" to "ALPHAHLX." 

```diff
- 23: SETR FSTRES 2 ! First residue to be modified.
+ 23: SET FSTRES 2 ! First residue to be modified.
...
- 29: OPEN READ UNIT 18 CARD NAME "ALPHAHLX.STR" 
+ 29: OPEN READ UNIT 18 CARD NAME "ALPHAHLX" 
```

Now, there’s no such file as "ALPHAHLX" in your directory, so when you tell CHARMM to read this stream file, it won’t be able to read anything. Save your file and run "ALPHA_MESSED.STR" again. Look carefully at the new log file.

Although CHARMM was not able to read "ALPHAHLX," the program doesn’t crash because the `BOMLEV` wasn’t set low enough. Of course, without the stream file, "MESSED.STR" won’t change the dihedrals of our polypeptide to build an alpha-helix. This is why you must always read your log files even if CHARMM doesn’t crash openly. This raises a question: if it’s such a nuisance to allow CHARMM to continue even after an error like this, why not raise the`BOMLEV`? If we did raise the`BOMLEV`, CHARMM would have crashed in the Introduction to CHARMM lab when it disliked our non-bonded cutoffs, and that would have been a nuisance too.

### 4. Good Programming Practice
One indicator of good computer programmers is the readability of their code. This applies to molecular modelers as well. There are several small tricks that help humans be able to understand scripts.

#### White Space
If this lab had been written as one long paragraph without tabs or blank lines, it would have been harder to read. Scripts can also be easier to read if they contain an appropriate usage of white space. Extra tabs, spaces, and line breaks are considered white space. In stream files, CHARMM does not care if you have one blank space or twenty blank spaces, one blank line or 4 blank lines, they are run the same. Format your scripts so that they are easy to read.

#### Comments
The `!` character is the comment character in CHARMM stream files. This means that anything that comes after `!` is not read by CHARMM. Take a minute and look at "top_all27_prot_lipid.rtf." Compare the residues defined in this file to those printed at the end of this lab. You will notice that in the "top_all27_prot_lipid.rtf" file, there are diagrams of each residue. CHARMM does not read these diagrams because of the `!` on each line. Comments are a great way to explain a cryptic part of your script to make it more readable.

#### Variable Names
When you name variables in your script, make them short and descriptive. For example, if you need a variable to count the number of molecules outside a particular region, you could call it NumInBox or num_in_box. Notice the capitalization. CHARMM is not case-sensitive, meaning it does not distinguish between NumInBox and numinbox. Variations in capitalization can be used to make the program more readable. In these labs, we are using the old-fashioned tradition of capitalizing everything as a syntactical convention to make it easier for you to read the handout. Notice the difference shown between the two examples shown below, which perform the same function.

```diff
- ! Poor Example
- SET 1 6
- SET 2 10
- SET 3 4
- SET 4 5
- SET 5 1 LABEL THINGY INCR 2 BY @2 INCR 3 BY @3 INCR 4 BY @4 INCR 5 BY 1
- IF 5 LE @1 GOTO THINGY
- INCR 1 by @2 INCR 1 by @3

+ ! Better Example
+ ! script computes x(a+b+c) SET x 6
+ SET a 10
+ SET b 4
+ SET c 5
+ 
+ ! Add a, b, and c x times SET count 1
+ LABEL start INCR a BY @a INCR b BY @b INCR c BY @c INCR count BY 1
+ IF count LE @x GOTO start
+ 
+ ! sum the products SET answer @a
+ INCR answer by @b
+ INCR answer by @c
```

> **Question 6**: Write a script that builds a polypeptide ALA-GLU-TRP and produces three "PDB" files called "ALA.PDB," " GLU.PDB," and "TRP.PDB" which contain only the atoms in the first, second, or third residues, respectively. Use the `SELE`, `ATOM`, `SET`, and `LABEL` (loop) commands in your script. Use a separate stream file and call it "ala_glu_trp.str". When writing this script, keep the sheet from the Introduction to CHARMM lab close by your side. Don’t forget, right after your title, your first commands to CHARMM must be lines 1-6 from "ALPHA.STR," which are the commands in "TOPPARM.STR." One more reminder: you must close a unit if you wish to use its number again.

Run "ala_glu_trp.str." Read "ala_glu_trp.log". If you have any errors, make an effort to correct the problem on your own. Go back to your "ala_glu_trp.log" and try to see what went wrong (look for typos, and make sure you phrased things exactly as they’re listed in previous labs), make a change, and rerun. Comment the file appropriately. *When you submit your answers for this lab to the T.A., please attach your copy of the working stream file.*

### 5. RTF files
A **Residue Topology File (RTF)** ([rtop.doc](https://www.charmm.org/charmm/documentation/by-version/c37b1/params/doc/rtop/)) is a collection of information about the charge, connectivity, and arrangement in space of a polymeric residue or a molecule. On the attached pages are some sample RTFs for different amino acids. The GROU lines are used for simplifying electrostatic calculations when needed.

The first lines, which begin with `ATOM`, are quite simply a list of all the atoms that the residues (and molecules) in the file could contain. The atom list information is in the order `ATOM [atomname] [atomtype] [partial charge]`.

`AUTOGENERATE ANGLES` causes the angle list to be generated from the bond list.

The lines which begin with `BOND` determine which atoms are covalently bonded. The bond information is in the form `BOND [atomname (i)] [atomname (j)]`. Don’t get confused if there are several of these in a row. The purpose of these lines is to create listed of bonded interactions for the ENERGY function (not to specify the internal coordinates--that is the purpose of the IC lines alone, which are found below).

Lines that begin with `DOUBLE` specify double bonds.

There are no `ANGLE` lines because those are autogenerated from the bond list.

The lines that begin `DIHE` specify all the dihedral angles that will contribute to the energy.

The lines that begin `IMPR` specify "improper dihedral" relationships, which are artificial energy terms (or "penalties" if you like) used to enforce miscellaneous features of the molecular geometry related to electron structure such as chirality or planarity of conjugated ring structures.

Following these lines are lists of hydrogen bond donors and acceptors, which are only used in the hydrogen-bond detection facility, and not for energy calculations.

The remainder of the residue specification is a list of IC lines. Recall from the Introduction to CHARMM lab that the numbers represent bond length, angle, dihedral, angle, and bond length. Many times, all but the dihedral angle are given as 0.0 in the RTF. Here the numbers serve as placeholders. Any 0.0 will be replaced by the parameter file value for the corresponding atom types when `IC PARAM` is executed prior to `IC SEED` and `IC BUILD`.

> **Question 7**: Identify residues A through E. Use your intuition, focusing first on the atoms that are listed as bonded together and the atom types in the ATOM lines. You may want to open top_all27_prot_lipid.rtf to check the atom types and their typical usage at the top of the file.

Now that you have a bit of experience in deciphering RTFs, it’s time to try something a little tougher: writing one. This will give you a better idea of what is contained in these files and will provide valuable practice.

> **Question 8**: Given the RTFs for phosphotyrosine and threonine, **create an RTF for phosphothreonine**. (Hint: threonine should be phosphorylated in a way analogous to tyrosine.) You are not expected to fill in the IC tables portion of the RTF, though you are welcome to attempt it if you desire.

When you are done answering all of the questions, email your answers to your T.A. **_Be sure to attach "ala_glu_trp.str."_**

```fortran
RESI ??A?? 0.00
GROUP
ATOM N NH1 -0.47
ATOM HN H 0.31
ATOM CA CT1 0.07
ATOM HA HB 0.09
GROUP
ATOM CB CT3 -0.27
ATOM HB1 HA 0.09
ATOM HB2 HA 0.09
ATOM HB3 HA 0.09
GROUP
ATOM C C 0.51
ATOM O O -0.51
BOND CB CA N HN N CA
BOND C CA C +N CA HA CB HB1 CB HB2 CB HB3
DOUBLE O C
IMPR N -C CA HN C CA +N O
DONOR HN N
ACCEPTOR O C
IC -C CA *N HN 1.3551 126.4900 180.0000 115.4200 0.9996
IC -C N CA C 1.3551 126.4900 180.0000 114.4400 1.5390
IC N CA C +N 1.4592 114.4400 180.0000 116.8400 1.3558
IC +N CA *C O 1.3558 116.8400 180.0000 122.5200 1.2297
IC CA C +N +CA 1.5390 116.8400 180.0000 126.7700 1.4613
IC N C *CA CB 1.4592 114.4400 123.2300 111.0900 1.5461
IC N C *CA HA 1.4592 114.4400 -120.4500 106.3900 1.0840
IC C CA CB HB1 1.5390 111.0900 177.2500 109.6000 1.1109
IC HB1 CA *CB HB2 1.1109 109.6000 119.1300 111.0500 1.1119
IC HB1 CA *CB HB3 1.1109 109.6000 -119.5800 111.6100 1.1114
```

```fortran
RESI ??B?? 0.00
GROUP
ATOM N NH1 -0.47
ATOM HN H 0.31
ATOM CA CT1 0.07
ATOM HA HB 0.09
GROUP
ATOM CB CT2 -0.18
ATOM HB1 HA 0.09
ATOM HB2 HA 0.09
GROUP
ATOM CG CY -0.03
ATOM CD1 CA 0.035
ATOM HD1 HP 0.115
ATOM NE1 NY -0.61
ATOM HE1 H 0.38
ATOM CE2 CPT 0.13
ATOM CD2 CPT -0.02
GROUP
ATOM CE3 CA -0.115
ATOM HE3 HP 0.115
GROUP
ATOM CZ3 CA -0.115
ATOM HZ3 HP 0.115
GROUP
ATOM CZ2 CA -0.115
ATOM HZ2 HP 0.115
GROUP
ATOM CH2 CA -0.115
ATOM HH2 HP 0.115
GROUP
ATOM C C 0.51
ATOM O O -0.51
BOND CB CA CG CB CD2 CG NE1 CD1
BOND CZ2 CE2
BOND N HN N CA C CA C +N
BOND CZ3 CH2 CD2 CE3 NE1 CE2 CA HA CB HB1
BOND CB HB2 CD1 HD1 NE1 HE1 CE3 HE3 CZ2 HZ2
BOND CZ3 HZ3 CH2 HH2
DOUBLE O C CD1 CG CE2 CD2 CZ3 CE3 CH2 CZ2
IMPR N -C CA HN C CA +N O
DONOR HN N
DONOR HE1 NE1
ACCEPTOR O C
IC -C CA *N HN 1.3482 123.5100 180.0000 115.0200 0.9972
IC -C N CA C 1.3482 123.5100 180.0000 107.6900 1.5202
IC N CA C +N 1.4507 107.6900 180.0000 117.5700 1.3505
IC +N CA *C O 1.3505 117.5700 180.0000 121.0800 1.2304
IC CA C +N +CA 1.5202 117.5700 180.0000 124.8800 1.4526
IC N C *CA CB 1.4507 107.6900 122.6800 111.2300 1.5560
IC N C *CA HA 1.4507 107.6900 -117.0200 106.9200 1.0835
IC N CA CB CG 1.4507 111.6800 180.0000 115.1400 1.5233
IC CG CA *CB HB1 1.5233 115.1400 119.1700 107.8400 1.1127
IC CG CA *CB HB2 1.5233 115.1400 -124.7300 109.8700 1.1118
IC CA CB CG CD2 1.5560 115.1400 90.0000 123.9500 1.4407
IC CD2 CB *CG CD1 1.4407 123.9500 -172.8100 129.1800 1.3679
IC CD1 CG CD2 CE2 1.3679 106.5700 -0.0800 106.6500 1.4126
IC CG CD2 CE2 NE1 1.4407 106.6500 0.1400 107.8700 1.3746
IC CE2 CG *CD2 CE3 1.4126 106.6500 179.2100 132.5400 1.4011
IC CE2 CD2 CE3 CZ3 1.4126 120.8000 -0.2000 118.1600 1.4017
IC CD2 CE3 CZ3 CH2 1.4011 118.1600 0.1000 120.9700 1.4019
IC CE3 CZ3 CH2 CZ2 1.4017 120.9700 0.0100 120.8700 1.4030
IC CZ3 CD2 *CE3 HE3 1.4017 118.1600 -179.6200 121.8400 1.0815
IC CH2 CE3 *CZ3 HZ3 1.4019 120.9700 -179.8200 119.4500 1.0811
IC CZ2 CZ3 *CH2 HH2 1.4030 120.8700 -179.9200 119.5700 1.0811
IC CE2 CH2 *CZ2 HZ2 1.3939 118.4200 179.8700 120.0800 1.0790
IC CD1 CE2 *NE1 HE1 1.3752 108.8100 177.7800 124.6800 0.9767
IC CG NE1 *CD1 HD1 1.3679 110.1000 178.1000 125.4300 1.0820
```

```fortran
RESI ??C?? 0.00
GROUP
ATOM N NH1 -0.47
ATOM HN H 0.31
ATOM CA CT1 0.07
ATOM HA HB 0.09
GROUP
ATOM CB CT1 -0.09
ATOM HB HA 0.09
GROUP
ATOM CG2 CT3 -0.27
ATOM HG21 HA 0.09
ATOM HG22 HA 0.09
ATOM HG23 HA 0.09
GROUP
ATOM CG1 CT2 -0.18
ATOM HG11 HA 0.09
ATOM HG12 HA 0.09
GROUP
ATOM CD CT3 -0.27
ATOM HD1 HA 0.09
ATOM HD2 HA 0.09
ATOM HD3 HA 0.09
GROUP
ATOM C C 0.51
ATOM O O -0.51
BOND CB CA CG1 CB CG2 CB CD CG1
BOND N HN N CA C CA C +N
BOND CA HA CB HB CG1 HG11 CG1 HG12 CG2 HG21
BOND CG2 HG22 CG2 HG23 CD HD1 CD HD2 CD HD3
DOUBLE O C
IMPR N -C CA HN C CA +N O
DONOR HN N
ACCEPTOR O C
IC -C CA *N HN 1.3470 124.1600 180.0000 114.1900 0.9978
IC -C N CA C 1.3470 124.1600 180.0000 106.3500 1.5190
IC N CA C +N 1.4542 106.3500 180.0000 117.9700 1.3465
IC +N CA *C O 1.3465 117.9700 180.0000 120.5900 1.2300
IC CA C +N +CA 1.5190 117.9700 180.0000 124.2100 1.4467
IC N C *CA CB 1.4542 106.3500 124.2200 112.9300 1.5681
IC N C *CA HA 1.4542 106.3500 -115.6300 106.8100 1.0826
IC N CA CB CG1 1.4542 112.7900 180.0000 113.6300 1.5498
IC CG1 CA *CB HB 1.5498 113.6300 114.5500 104.4800 1.1195
IC CG1 CA *CB CG2 1.5498 113.6300 -130.0400 113.9300 1.5452
IC CA CB CG2 HG21 1.5681 113.9300 -171.3000 110.6100 1.1100
IC HG21 CB *CG2 HG22 1.1100 110.6100 119.3500 110.9000 1.1102
IC HG21 CB *CG2 HG23 1.1100 110.6100 -120.0900 110.9700 1.1105
IC CA CB CG1 CD 1.5681 113.6300 180.0000 114.0900 1.5381
IC CD CB *CG1 HG11 1.5381 114.0900 122.3600 109.7800 1.1130
IC CD CB *CG1 HG12 1.5381 114.0900 -120.5900 108.8900 1.1141
IC CB CG1 CD HD1 1.5498 114.0900 -176.7800 110.3100 1.1115
IC HD1 CG1 *CD HD2 1.1115 110.3100 119.7500 110.6500 1.1113
IC HD1 CG1 *CD HD3 1.1115 110.3100 -119.7000 111.0200 1.1103
```

```fortran
RESI ??D?? 0.00
GROUP
ATOM N NH1 -0.47
ATOM HN H 0.31
ATOM CA CT1 0.07
ATOM HA HB 0.09
GROUP
ATOM CB CT2 -0.18
ATOM HB1 HA 0.09
ATOM HB2 HA 0.09
GROUP
ATOM CG CT2 -0.18
ATOM HG1 HA 0.09
ATOM HG2 HA 0.09
GROUP
ATOM CD CC 0.55
ATOM OE1 O -0.55
GROUP
ATOM NE2 NH2 -0.62
ATOM HE21 H 0.32
ATOM HE22 H 0.30
GROUP
ATOM C C 0.51
ATOM O O -0.51
BOND CB CA CG CB CD CG NE2 CD
BOND N HN N CA C CA
BOND C +N CA HA CB HB1 CB HB2 CG HG1
BOND CG HG2 NE2 HE21 NE2 HE22
DOUBLE O C CD OE1
IMPR N -C CA HN C CA +N O
IMPR CD NE2 CG OE1 CD CG NE2 OE1
IMPR NE2 CD HE21 HE22 NE2 CD HE22 HE21
DONOR HN N
DONOR HE21 NE2
DONOR HE22 NE2
ACCEPTOR OE1 CD
ACCEPTOR O C
IC -C CA *N HN 1.3477 123.9300 180.0000 114.4500 0.9984
IC -C N CA C 1.3477 123.9300 180.0000 106.5700 1.5180
IC N CA C +N 1.4506 106.5700 180.0000 117.7200 1.3463
IC +N CA *C O 1.3463 117.7200 180.0000 120.5900 1.2291
IC CA C +N +CA 1.5180 117.7200 180.0000 124.3500 1.4461
IC N C *CA CB 1.4506 106.5700 121.9100 111.6800 1.5538
IC N C *CA HA 1.4506 106.5700 -116.8200 107.5300 1.0832
IC N CA CB CG 1.4506 111.4400 180.0000 115.5200 1.5534
IC CG CA *CB HB1 1.5534 115.5200 120.9300 106.8000 1.1147
IC CG CA *CB HB2 1.5534 115.5200 -124.5800 109.3400 1.1140
IC CA CB CG CD 1.5538 115.5200 180.0000 112.5000 1.5320
IC CD CB *CG HG1 1.5320 112.5000 118.6900 110.4100 1.1112
IC CD CB *CG HG2 1.5320 112.5000 -121.9100 110.7400 1.1094
IC CB CG CD OE1 1.5534 112.5000 180.0000 121.5200 1.2294
IC OE1 CG *CD NE2 1.2294 121.5200 179.5700 116.8400 1.3530
IC CG CD NE2 HE21 1.5320 116.8400 -179.7200 116.8600 0.9959
IC HE21 CD *NE2 HE22 0.9959 116.8600 -178.9100 119.8300 0.9943
```

```fortran
RESI ??E?? 1.00
GROUP
ATOM N NH1 -0.47
ATOM HN H 0.31
ATOM CA CT1 0.07
ATOM HA HB 0.09
GROUP
ATOM CB CT2 -0.18
ATOM HB1 HA 0.09
ATOM HB2 HA 0.09
GROUP
ATOM CG CT2 -0.18
ATOM HG1 HA 0.09
ATOM HG2 HA 0.09
GROUP
ATOM CD CT2 0.20
ATOM HD1 HA 0.09
ATOM HD2 HA 0.09
ATOM NE NC2 -0.70
ATOM HE HC 0.44
ATOM CZ C 0.64
ATOM NH1 NC2 -0.80
ATOM HH11 HC 0.46
ATOM HH12 HC 0.46
ATOM NH2 NC2 -0.80
ATOM HH21 HC 0.46
ATOM HH22 HC 0.46
GROUP
ATOM C C 0.51
ATOM O O -0.51
BOND CB CA CG CB CD CG NE CD CZ NE
BOND NH2 CZ N HN N CA
BOND C CA C +N CA HA CB HB1
BOND CB HB2 CG HG1 CG HG2 CD HD1 CD HD2
BOND NE HE NH1 HH11 NH1 HH12 NH2 HH21 NH2 HH22
DOUBLE O C CZ NH1
IMPR N -C CA HN C CA +N O
IMPR CZ NH1 NH2 NE
DONOR HN N
DONOR HE NE
DONOR HH11 NH1
DONOR HH12 NH1
DONOR HH21 NH2
DONOR HH22 NH2
ACCEPTOR O C
IC -C CA *N HN 1.3496 122.4500 180.0000 116.6700 0.9973
IC -C N CA C 1.3496 122.4500 180.0000 109.8600 1.5227
IC N CA C +N 1.4544 109.8600 180.0000 117.1200 1.3511
IC +N CA *C O 1.3511 117.1200 180.0000 121.4000 1.2271
IC CA C +N +CA 1.5227 117.1200 180.0000 124.6700 1.4565
IC N C *CA CB 1.4544 109.8600 123.6400 112.2600 1.5552
IC N C *CA HA 1.4544 109.8600 -117.9300 106.6100 1.0836
IC N CA CB CG 1.4544 110.7000 180.0000 115.9500 1.5475
IC CG CA *CB HB1 1.5475 115.9500 120.0500 106.4000 1.1163
IC CG CA *CB HB2 1.5475 115.9500 -125.8100 109.5500 1.1124
IC CA CB CG CD 1.5552 115.9500 180.0000 114.0100 1.5384
IC CD CB *CG HG1 1.5384 114.0100 125.2000 108.5500 1.1121
IC CD CB *CG HG2 1.5384 114.0100 -120.3000 108.9600 1.1143
IC CB CG CD NE 1.5475 114.0100 180.0000 107.0900 1.5034
IC NE CG *CD HD1 1.5034 107.0900 120.6900 109.4100 1.1143
IC NE CG *CD HD2 1.5034 107.0900 -119.0400 111.5200 1.1150
IC CG CD NE CZ 1.5384 107.0900 180.0000 123.0500 1.3401
IC CZ CD *NE HE 1.3401 123.0500 180.0000 113.1400 1.0065
IC CD NE CZ NH1 1.5034 123.0500 180.0000 118.0600 1.3311
IC NE CZ NH1 HH11 1.3401 118.0600 -178.2800 120.6100 0.9903
IC HH11 CZ *NH1 HH12 0.9903 120.6100 171.1900 116.2900 1.0023
IC NH1 NE *CZ NH2 1.3311 118.0600 178.6400 122.1400 1.3292
IC NE CZ NH2 HH21 1.3401 122.1400 -174.1400 119.9100 0.9899
IC HH21 CZ *NH2 HH22 0.9899 119.9100 166.1600 116.8800 0.9914
```

### Reference Residues

```fortran
RESI THR 0.00 		! Threonine
GROUP
ATOM N NH1 -0.47 	! |
ATOM HN H 0.31 		! HN-N
ATOM CA CT1 0.07 	! | OG1--HG1
ATOM HA HB 0.09		! | /
GROUP 				! HA-CA--CB-HB
ATOM CB CT1 0.14 	! | \
ATOM HB HA 0.09 	! | CG2--HG21
ATOM OG1 OH1 -0.66	! O=C / \
ATOM HG1 H 0.43 	! | HG21 HG22
GROUP
ATOM CG2 CT3 -0.27
ATOM HG21 HA 0.09
ATOM HG22 HA 0.09
ATOM HG23 HA 0.09
GROUP
ATOM C C 0.51
ATOM O O -0.51
BOND CB CA OG1 CB CG2 CB N HN
BOND N CA C CA C +N CA HA
BOND CB HB OG1 HG1 CG2 HG21 CG2 HG22 CG2 HG23
DOUBLE O C
IMPR N -C CA HN C CA +N O
DONOR HN N
DONOR HG1 OG1
ACCEPTOR OG1
ACCEPTOR O C
IC -C CA *N HN 1.3471 124.1200 180.0000 114.2600 0.9995
IC -C N CA C 1.3471 124.1200 180.0000 106.0900 1.5162
IC N CA C +N 1.4607 106.0900 180.0000 117.6900 1.3449
IC +N CA *C O 1.3449 117.6900 180.0000 120.3000 1.2294
IC CA C +N +CA 1.5162 117.6900 180.0000 124.6600 1.4525
IC N C *CA CB 1.4607 106.0900 126.4600 112.7400 1.5693
IC N C *CA HA 1.4607 106.0900 -114.9200 106.5300 1.0817
IC N CA CB OG1 1.4607 114.8100 180.0000 112.1600 1.4252
IC OG1 CA *CB HB 1.4252 112.1600 116.3900 106.1100 1.1174
IC OG1 CA *CB CG2 1.4252 112.1600 -124.1300 115.9100 1.5324
IC CA CB OG1 HG1 1.5693 112.1600 -179.2800 105.4500 0.9633
IC CA CB CG2 HG21 1.5693 115.9100 -173.6500 110.8500 1.1104
IC HG21 CB *CG2 HG22 1.1104 110.8500 119.5100 110.4100 1.1109
IC HG21 CB *CG2 HG23 1.1104 110.8500 -120.3900 111.1100 1.1113
```

```fortran
RESI TYR 0.00 		! Tyrosine
GROUP
ATOM N NH1 -0.47 	! | HD1 HE1
ATOM HN H 0.31 		! HN-N | |
ATOM CA CT1 0.07 	! | HB1 CD1--CE1
ATOM HA HB 0.09 	! | | // \\
GROUP 				! HA-CA--CB--CG CZ--OH
ATOM CB CT2 -0.18 	! | | \ __ / \
ATOM HB1 HA 0.09 	! | HB2 CD2--CE2 HH
ATOM HB2 HA 0.09 	! O=C | |
GROUP ! | HD2 HE2
ATOM CG CA 0.00
GROUP
ATOM CD1 CA -0.115
ATOM HD1 HP 0.115
GROUP
ATOM CE1 CA -0.115
ATOM HE1 HP 0.115
GROUP
ATOM CZ CA 0.11
ATOM OH OH1 -0.54
ATOM HH H 0.43
GROUP
ATOM CD2 CA -0.115
ATOM HD2 HP 0.115
GROUP
ATOM CE2 CA -0.115
ATOM HE2 HP 0.115
GROUP
ATOM C C 0.51
ATOM O O -0.51
BOND CB CA CG CB CD2 CG CE1 CD1
BOND CZ CE2 OH CZ
BOND N HN N CA C CA C +N
BOND CA HA CB HB1 CB HB2 CD1 HD1 CD2 HD2
BOND CE1 HE1 CE2 HE2 OH HH
DOUBLE O C CD1 CG CE1 CZ CE2 CD2
IMPR N -C CA HN C CA +N O
DONOR HN N
DONOR HH OH
ACCEPTOR OH
ACCEPTOR O C
IC -C CA *N HN 1.3476 123.8100 180.0000 114.5400 0.9986
IC -C N CA C 1.3476 123.8100 180.0000 106.5200 1.5232
IC N CA C +N 1.4501 106.5200 180.0000 117.3300 1.3484
IC +N CA *C O 1.3484 117.3300 180.0000 120.6700 1.2287
IC CA C +N +CA 1.5232 117.3300 180.0000 124.3100 1.4513
IC N C *CA CB 1.4501 106.5200 122.2700 112.3400 1.5606
IC N C *CA HA 1.4501 106.5200 -116.0400 107.1500 1.0833
IC N CA CB CG 1.4501 111.4300 180.0000 112.9400 1.5113
IC CG CA *CB HB1 1.5113 112.9400 118.8900 109.1200 1.1119
IC CG CA *CB HB2 1.5113 112.9400 -123.3600 110.7000 1.1115
IC CA CB CG CD1 1.5606 112.9400 90.0000 120.4900 1.4064
IC CD1 CB *CG CD2 1.4064 120.4900 -176.4600 120.4600 1.4068
IC CB CG CD1 CE1 1.5113 120.4900 -175.4900 120.4000 1.4026
IC CE1 CG *CD1 HD1 1.4026 120.4000 178.9400 119.8000 1.0814
IC CB CG CD2 CE2 1.5113 120.4600 175.3200 120.5600 1.4022
IC CE2 CG *CD2 HD2 1.4022 120.5600 -177.5700 119.9800 1.0813
IC CG CD1 CE1 CZ 1.4064 120.4000 -0.1900 120.0900 1.3978
IC CZ CD1 *CE1 HE1 1.3978 120.0900 179.6400 120.5800 1.0799
IC CZ CD2 *CE2 HE2 1.3979 119.9200 -178.6900 119.7600 1.0798
IC CE1 CE2 *CZ OH 1.3978 120.0500 -178.9800 120.2500 1.4063
IC CE1 CZ OH HH 1.3978 119.6800 175.4500 107.4700 0.9594
```

```fortran
RESI PTYR -1.00 	! Phosphotyrosine
GROUP
ATOM N NH1 -0.47 	! | HD1 HE1
ATOM HN H 0.31 		! HN-N | |
ATOM CA CT1 0.07 	! | HB1 CD1--CE1 OC1
ATOM HA HB 0.09 	! | | // \\ |
GROUP 				! HA-CA--CB--CG CZ--OH--PO4—OC2
ATOM CB CT2 -0.18 	! | | \ __ / |
ATOM HB1 HA 0.09 	! | HB2 CD2--CE2 OC3
ATOM HB2 HA 0.09 	! O=C | |
GROUP ! | HD2 HE2
ATOM CG CA 0.00
GROUP
ATOM CD1 CA -0.115
ATOM HD1 HP 0.115
GROUP
ATOM CE1 CA -0.115
ATOM HE1 HP 0.115
GROUP
ATOM CZ CA 0.11
ATOM OH OH1 -0.54
ATOM PO4 P04 1.098
ATOM OC1 OC -0.556
ATOM OC2 OC -0.556
ATOM OC3 OC -0.556
GROUP
ATOM CD2 CA -0.115
ATOM HD2 HP 0.115
GROUP
ATOM CE2 CA -0.115
ATOM HE2 HP 0.115
GROUP
ATOM C C 0.51
ATOM O O -0.51
BOND CB CA CG CB CD2 CG CE1 CD1
BOND CZ CE2 OH CZ
BOND N HN N CA C CA C +N
BOND CA HA CB HB1 CB HB2 CD1 HD1 CD2 HD2
BOND CE1 HE1 CE2 HE2 OH PO4 PO4 OC1 PO4 OC2
BOND PO4 OC3
DOUBLE O C CD1 CG CE1 CZ CE2 CD2
IMPR N -C CA HN C CA +N O
DONOR HN N
ACCEPTOR OH
ACCEPTOR O C
IC -C CA *N HN 1.3476 123.8100 180.0000 114.5400 0.9986
IC -C N CA C 1.3476 123.8100 180.0000 106.5200 1.5232
IC N CA C +N 1.4501 106.5200 180.0000 117.3300 1.3484
IC +N CA *C O 1.3484 117.3300 180.0000 120.6700 1.2287
IC CA C +N +CA 1.5232 117.3300 180.0000 124.3100 1.4513
IC N C *CA CB 1.4501 106.5200 122.2700 112.3400 1.5606
IC N C *CA HA 1.4501 106.5200 -116.0400 107.1500 1.0833
IC N CA CB CG 1.4501 111.4300 180.0000 112.9400 1.5113
IC CG CA *CB HB1 1.5113 112.9400 118.8900 109.1200 1.1119
IC CG CA *CB HB2 1.5113 112.9400 -123.3600 110.7000 1.1115
IC CA CB CG CD1 1.5606 112.9400 90.0000 120.4900 1.4064
IC CD1 CB *CG CD2 1.4064 120.4900 -176.4600 120.4600 1.4068
IC CB CG CD1 CE1 1.5113 120.4900 -175.4900 120.4000 1.4026
IC CE1 CG *CD1 HD1 1.4026 120.4000 178.9400 119.8000 1.0814
IC CB CG CD2 CE2 1.5113 120.4600 175.3200 120.5600 1.4022
IC CE2 CG *CD2 HD2 1.4022 120.5600 -177.5700 119.9800 1.0813
IC CG CD1 CE1 CZ 1.4064 120.4000 -0.1900 120.0900 1.3978
IC CZ CD1 *CE1 HE1 1.3978 120.0900 179.6400 120.5800 1.0799
IC CZ CD2 *CE2 HE2 1.3979 119.9200 -178.6900 119.7600 1.0798
IC CE1 CE2 *CZ OH 1.3978 120.0500 -178.9800 120.2500 1.4063
IC CE1 CZ OH HH 1.3978 119.6800 175.4500 107.4700 0.9594
(etc)
```

**[Lab 4](https://busathlab.github.io/mdlab/lab4.html)**

**[Return to home page](https://busathlab.github.io/mdlab/index.html)**
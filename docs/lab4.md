## LAB 4: ENERGY MINIMIZATION
###### by Dr. David Busath

---

#### Objectives:
- Explore the `ENERGY` function deeper
- Understand the Protein Structure File format
- Implement the `PATCH` command
- Use the various types of minimization methods
- Understand how to use `NOE` contraints

---

In the previous labs we have, on a number of occasions, asked you to perform an energy minimization without going into detail about the process. In this lab we will explore minimization and the Energy function, but first, let’s learn more about the next level in the CHARMM data structures: the PSF file.

### 1. The Principle Structure File and Patches
The PSF file was originally called the Protein Structure File, but the name was converted to the Principle Structure File with the advent of DNA, lipids, etc. It is like the residue topology file, but contains the topology information for your whole system (NAMD PSF tutorial). For instance, if you have a 6-residue peptide, the PSF will contain the atoms types and partial charges for each of the residues, as well as the connections between the residues. In this regard, the PSF is a super-RTF. However, the style of the bond-pair and other bonded interactions are a bit different from the RTF and there are additional structures for H-bonding and other purposes that are non-transparent at the end. We will not concern ourselves with these, but will examine the PSF to learn exactly what takes place when a PSF patch is applied.
PSF patches are designed to modify the PSF for a segment after it has been generated. For instance, you might want to attach a palmitoyl group to a Cys side chain, or link a Heme residue to a His side chain after building a protein. These “post-translational modifications” are carried out in CHARMM by commands that delete existing atoms in the protein and then add in others.
A patch is very similar to a residue (struct.doc). Both are defined in the RTF. Residues are specified with the RESI keyword (short for residue) while patches are specified by the PRES keyword (short for patch residue). Patches are usually used to modify existing PSF structures, while residues are used to generate PSF structures. For example, PRES DISU removes the terminal H on two Cys side chains and then installs a bond between the side chain Sulfurs:
PRES DISU -0.36 ! patch for disulfides. Patch must be 1-CYS and 2-CYS.
GROUP ! use in a patch statement
ATOM 1CB CT2 -0.10 !
ATOM 1SG SM -0.08 ! 2SG--2CB--
GROUP ! /
ATOM 2SG SM -0.08 ! -1CB--1SG
ATOM 2CB CT2 -0.10 !
DELETE ATOM 1HG1
DELETE ATOM 2HG1
BOND 1SG 2SG
ANGLE 1CB 1SG 2SG 1SG 2SG 2CB
DIHE 1HB1 1CB 1SG 2SG 1HB2 1CB 1SG 2SG
DIHE 2HB1 2CB 2SG 1SG 2HB2 2CB 2SG 1SG
DIHE 1CA 1CB 1SG 2SG 1SG 2SG 2CB 2CA
DIHE 1CB 1SG 2SG 2CB
!DIHE 1CB 1SG 2SG 2CB
IC 1CA 1CB 1SG 2SG 0.0000 0.0000 180.0000 0.0000 0.0000
IC 1CB 1SG 2SG 2CB 0.0000 0.0000 90.0000 0.0000 0.0000
35
Lab 4: Energy Minimization
IC 1SG 2SG 2CB 2CA 0.0000 0.0000 180.0000 0.0000 0.0000
Notice where the two hydrogen atoms are deleted and the disulfide bond is added. To apply the patch, you issue the command after the segment(s) containing the protein(s) is (are) generated:
PATCH DISU segn1 resi1 segn2 resi2
Segn1 and resi1 represent the name of the segment and the number of the residue that correspond to the first residue in the patch. Segn2 and resi2 likewise represent the name of the segment and the number of the second residue in the patch. They are treated as arguments and used to replace 1-CYS and 2-CYS as they appear in the text.
Let’s use this with a 16-residue fragment from SNAP25, the synaptic vesicle fusion protein, which has 4 Cys residues in the center. One might imagine that these would be prone to be reduced when the protein is in the cytoplasm, allowing the protein to stretch out, and then to be oxidized when the protein is in the membrane, inducing a hairpin conformation for the protein.
The fragment sequence for SNAP25 can be read into CHARMM using the stream file “build_snap25.str.” Open “build_snap25.str” and observe that this script opens the SNAP25 sequence, generates the segment “SNAP,” and builds the Cartesian coordinates from the IC table (note: you should be able to do this on your own. If you are confused about what is going on in this file, you should review the previous labs so that you have a good understanding of the basics of building proteins).
In a new input file, open the topology and parameter files and then stream “build_snap25.str.” After streaming “build_snap25.str”, use PRINT PSF to write the PSF data structure to the log file at this juncture. Then, add the PATCH command shown above twice to introduce two disulfide bonds, one between residues 5 and 12 and another between residues 8 and 10. Then PRINT PSF again. Write a coordinate file in PDB format for viewing the structure, which should, at this stage, just be an extended rod. Also, write the PSF and coordinates to .PSF and .CRD files for use in the next script. That way you won’t have to rebuild the molecules again. The CHARMM commands to write these files are as follows:
OPEN WRITE UNIT 1 CARD NAME snap25.pdb
WRITE COOR PDB UNIT 1 CARD
* SNAP25 FRAGMENT
*
CLOSE UNIT 1
OPEN WRITE UNIT 1 CARD NAME snap25.crd
WRITE COOR UNIT 1 CARD
* SNAP25 FRAGMENT
*
CLOSE UNIT 1
OPEN WRITE UNIT 2 CARD NAME snap25.psf
WRITE PSF UNIT 2 CARD
* SNAP25 FRAGMENT
*
CLOSE UNIT 2
36
Lab 4: Energy Minimization
Question 1: How has the PSF changed? Why doesn’t VMD show the disulfide bonds? (While it isn’t necessary, you might find it helpful to write the PSF’s to individual files that can be loaded in VMD and compared, rather than just viewed in the log file.)
If we were building the whole protein, we might next wind the appropriate residues at each end of the protein into alpha-helices using the stream files from last week. These files change the values of the dihedrals PSI and PHI in the IC table, but do not change the Cartesian coordinates. To change the Cartesian coordinates, you would have to first initialize the Cartesian coordinates of those atoms you expect to be moved in the new conformations. For this, you would use the COOR INIT command, selecting those atoms to be initialized. IC BUILD could then rebuild the initialized coordinates based upon the remaining coordinates and the edited IC table. We will skip over this, however, for the sake of time so that we can move on to minimization.
II. Minimization and Energy
Now we need to allow the two halves of the fragment to form the hairpin and the disulfide bonds to shorten to a normal length. Energy minimization is an algorithm that searches for a local minimum (minimiz.doc). Molecular dynamics can be used to further anneal the structure and explore conformational space. Use the PSF and CRD files that you generated together with the stream file below named iama_minimzer1.str (which is located in the charmmlab directory). This will minimize the structure for 500 steps of steepest decent (SD) writing the energy out to the log file every 10 steps. Run this STR file and note, in the log file produced, what the energy was after 0, 10, and 500 steps. Particularly, pay attention to the bond energy term, which should be huge to begin with. You will see in the LOG file that CHARMM is warning you that certain pairs of atom are too close together or that certain dihedrals are stretched. These warnings should decrease in number as the minimization progresses.
Next, alter the .str file so that it now does 500 steps of Adopted Basis Newton - Raphson (ABNR) minimization on the initial structure instead and save the STR file as iama_minimizer2.str. Note the values after 0, 10 and 500 steps. ABNR is a somewhat more complicated algorithm that is designed to find the minimum faster, albeit less robustly, than SD. It is usually used to refine a fit after SD is used to get close to a local minimum. The structure of the two files is shown below.
*********************iama_minimizer1.str***************************
* Minimizes the peptide using SD minimization
*
STREAM TOPPARM.STR
OPEN READ CARD UNIT 11 NAME snap25.psf
READ PSF CARD UNIT 11
CLOSE UNIT 11
OPEN READ CARD UNIT 11 NAME snap25.crd
READ COOR CARD UNIT 11
CLOSE UNIT 11
MINI SD NSTEP 500 NPRINT 10
STOP
37
Lab 4: Energy Minimization
*********************iama_minimizer2.str***************************
* Minimizes the peptide using ABNR minimization
*
STREAM TOPPARM.STR
OPEN READ CARD UNIT 11 NAME snap25.psf
READ PSF CARD UNIT 11
CLOSE UNIT 11
OPEN READ CARD UNIT 11 NAME snap25.crd
READ COOR CARD UNIT 11
CLOSE UNIT 11
MINI ABNR NSTEP 500 NPRINT 10
STOP
Question 2: Which method has reached a lower value of energy after 500 steps (SD or ABNR)? By how much?
ABNR sure seems to be slower so far, but it is designed to do the best when the total energy is not at exponential values. Create two new stream files: one that does 100 SD on the original structure, and one that does 50 SD then 50 ABNR. Run each of these stream files.
Question 3: Which structure has the lower energy now? By how much?
Conjugate Gradient (CONJ) is supposed to be very similar to SD (each step takes about the same amount of time) except that it has a slightly better algorithm - one that remembers how effective the last minimization step is and directs the step orientation and it’s size accordingly. Write a script that minimizes the original structure for 50 steps of CONJ.
Question 4: How did the 50 steps of CONJ compare to 50 steps of SD? (Retrieve the 50th step of SD from the log file – located part way through the 500-step minimization).
Now write a stream file that minimizes the original structure first for 50 SD, then 1000 ABNR. Note that the structure drops in energy by smaller and smaller amounts. Also note the rms force per atom or root-mean-squared gradient, which is listed in the energy print out as GRMS. The rms force is the root mean squared force on the atoms of this structure - a measure of the stress on the molecule. At a local minimum, the force would be equal to 0.0. It is usually a good indication of how well minimized a structure is.
How good is good enough? Usually an rms force less than 1.0 is the minimum preparation needed for heating in molecular dynamics. A value less than 0.1 is considered very well minimized. Remember – even an extremely well minimized structure is probably still just in a local minimum, so no use getting carried away here. A value less than 1.0 is generally good enough that the system will not spontaneously heat up and cause an “Energy Tolerance Exceeded” crash in the initial stages of molecular dynamics.
38
Lab 4: Energy Minimization
By the way, when performing a minimization, CHARMM looks at the change in energy of the structure. If the change is smaller than a set tolerance parameter, the program decides that the structure is minimized well enough and quits out of the minimization. You may see this some day and wonder why CHARMM stopped in the middle of a minimization. It is not a bug--this is CHARMM’s way of being more efficient.
III. Constraints
CHARMM allows you to add energy terms to minimizations (and dynamics) called constraints (cons.doc). There are three basic types of constraints: Atom, Distance, and Dihedral. Harmonic atom constraints allow you to confine an atom near its current X Y Z coordinates by a restoring force. The strength of the force can be varied. The associated energy has units of kcal/ (Angstrom from the initial position)2. Another type of atom constraint is the Fixed constraint, which toggles off the “move flag” for selected atoms. They will not be moved during minimization or dynamics, and interactions between fixed atoms will not be added to the potential energy. Distance constraints allow you to fix the distance between two atoms with a specific force, allowing the user to keep specific atoms within a certain distance of one another. Dihedral constraints create a restoring force which holds the value of a dihedral angle near to a specific value. These commands each allow you to control a minimization or a dynamics run in specific ways. Here we will use constraints to answer a real question from our research:
Years ago we were trying to design a cyclic peptide to bind calcium. The sequence being explored was: EPPEP PEPPE PP. We hoped that the 4 negatively charged glutamic acids would bind calcium, and the prolines would keep the peptide well defined. Experimentally, the peptide would be synthesized first as a linear peptide; then the N- and C-termini would be linked chemically forming a cyclic peptide. But could this cyclization step be energetically feasible in the test tube? It is possible that the peptide might stay extended, that the N- and C-termini could only approach each other under unreasonable strain, and that such contacts would happen at so low a rate that the reaction would not produce much product. Or it might easily bend, and we could expect quite a lot of product. This is something we should try to estimate before blowing $1000 on synthesizing this thing. So let’s use CHARMM to find out the stress involved in cyclizing the peptide in a simple way.
First use CHARMM to create the linear version of the peptide. Write a .pdb file named “pre-min.pdb” for viewing with VMD. Minimize it for 200 ABNR. Write another .pdb file named “post-min.pdb.” Finally, write .crd and .psf files so that you don’t have to rebuild and minimize the structure in the next section. Compare the two .pdb files in VMD. The N- & C-termini don’t rush toward each other, but the structure does seem to change a little.
Minimization just gives us a local minimum. What we wish to see may not be a minimum, but may not be too far from one in energy. If we did dynamics for long enough we could watch for a conformation with the N- & C-termini near one another, but this might take quite a long dynamics run. Instead we will use a NOE constraint, which is a “distance” or “target” constraint. (NOE stands for Nuclear Overhauser Effect, which is a proximity signal obtained in NMR).
Create a new stream file named “constrained.str.” Copy the format of “iama_minimizer1.str” to load the structure that you just made above. (Be sure to only use “iama_minimizer1.str” as a template, i.e. do not include any of the commands (like MINI for example), other than those necessary to load the protein.)
39
Lab 4: Energy Minimization
With the protein loaded, you can apply the constraint. The following code will use an NOE constraint to pull the ends together:
NOE
ASSI SELE ATOM SEGN 1 N END SELE ATOM SEGN 12 C END -
KMAX 100.0 RMAX 3.0 FMAX 1000.0 RSUM
END
The NOE keyword marks the beginning of an NOE block and the keyword END marks the end. ASSI stands for assign. SELE invokes the selection command that was covered in the Molecular Structure Manipulation lab. SEGN should be changed to the name of the segment that you generated when you created the peptide. The space followed by a hyphen means that the next line should be concatenated onto the current line. This code will assign a constraint between the N atom of the first residue and the C atom of the twelfth residue. RMAX specifies the largest distance between the two selections that will be penalty free. For greater distances, a harmonic penalty will be applied with KMAX as the energy constant.
Calculate the energy of the structure, using the ENER command. Now do 25 steps of SD and 1000 steps of ABNR. Write a .pdb file named “constrained.pdb” to view in VMD. Turn off the constraints using the command RESET (which stands for reset) embedded in a new NOE block. Then recalculate the energy. Run your script and open “constrained.pdb” in VMD. Note that the ends came together. This is similar to what happened when we cyclized the SNAP25 fragment with the disulfide bond. Open the log file and note that the energy of the constraint is also calculated after the first ENER command. Compare the energies with the constraint turned on and with the constraint turned off.
Question 5: What is the difference in energy between the linear peptide and the constrained peptide? Do you think that the structure can fold in this way, or does the energy difference select against it? Another way to look at the problem is to minimize now that the constraints are released and see if the ends fly apart or if they are stable near one another. Try it. What happens?
Question 6: There are a number of problems with doing the calculation in this way. I can think of at least 3 major ones. Can you come up with two of them? Put down as many as you can think of. Some are not at all obvious.
Now go back and use CONS FIX SELE ATOM SEGN 1 N END (again, replace SEGN with the name of your segment) (corman.doc) command to fix the N-terminus amino acid in place in addition to the NOE distance constraint. This time only the C-terminus should move. A word of warning - if the line connecting two atoms which you wish to distance-constrain passes through another group of atoms the minimization could get real ugly fast as the atoms crash into one another. In this case it might be necessary to turn off VDW interactions or change the initial conformation by editing dihedrals and rebuilding.

**[Lab 5](https://busathlab.github.io/mdlab/lab4.html)**

**[Return to home page](https://busathlab.github.io/mdlab/index.html)**
## LAB 7: HOMOLOGY MODELING
###### by Curtis Evans, Mark Fowler, and Mitch Gleed

---

#### Objectives:
- Learn how to mutate wild-type M2 to S31N M2 using Homology Modeling
- Create an RMSD Heatmap to compare wild-type M2 to S31N M2

---

**Homology modeling**, also known as comparative modeling of protein, refers to constructing an atomic-resolution model of the "target" protein from its amino acid sequence and an experimental three-dimensional structure of a related homologous protein (the "template"). Homology modeling relies on the identification of one or more known protein structures likely to resemble the structure of the query sequence, and on the production of an alignment that maps residues in the query sequence to residues in the template sequence. It has been shown that protein structures are more conserved than protein sequences amongst homologues, but sequences falling below a 20% sequence identity can have very different structure.[1](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC1166865/)

Evolutionarily related proteins have similar sequences and naturally occurring homologous proteins have similar protein structure. It has been shown that three-dimensional protein structure is evolutionarily more conserved than would be expected on the basis of sequence conservation alone.[2](https://link.springer.com/article/10.1007/s00214-009-0656-3)

Homology modeling has proven to be a useful tool for many research groups, because it can answer a widespread and fundamental research problem: "If a protein’s primary structure is known, how can one determine the secondary, tertiary, and quaternary structure of the protein?" This is done by threading the sequence of the protein with unknown structure into the known structure of a similar protein.

First of all, where do researchers get the secondary, tertiary, and quaternary structures of proteins? The main method is x-ray crystallography. Other techniques include cryo-electron microscopy (~4 Å resolution at best), and solution and solid state NMR. A crystallographer will gather all known structural data about their protein of interest to create a PDB file that is as accurate as possible, and then publish this PDB file on the RCSB Protein Data Bank.

In this lab, you will be introduced to a simple fitting algorithm in the Swiss-PDB Viewer Deep-View program that builds the structure of your unknown based on that of the homologous residues in a PDB structure file. You may refer to the [homology modeling tutorial](http://spdbv.vital-it.ch/modeling_tut.html); however, we will follow the directions below for the lab.

The **Influenza A M2 channel** is a tetrameric transmembrane protein found in viral lipid. It is the target of anti-flu agents Amantadine and Rimantadine which block infection. The wild type apo structure for the M2 channel was well defined using solid-state NMR and published in 2010 by Sharma et al with the pdb id 2L0J. 2L0J includes the inter membrane domain and amphipathic helices (residues 22-62) of the Influenza A M2 channel. Single amino acid mutations, such as S31N, can render the channel insensitive to anti-flu drugs. We will use homology modeling to create a tetrameter with a single amino acid mutation in each monomer that is similar in structure to the wild type. 

### Instructions
1. Browse to [http://spdbv.vital-it.ch/disclaim.html](http://spdbv.vital-it.ch/disclaim.html), click Download, accept agreement, and download the proper version to your desktop.
2. Unzip the folder by clicking on it and clicking "Extract all files."
3. Navigate down one directory and click on the SPDBV executable (black icon). Hit Run if you get the security warning, and click on the About Swiss-PDB Viewer window to close it.
4. Search for 2L0J at [rscb.org](http://rscb.org) and download the FASTA sequences for the [2010 M2 Channel by Sharma et al](https://www.ncbi.nlm.nih.gov/pubmed/20966252). Copy the sequence to notepad and delete the first 3 primer amino acids (SNA). 
5. Edit the primary sequence to resemble an S31N mutant. Note that the first amino acid in the given sequence is number 22. Exclude the B, C, and D sequences and save the new sequence as "s31n.txt."
6. Copy the lab files directory to your personal directory, and then download the four PDB files for the monomers of 2L0J from the segments folder. These monomer files are designated by a-d following the protein name.
7. Open your S31N mutated 2L0J FASTA sequence and open it in SPDBV by going to the tab "Swiss Model" and selecting "Load Raw Sequence from Amino Acids." A log box will appear, check it out and close it. It appears in the black window as a default alpha helix.
8. Open 2l0j_a.pdb in SPDBV using File, "Open PDB File…" A log box will appear, check it out and close it (ignore errors).
9. Fit your S31N mutant 2L0J FASTA sequence 1 to 2l0j_a.pdb in SPDBV using Fit, "Magic Fit." The alpha helix is turned into a replica overlying 2l0j_a. Additional controls of the view and the fit can be introduced using the Control Panel, which is opened using Wind, "Control Panel." The help "?" icons for both the Control Panel and the main toolbar give introductory instructions and directions to the User’s Guide.
10. Save your new structure to your desktop using File, "Save" -> "Current Layer" as s31n_a.pdb. Under File, hit Close twice to clear both molecules.
11. Repeat steps 6-10 for the second, third, and fourth sequences of 2L0J fitting them to 2l0j_b, 2l0j_c, and 2l0j_d.pdb respectively.
12. In the lab directory you will find several directories for organization purposes and scripts written for your use. Import your S31N mutant files into the "segments" directory. In the "str" directory open "builder.str" and edit this script to read in your S31N mutant PDB files. This script creates a coordinate file, principal structure file, and PDB file of the final S31N tetramer from your four S31N monomer PDB files. Look through this script and familiarize yourself with any CHARMM commands or syntax that are new to you.
13. Open and revise wolfsubmit.sh or batch.submit and then execute "builder.str" using correct syntax. If you are using Marylou, you may use the `./[filename]` in place of `sbatch [filename]` for short jobs such as these to run the script on the internode rather than submit it to the scheduler.
14. Check the "channels" directory for the output files. Did your script run successfully? If not, look for the log file in the "log" directory to begin troubleshooting what might have gone wrong.
15. Now perform steps 12-14 for 2L0J, the wild-type channel.
16. In the "str" directory you will find one "dyna" script that will perform minimization, heating, and equilibration for your 2L0J wild-type tetramer. You may be required to change one of the variables for the script to run successfully. Submit the script and view the log file to ensure it ran properly. You will want to refer to the log file to answer questions later in the lab.
17. Download 2l0j.psf (in channels directory) and 2l0j_2eq.dcd (in dynafiles directory) to your computer.
18. Open VMD, load the .psf file, and then add the .dcd file to the psf. Click the Extensions tab, navigate to Analysis, open RMSD Visualizer Tool. Check "Frames from..." box, check "Backbone" box, click RMSD, then (once RMSD finishes calculating) click Align.
19. Click "Heatmap plot." Take a minute to understand the plot, and zoom out if necessary. Change the max threshold to 6, hit "apply," and save the heatmap plot. While you can render from VMD, it is easiest and sometimes better to take a screenshot. The heatmap plot can be saved as a .gif with the File menu, but it loses the axes.
20. Repeat steps 16-19 for S31N channel.

> **Question 1**: What is the total energy of the wild-type tetramer before minimization? How about the mutant? Why are the energies so different? What are the energies of each species following minimization? Is this energy potential or kinetic energy?

> **Question 2**: Watch both trajectories for wild-type and mutant M2 in VMD, and compare them. Why might an S31N mutant change drug binding affinities? Hint: M2 blockers bind to the inner pocket of the M2 channel.

> **Question 3**: What are the main differences in the heat plots? Why might a simple substitution mutation give rise to these differences?

**[Lab 8](https://busathlab.github.io/mdlab/lab8.html)**

**[Return to home page](https://busathlab.github.io/mdlab/index.html)**
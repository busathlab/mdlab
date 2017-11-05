## LAB 1: INTRODUCTION TO THE PROTEIN DATA BANK AND VMD

---

#### Objectives:
- Familiarize with the Protein Databank
- Find a protein in the database and download the protein’s .pdb file
- Familiarize with VMD and perform basic functions

---

### 1. RCSB Protein Data bank
Many of your molecular models will contain proteins, many of which are common in dynamics simulations. It would be very time consuming to have to recreate these proteins every time that you wanted to use one. The RCSB Protein Data bank contains a database of proteins that you can use in your models.

#### Finding proteins in the database
To get started, use your internet browser to go to the [RSCB homepage at rcsb.org](http://www.rcsb.org). We will use the Botulinum Neurotoxin, often referred to as BoNT or BoTox, in this first lab.  If you knew the PDB ID number for your protein, you could simply type it into the search box and click Search. Since you probably don’t, you can just type **BoTox** in the search box and click Search. The search should bring a list of results. We want to use the crystal structure of Botulinum Neurotoxin Serotype A, which was the first one determined and was released in 1999. The four digit code on the left hand side above one of the small pictures is the PDB ID number. We are looking for **3BTA**. Click on it to bring up a page specific to our protein. This page contains a lot of information that we will not cover in this lab.

#### Downloading PDB files
You can download files from the PDB website to your computer so that you can use them in simulations. On the page specific to our BoTox protein, toggle the drop-down menu on the right-hand side labeled "Download files" and choose "PDB Format." Save the file where you will be able to find it later.

### 2. VMD
We will be using a program named CHARMM (Chemistry at HARvard Molecular Modeling) to run our simulations. While CHARMM is great at crunching numbers to simulate how systems work, it has no graphical component. VMD is a program that converts the output files from CHARMM to visual representations of molecular systems as if we were looking at them under a type of microscope.

#### Loading files into VMD
When VMD is opened, it starts three windows: a console window, a display window, and the VMD main window. On the main window, click "file" then "New Molecule…" This brings up the "Molecule File Browser" window. Make sure that the drop down box next to "Load files for:" says "New Molecule." If it does not,  arrow  select "New Molecule."  Next, click the button that says "Browse…"  A new window will appear. Find the file that we downloaded from the PDB website hopefully named "3BTA.pdb" and click "Open." The "Molecule File Browser" window should now have the path of the file you just selected in the white text box. Click the button that says "Load" and close the window. In the Main window, you should see a line of text with several numbers and the filename that you just opened. The display window should have a picture of the protein encoded in the file you just opened.

#### Display options
*Rotation*: The rotate mode allows you to rotate the display. In the main window, click on the "Mouse" pull-down menu and select "Rotate Mode."  Next click and drag anywhere in the display window.  If you click, drag, and then let go of the mouse button while the mouse is still moving, VMD will continue to rotate or spin the display even though you are not holding down the mouse button. If you click, drag, and then let go of the mouse button when the mouse is not moving, VMD will not make the display spin. Try clicking and dragging with the right mouse button and see what happens. The display should rotate differently when holding the right mouse button.  It will not be a free rotation like you observed when you held the left button.

*Scaling*: The scale mode allows you to zoom in on the display. Again this mode is activated by selecting "Scale Mode" in the "Mouse" pull-down menu. To zoom in, click and drag on the display window. Drag left to zoom out and drag right to zoom in. If your mouse has a scroll wheel, then you can also just spin the wheel to zoom in or out.

*Translating*: The translate mode allows you to move the display. To enter this mode, select "Translate" from the "Mouse" pull-down menu.  To move the display, simply click on the display window and drag it the directions you want.

*Labeling*: The label mode allows you to show the names of different components of the display. This mode is also found in the "Mouse" pull-down menu. You have four options. You can label atoms, bonds, angles, and dihedrals. To label an atom, just click on it. To label a bond, click on the two atoms in the bond. To label an angle, click on three atoms. To label a dihedral angle, click on the four atoms that comprise the dihedral. To manage labels, use the "Labels" tool under "Graphics."

*Reset*: Now that you have rotated, moved, and zoomed in and out on you display, it might look a little funny. You can reset it by selecting "Reset View" from the "Display" pull-down menu in the main window.

*Perspective vs . Orthographic*: Perhaps you noticed that when you rotated the display, some bond lengths seemed to get smaller, and some got bigger--This is the result of using **perspective mode** in VMD. In an attempt to help visualize the three-dimensional structure, VMD makes atoms that are far away small and atoms that are close big. Often times this feature makes it hard to see what is going on in the system. To turn off perspective and enable **orthographic mode**, select "Orthographic" from the "Display" pull-down menu in the main window.

*Stereo Vision*: Another tool to help visualize the three-dimensional structure of your system is **stereo vision**. In the Main window, select "Display," "Stereo," and then "Side by Side." The display window should have two images side by side. This function is like magic eye pictures. The idea is that you want your right eye to look at the image on the right and your left eye to look at the image on the left. The images look the same, but are slightly different. When the two images are superimposed in your brain, you get the illusion of 3-D, or "stereo vision."

This can be a little tricky at first, so here are some pointers. First, resize your window so that the centers of each image are about two inches apart. Next, get as close to the screen as possible without touching your nose to the glass. The idea is that if you are close enough, then your right eye can only see the right image because your nose blocks the left image. Your left eye likewise can only see the left image.  Relax your eyes as if you were looking across the room. You should see one unfocused image. Your brain will think that the two different images are really the same image. Slowly back away from the screen being careful to focus so that the single image remains super-imposed. As you back away, your right eye will begin to see the image on the left and your left eye will be able to see the image on the right. You will see a total of three images. The one in the middle will be in 3-D!  Sometimes it helps to slightly rotate the display with the mouse. You can also zoom in now (scale up), but not too far or you will lose focus.

#### Graphical Representations
You can change the way different atoms and bonds are represented by using the Graphical Representations window. To open this window, use the "Graphics" pull-down menu in the Main window and select "Representations…"

A **representation** is a group of atoms and its display properties. You can create and delete representations with the "Create Rep" and "Delete Rep" buttons. As you do, they will appear and disappear from the text area below the buttons. If you double click on the representation in the text area it will toggle between active and inactive.  When the representation is active, it shows up in the display window. When it is inactive, it disappears.

*Draw style tab*: This tab allows you to change how each atom and bond will be represented on the screen. The "Coloring Method" refers to the way VMD determines how to color the atoms and bonds. You choose how to group the selected atoms for the representation. For example, you could choose to color the atoms by name. All of the carbon atoms would be one color and all of the hydrogen atoms would be another color. You could group atoms by molecules. All of the water molecules would be one color and all of the lipid molecules would be another color.  The "Drawing Method" changes the shape of the representations. Line representation just draws lines to represent each bond. The color of the line is determined by the coloring method. The "VDW" method draws each atom as a small sphere. The "Cartoon" method shows structural components of proteins like alpha helices and beta sheets.

*Selections tab*: This tab allows you to select which atoms are in the representation. The "Singlewords" box allows you to choose common groups of atoms such as all, water, protein, etc. The "Keyword" box gives you a list of identifiers defined in the pdb file. We will discuss many of these identifiers in later labs. For now you should know that the "name" keyword refers to the name of the atom. The atom names in the .pdb file are not necessarily the simple element names learned in chemistry.  If you click on name, a list of all the atom names in the file will appear in the "Value" box. To make a representation that selects only carbon atoms first clear the text box below where it says "Selected Atoms." Next, double-click on the keyword "name." You will notice that there are many different names that represent carbon.  Double-click on the "C" located in the value box.  To save the selection, click "Apply."
 
#### Other Tools
*Clipping Planes*: If you want to see a cross-sectional view of a system, you can use the **clipping plane tool**. To do this, use the "Extensions" pull-down menu. Select "Visualization" then "Clipping Plane Tool." You can have up to 6 clipping planes. To edit any one of the planes, click on the button with its number. You can tell if a particular plane is active in two ways. The first is that there is a small checkbox by the title.  You can also tell because when a plane is active there is a white bar under its button.

Click on clipping plane number ‘0.’ When you first turn on a clipping plane, the plane is parallel to the screen. All of the atoms behind the plane disappear.  If you click on the "flip" button, then all of the atoms that were hidden appear and the atoms that were visible are hidden. The clipping plane is perpendicular to a vector. You can manipulate the clipping plane by changing the three parameters of the vector; the origin of the vector "Origin," the magnitude of XYZ components "Normal," and the distance from the origin of the vector "Distance." The setting "Normal follows view" sets the Normal to the visual plane and allows the molecule to rotate through this plane. The setting "Origin follows center" sets the origin of the vector to the center of the molecule. The default setting sets the origin of the vector at the center of the molecule and you can adjust the distance that the plane is from the origin with the "Distance" sliding box.  Move the distance box left and right.  The plane will move backwards and forwards.

*Rendering*:  Often you want to use an image from VMD in an outside project such as a poster or a paper. You can export snapshots of VMD using the **render** command. These files are saved in the .bmp format. To save a picture of the display window, use the "File" pull-down menu and select "Render." In the Render Controls window, choose a location to save the snapshot.

> **Assignment 1**: open a copy of the BoTox molecule. Rotate it, rescale it, and translate it slightly.  Next, label an atom, a bond, an angle, and a dihedral angle.  Finally, render a copy of your display naming it "lab1_singleBoTox.bmp." Save the file to submit it at the end of the lab.  Your display should resemble Figure 1 below.

*Figure 1*
![alt text](https://github.com/busathlab/mdlab/raw/master/images/01_f01.PNG "Figure 1")

#### Multiple files
VMD is not limited to opening one file at a time. You can open many files and view them at the same time.  You can even open one file many times, and VMD will load several copies of that molecule. When opening a new file, make sure that the file browser window says "New Molecule" next to the words "Load files for." Load the BoTox file several times. You know that it is loading because in the main menu there are several lines each with a unique ID number.

When you look at the display window, it looks like there is only one molecule. This is because they are all loaded on top of each other. Try to move them using translate mode. You will notice that they all move together. The same is true in rotate mode and scale mode.  To move each copy individually, use the "Move" command found in the "Mouse" pull-down menu. This command allows you to select and move individual groups of atoms. Select "Move Molecule" and drag one of the BoTox molecules off of the stack. To change the representations of any individual file, go to the graphical representation window and select the file name using the right arrow in the box under the heading "Selected Molecule."

> **Assignment 2**: open four copies of the BoTox molecule. Move and scale them so that all four molecules are visible and so that none are touching. Change the representations so that all four molecules have different coloring methods and different drawing methods. Render a copy of your display naming it "lab1_fourBoTox.bmp." Save the file to submit it at the end of the lab.  Your display should resemble Figure 2 below.

*Figure 2.*
![alt text](https://github.com/busathlab/mdlab/raw/master/images/01_f02.PNG "Figure 2")

#### DCD files
Up until now we have learned how VMD allows us to see molecular models graphically. We have learned how to manipulate the way we look at these models, but the models remain unchanged. We can also use VMD to watch simulations.  During dynamics simulations, CHARMM creates **.dcd files** that can be viewed with VMD much like DVD’s are viewed with a DVD player. To do this, you need to load at least two files. The first file is the .pdb file for the model. The **.pdb file** has all of the atom information including initial coordinates and atom names for each atom. The other is a .dcd file which tells how each atom moved during the simulation.  You can actually load many .dcd files at once.

For this part of the lab, we will watch a lipid bilayer simulation using files in the lab directory.  First load the file named "bilayer.pdb" into VMD. When this file loads, you will be looking at the system, which consists of two types of lipid molecules sandwiched by water molecules, from the top.  Rotate the system so that you are looking at it from the side.  You should see red and white water molecules on the top and bottom of the system. Next, go to the Main window and select "Load Data into Molecule" from the "File" pull-down menu. You should see the Molecule File Browser window appear just like when you were loading a new .pdb file. Make sure that the Load files for box says "bilayer.pdb." If it does not, then click on the arrow on the right of the box and select "bilayer.pdb." Now browse, select, and load "bilayer.dcd." You will notice that the number of frames in the Main window will start counting, and the display window will start showing the simulation. When the file is done loading, then the frame count will stop. The controls at the bottom of the main window control the simulation playback. The single arrows on the bottom right and bottom left corners play the simulation forwards and reverse respectively. Click on the play button again and the simulation playback will be paused. The arrows directly above the play buttons jump to the beginning or to the end. The last two arrows step through the simulation one frame at a time.

In order to keep system size small while simulating large systems, CHARMM uses something called **periodic boundaries**. Simply, copies of the system are replicated about the original system in all directions. When you load a .dcd file, VMD only shows the primary image. To see the images in the periodic boundaries, defined in the header of the .dcd file, you have to turn them on. To do this go to the Graphical Representations window, select the "Periodic" tab, and click on the check boxes next to the dimensions that you want to show.

> Frame 0 of the trajectory is simply the coordinates of the original pdb file, and it won’t demonstrate periodicity. To avoid this artifact, delete frame 0 to show only the frames from the dcd file.

> **Assignment 3**: open the .pdb and the .dcd files for the lipid bilayer. Rotate the display so that you are looking at the side of the model. Make three representations with the following selections: "water", "resname PALM or resname PCGL", and "resname DLPC". Change the drawing method of the representation with the ‘resname DLPC’ selection so that it is easily distinguishable from the representation with the "resname PALM and resname PCGL" selection. Turn on the periodicity for all the representations except the water representation in both the +x and –x directions. Render three snapshots: the first at the beginning of the run, the second in the middle of the run, and the last at the end of the run. Name these files "lab1_beg. bmp", "lab1_mid.bmp", and "lab1_end.bmp". Your display should resemble Figure 3 below.

*Figure 3.*
![alt text](https://github.com/busathlab/mdlab/raw/master/images/01_f03.PNG "Figure 3")

Submit these three files along with the two files from the first two assignments in the lab to your T.A.

**[Lab 2](https://busathlab.github.io/mdlab/lab2.html)**

**[Return to home page](https://busathlab.github.io/mdlab/index.html)**

# Data_cube

Originally, this repository just contained an R script to process EDS "data cubes" stored as .raw files. To use this the user would need to install the "hexView" package for R.
Also involved was the CSV file with X-ray energies, which was from https://xdb.lbl.gov/Section1/Table_1-2.pdf

Having learned that ImageJ is a much better tool for this, I added a couple ImageJ macros (labeled as .java files but they are actually whatever language ImageJ macros use). The "element_maps.java" macro requires the "xrays.txt" file (not to be confused with the "x rays.csv" file). To use:
	1) Modify the macro to fill in the Necessary Info
	2) Open ImageJ, Open a text window (Ctrl + Shift + N)
	3) Paste this script into the text window
	4) Run the script (Ctrl + R)

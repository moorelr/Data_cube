/*
	This is a simple script to open a raw file from the SEM
	and apply a lookup table.
	
	To use:
	1) Fill in the Necessary Info below
	2) Open ImageJ, Open a text window (Ctrl + Shift + N)
	3) Paste this script into the text window
	4) Run the script (Ctrl + R)
*/

// Necessary Info:
import_path = ""; // File path to .raw file
img_width = 1024;
img_height = 832;
img_num = 1023;

// Open raw file
run("Raw...", "open=[import_path] image=[16-bit Unsigned] width=img_width height=img_height number=img_num");

// Apply LUT
run("Fire");

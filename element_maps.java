// Now, as later when I back this up on github, this is licensed under The MIT License
// Copyright 2020 Lowell R. Moore

/*
	This is a script to open a .raw file, apply various annotations,
	and then save it as a sequence of frames in a specified directory.
	
	Note: The script requires a separate "xrays.txt" file, which is a
		list of the frame intervals corresponding to each element. This
		file was written assuming that frame 1 starts at 0 eV and that
		the SmartMap was collected on 2047 channels over 10 keV.
	
	Note: The SEM saves SmartMaps in one of several default settings:
		Resolution: 512 x 416, 1024 x 832, ...?
		We usually save the raw files as 16-bit unsigned
	
	To use:
	1) Fill in the Necessary Info below
	2) Open ImageJ, Open a text window (Ctrl + Shift + N)
	3) Paste this script into the text window
	4) Run the script (Ctrl + R)
	5) When prompted, navigate to the xrays.txt file and open it. (Don't ask!)
*/

// Necessary Info
import_path = "SmartMap.raw"; // Path to raw file
output_path = "../frames"; // Directory to save output files (element maps)
img_width = 1024; // Pixel width of images
img_height = 832; // Pixel height of images
img_num = 1032; // Number of frames to load

// Extra settings
sample_name = "Element_Map" // Sample Name
delay_buff = 10; // Length of pause intervals (ms) at various places in the script to help things run smoothly. (Don't ask me!)
d_frame = 5; // I can't remember what this does

run("Raw...", "open=[import_path] image=[16-bit Unsigned] width=img_width height=img_height number=img_num"); // Load raw file
run("Fire"); // Apply LUT
run("Set Scale...", "distance=1024 known=1000 pixel=1 unit=microns"); // Calibrate image scale. I don't really understand how this works.
setColor("#ffffff"); // Set color applied to labels
setFont("SansSerif", 48, "bold"); // Set font

// Unused code to crop part of the image stack. It should work if enabled...
/*
	makeRectangle(17, 68, 379, 333);
	run("Crop");
*/

pathfile=File.openDialog("Choose the file to Open:"); // ask for location of xrays.txt file. (Don't ask!)
filestring = File.openAsString(pathfile); // open text file with x-ray bins

// Parse text file into some arrays. (Also don't ask!)
rows = split(filestring, "\n");
element = newArray(rows.length);
frame_start = newArray(rows.length);
frame_stop = newArray(rows.length);

// Loop over elements in those arrays, (ignoring the header row)
for(i=1; i<rows.length; i++){
	columns = split(rows[i],"\t");
	frame_start[i] = parseInt(columns[1]);
	frame_stop[i] = parseInt(columns[2]);
	element[i] = columns[0];
	
	// Some output to make us feel safe
	print(frame_start[i]);
	print(frame_stop[i]);
	print(element[i]);
	
	// get start and end frame from "frame_list"
	start_i = frame_start[i];
	stop_i = frame_stop[i];
	
	// Set indexed save path
	// the 4-digit index format ended up being important for the ImageMagick script I use to make animated gif's
	// Incidentally, this script was modified from one that saves ALL the frames in the raw file, so this was more necessary then.
	if (i < 10) {
		save_path = "C:/Users/Lowell Moore/Desktop/frames/" + sample_name + " frame 00" + i + ".png";
	}
	if (i >= 10 && i < 99) {
		save_path = "C:/Users/Lowell Moore/Desktop/frames/" + sample_name + " frame 0" + i + ".png";
	}
	if (i >= 100) {
		save_path = "C:/Users/Lowell Moore/Desktop/frames/" + sample_name + " frame -" + i + ".png";
	}
	
	// Z-project averaging from start to end frame
	run("Z Project...", "start=" + start_i + " stop=" + stop_i + " projection=[Average Intensity]");
	
	wait(delay_buff);
	
	// Scale Bar
	run("Scale Bar...", "width=200 height=4 font=14 color=White background=None location=[Lower Right] bold");
	wait(10);
	
	wait(10);
	*/
	
	// Create label for element
	img_label = element[i];
	Overlay.drawString(img_label, 58, 84, 0.0); // Note: here is where you can tweak the position of the label
	Overlay.show();
	wait(delay_buff);

	// Save and close the Z-projected image
	saveAs("PNG", save_path);
	Overlay.clear();
	close();
	wait(delay_buff);
	
} 
close(); // close the raw file
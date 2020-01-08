# Settings/Init

library("hexView") # Library with functions used to read hex files

# Where are raw files stored?
directory <- getwd() # use working directory by default

# What is the name of the raw file to look at?
file_name <- list.files()[grepl(".raw", list.files())][1] # Use the first ".raw" file in the directory by default

# Create path to raw file of interest
import_path <- paste(directory, file_name, sep = "/")

# Import another file listing x-ray energies
xray_path <- "x rays.csv"
xray_list <- read.csv(xray_path, stringsAsFactors = FALSE)

# SmartMap resolution
img_width <- 1024
img_height <- 832
img_size <- img_width * img_height

# Functions ####

# Note: In the comments and functions, "frame" refers to one image or layer in the stack of
#   images which comprise the data cube. The frames occur in sequence in the raw file where
#   the first frame corresponds to the first channel of the EDS spectrum with the lowest
#   energy.

# Load a frame and return a matrix of intensities
get_frame <- function(frame){
  # Debug: frame <- 391
  start_pos <- frame * img_size * 2
  chunk_length <- img_size * 2
  raw_image <- readRaw(import_path
                       , human = "int"
                       , offset = start_pos
                       , nbytes = chunk_length
                       #, width = 2
                       , size = 2
                       #, endian = "big"
                       #, signed = FALSE
  )
  
  img_block <- blockValue(raw_image)
  image_matrix <- matrix(img_block/max(img_block), nrow = img_height, ncol = img_width, byrow = TRUE)
  return(image_matrix)
}

# Draw a raster image of a frame indicating the location of a particular point
plot_frame <- function(frame, col_plot = img_width/2, row_plot = img_height/2){
  plot(as.raster(get_frame(frame)))
  points(col_plot, img_height - row_plot, col = "red")
}

# Draw a raster image of part of a frame
zoom_frame <- function(sub_frame, frame){
  # sub_frame is formatted based on the indices of the
  #   img_matrix variable: (row1, row2, col1, col2)
  img_matrix <- get_frame(frame)
  plot(as.raster(img_matrix[sub_frame[1]:sub_frame[2], sub_frame[3]:sub_frame[4]]))
}

# Returns the intensity for row i and column j in a given frame
get_point <- function(i, j, frame){
  if(FALSE){
    i <- (img_height/2) - 100
    j <- img_width/2
    frame <- 391
  }
  start_pos <- frame * img_size
  offset_i <- (i-1) * img_width
  start_pos <- (start_pos + offset_i + j)*2
  chunk_length <- 2
  
  raw_image <- readRaw(import_path
                       , human = "int"
                       , offset = start_pos
                       , nbytes = chunk_length
                       #, width = 2
                       , size = 2
                       #, endian = "big"
                       #, signed = FALSE
  )
  
  intensity_ij <- blockValue(raw_image)
  return(intensity_ij)
}

# This function doesn't work yet, but a strategy for drawing spectra is
#   accomplished by "brute force" below.
get_spectrum <- function(sub_frame, frame){
  # This function sucks!
  
  img_matrix <- get_frame(frame)
  start_row <- nrow(img_matrix) - sub_frame[3]
  end_row <- nrow(img_matrix) - sub_frame[4]
  start_col <- sub_frame[1]
  end_col <- sub_frame[2]
  intensities <- numeric(0)
  for(i in start_row:end_row){
    for(j in start_col:end_col){
      intensities <- c(intensities, image_matrix[i, j])
    }
  }
  return(c(frame, intensities))
}

# Add labels for x-ray energy using the accompanying CSV file
draw_xrays <- function(elements, orbital){
  # elements: list of standard elemental abbreviations
  # orbitals: list of [Ka1, Ka2, Kb1, La1, La2, Lb1, Lb2, Lc1, Ma1]
  # This adds lines to an existing plot
  
  # Debug : elements <- "Si"; orbital <- "Ka1"
  for(ele_i in elements){
    # Sorry, kind of janky...
    row_i <- which(grepl(ele_i, xray_list$Element))
    for(orb_j in orbital){
      xray_ij <- xray_list[row_i, orb_j]
      abline(v = xray_ij, col = "red", lty = 2)
      label_ij <- paste(ele_i
                        #, orb_j
                        , sep = " ")
      text(xray_ij, 0, labels = label_ij, adj = c(0, 1), col = "red")
    }
  }
}

# Draw a raster image of several frames added together
sum_frames <- function(frames, col_plot = img_width/2
                       , row_plot = img_height/2){
  sum_matrix <- get_frame(frame[1])
  for(i in 2:length(frames)){
    print(i)
    sum_matrix <- sum_matrix + get_frame(frames[i])
  }
  sum_matrix <- sum_matrix/max(sum_matrix)
  plot(as.raster(sum_matrix))
  #points(col_plot, img_height - row_plot, col = "red")
}

# Testing basic plot functions

frame_test <- 482 # Which frame to use (corresponds roughly to S Ka peak)
col_pos <- 670; col_buf <- 50 # Position of interest and buffer on either side
row_pos <- 480; row_buf <- 50

# Look at the frame for S
plot_frame(frame = frame_test, col_plot = col_pos, row_plot = row_pos)

# Zoom in on a sulfide grain
zoom_frame(frame = frame_test, sub_frame = c(row_pos - row_buf, row_pos + row_buf, col_pos - col_buf, col_pos + col_buf))

# Plot part of the EDS spectrum near the peak for S
frames <- (frame_test - 100):(frame_test + 100)
intensities <- numeric(0)
for(frame_i in frames){
  print(frame_i)
  intensities <- c(intensities, get_point(i = row_pos, j = col_pos, frame = frame_i))
}
frames <- frames * (10000/2048) # Rescale given that 10 keV is distributed over 2048 channels
plot(frames, intensities, type = "l"
     , xlab = "Energy, eV", ylab = "Intensity"
     )
draw_xrays(elements = c("S"), orbital = "Ka1")

# Testing sum function
frame <- 482; frame_buff <- 17 # Which frames to sum over?
frames <- (frame_test - 100):(frame_test + 100)
intensities <- numeric(0)
for(frame_i in frames){
  print(frame_i)
  intensities <- c(intensities, get_point(i = row_pos, j = col_pos, frame = frame_i))
}

# Show the "middle" frame and the point used to make the preview spectrum
plot_frame(frame = frame, col_plot = col_pos, row_plot = row_pos)

# Show the frames being summed over as a spectrum at the point from the previous plot
plot(frames, intensities, type = "l")
abline(v = frame + frame_buff, lty = 2, col = "blue")
abline(v = frame - frame_buff, lty = 2, col = "blue")

# Draw the summed frame
sum_frames(frames = (frame - frame_buff):(frame + frame_buff))

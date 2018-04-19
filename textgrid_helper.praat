# This script helps you make text grids. It opens all files from the specified directory one at a time
# creates a text grid for you, waits until you're done annotating, and saves that text grid for you,
# and loops until you're done with all the files.
# originally written by Kathryn Flack and Shigeto Kawahara
# Modified version 4/7/2009

# First, we define the directory where all the files we want to work with is - You thus
# need to define your own directory;

# There are two ways to do this. Simply copy and paste this script to the folder in which you store 
# target files.
  
# The second way is to specify the direct path. To do so,(i) From the script window, go Edit => clear history, 
# (ii) From the object window, Read=> Read from file... and open any one file from the directory
# (iii) and paste history. This should give you a command line like the one blwo.
# Read from file.../xxx/yyyy/zzzz/aaa.wav. /xxx/yyyy/zzzz/ is the path to the directory. 
# Then you can then copy and paste the directory name.

# This line is just to test if git works correctly :D

form Textgrid helper
	#sentence Directory ./
	#sentence Directory C:\Users\QuyThao\Documents\Prosody analysis\Tests_ERJ_TIMIT\ERJ\Native\12.democracy\
endform

# this lists everything in the directory into what's called a Strings list
# and counts how many there are

Create Strings as file list... list 'directory$'*.wav
numberOfFiles = Get number of strings

appendInfoLine: "Found 'numberOfFiles' files"

# Below is the script for a loop, doing something for every file on the list.

for ifile to numberOfFiles

# Select the stringlist and find a file name. Then, it reads that file.

	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'directory$''fileName$'

# Now we define an object name - a file name minus extension. This is useful because
# then we can refer to the text grid file and the sound file by using the object name,
# which is a variable. See below

     	object_name$ = "'fileName$'" - ".wav"
  
# Select a sound now.

   	select Sound 'object_name$'

# Creat a text grid file with a tier named "sentence". This name is not important.
# It can be anything.

	#To TextGrid... sentence 
	To TextGrid... word

# And you select the sound file and the text grid file, whose name is defined
# by "object_name" (see above). This is why we defined the object_name.

	select Sound 'object_name$'
	plus TextGrid 'object_name$'

# And of course now we want to edit the files.

	Edit

# The script pauses here so that you can work on marking intervals.
# It waits until you click a button in the window that pops up, 
# at which point the script will resume. The sentence that follows
# will be in the window. Add any sentence that makes you feel happy
# when labeling.

     	pause  Let's annotate! Click continue when you're done.

# Once you are done marking, you want to save the TextGrid file. So, first you
# select it.

	select TextGrid 'object_name$'

# Then save it as a text file with "TextGrid" extension.

     	Write to text file... 'directory$''object_name$'.TextGrid

# Now we get rid of all the files from the menu window.
# It does NOT mean that we delete the files that we created.

     	select all
     	minus Strings list
     	Remove

# And it ends if it goes through all the files in the directory.

endfor

# After the loop, let's clear off all the window.

select all
Remove


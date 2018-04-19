# This script opens each file in a given directory, looks for the corresponding TextGrid file
# For each file, duration, pitch (F0), and intensity are extracted at each labeled segment
# The results are written to a tab-delimited text file
# The script is a modified version of the script "collect_formant_data_from_files.praat" by 
# Mietta Lennes, available here: http://www.helsinki.fi/~lennes/praat-scripts/
# This script was modified on November 2017

form Get pitch formants intensity and duration from labeled segments in files
	comment Directory of sound files. Be sure to include the final "/"
	text sound_directory C:/Users/Quy Thao/Documents/Prosody analysis/ERJ.WAV/
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files. Be sure to include the final "/"
	text textGrid_directory C:/Users/Quy Thao/Documents/Prosody analysis/ERJ.TextGrid/
	sentence TextGrid_file_extension .TextGrid
	comment Full path of the resulting text file:
	text resultsfile C:/Users/Quy Thao/Documents/Prosody analysis/phonelevel_prosodic_features_test.txt
	comment Which tier do you want to analyze?
	integer Tier 1
	comment Formant analysis parameters
	positive Time_step 0.01
	integer Maximum_number_of_formants 5
	positive Maximum_formant_(Hz) 5500
	positive Window_length_(s) 0.025
	real Preemphasis_from_(Hz) 50
	comment Pitch analysis parameters
	positive Pitch_time_step 0.01
	positive Minimum_pitch_(Hz) 75
	positive Maximum_pitch_(Hz) 300
endform

# Make a listing of all the sound files in a directory
Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings
appendInfoLine: "Total number of files = ", "'numberOfFiles'"

# Check if the result file exists:
if fileReadable (resultsfile$)
	pause The file 'resultsfile$' already exists! Do you want to overwrite it?
	filedelete 'resultsfile$'
endif

# In output file, add a line with label name, duration, F0, intensity values
# (One output for all the files)
#header$ = "'Filename' 'tab$' 'label' 'tab$' 'duration' 'tab$' 'f0' 'tab$' 'intensity' 'newline$'" 
header$ = "'Filename' 'tab$' 'label' 'tab$' 'duration (ms)' 'tab$' 'f0 (Hz)' 'tab$' 'f0_mean (Hz)' 'tab$' 'f0_diff (Hz)' 'tab$' 'intensity (dB)' 'newline$'" 
fileappend "'resultsfile$'" 'header$'
#appendInfoLine: "Output file successfully created"

# Open each sound file in the directory
for ifile to numberOfFiles
	filename$ = Get string... ifile
	Read from file... 'sound_directory$''filename$'

	# Get the name of the sound object
	soundname$ = selected$ ("Sound", 1)
	appendInfoLine: "Processing file number ", "'ifile'", ": ", "'soundname$'"

	# Look for a TextGrid with the same name
	gridfile$ = "'textGrid_directory$''soundname$'.TextGrid"
	appendInfoLine: "TextGrid filename: ", "'gridfile$'"	

	# If the TextGrid file exists, open it and analyse
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'
		#appendInfoLine: "TextGrid file found: ", "'gridfile$'"
		
		# No need to compute formants for now
		#select Sound 'soundname$'
		#To Formant (burg)... time_step maximum_number_of_formants maximum_formant window_length preemphasis_from

		select Sound 'soundname$'
		To Pitch... pitch_time_step minimum_pitch maximum_pitch
		#To Pitch... 0.01 75 300
		#appendInfoLine: "Pitch tier has successfully been created ", "'pitch_time_step' 'minimum_pitch' 'maximum_pitch'"
		
		select Sound 'soundname$'
		To Intensity... minimum_pitch time_step
		#appendInfoLine: "Intensity retrieved"

		select TextGrid 'soundname$'
		numberOfIntervals = Get number of intervals... tier 
		#appendInfoLine: "Number of intervals found: ", "'numberOfIntervals'"

		# Pass through all intervals in the designated tier, and if they have a label, do the analysis:
		for interval to numberOfIntervals
			label$ = Get label of interval... tier interval
			# if label$ <> ""
			if label$ <> "SIL"
				# Duration:
				start = Get starting point... tier interval
				end = Get end point... tier interval
				duration = end-start
				midpoint = (start + end) / 2
				duration_ms = duration*1000

				# Pitch:
				select Pitch 'soundname$'
				f0 = Get value at time... midpoint Hertz Linear
				f0_mean = Get mean... 'start' 'end' Hertz
				f0_start = Get value at time... start Hertz Linear
				f0_end = Get value at time... end Hertz Linear
				f0_diff = f0_end - f0_start

				# Intensity:
				select Intensity 'soundname$'
				intensity = Get value at time... midpoint Cubic

				# Save result to text file:
				#resultline$ = "'soundname$' 'tab$' 'label$' 'tab$' 'duration_ms:0' 'tab$' 'f0:1' 'tab$' 'intensity:1' 'newline$'"
				resultline$ = "'soundname$' 'tab$' 'label$' 'tab$' 'duration_ms:0' 'tab$' 'f0:1' 'tab$' 'f0_mean:1' 'tab$' 'f0_diff:1' 'tab$' 'intensity:1' 'newline$'"
				fileappend "'resultsfile$'" 'resultline$'

				# select the TextGrid so we can iterate to the next interval:
				select TextGrid 'soundname$'
			endif
		endfor

		# Remove the TextGrid, Formant, and Pitch objects
		select TextGrid 'soundname$'
		plus Pitch 'soundname$'
		plus Intensity 'soundname$'
		Remove

	endif
	# Remove the Sound object
	select Sound 'soundname$'
	Remove
	# and go on with the next sound file!
	select Strings list
endfor

# When everything is done, remove the list of sound file paths:
Remove
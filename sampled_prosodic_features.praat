# November 15th, 2017

# This script is used to compute prosodic features (F0, intensity, duration)
# at 25 sample points that are equally spaced for each interval 
# of each file present in the specified directory

form Get pitch intensity and duration from labeled segments in file
	comment Directory of sound files. Be sure to include the final "/"
	text sound_directory C:/Users/QuyThao/Documents/Prosody analysis/Tests_ERJ_TIMIT/ERJ/Native/12.democracy/
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files. Be sure to include the final "/"
	text textGrid_directory C:/Users/QuyThao/Documents/Prosody analysis/Tests_ERJ_TIMIT/ERJ/Native/12.democracy/
	sentence TextGrid_file_extension .TextGrid
	comment Full path of the resulting F0 text file:
	text resultsfile C:/Users/QuyThao/Documents/Prosody analysis/Tests_ERJ_TIMIT/ERJ/Native/12.democracy/f0_results.txt
	comment Full path of the resulting Intensity text file:
	text resultsfile_int C:/Users/QuyThao/Documents/Prosody analysis/Tests_ERJ_TIMIT/ERJ/Native/12.democracy/intensity_results.txt
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
	#positive Minimum_pitch_(Hz) 10
	positive Maximum_pitch_(Hz) 300
endform


# This lists everything in the directory into what's called a Strings list
# and counts how many there are

Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings

# Checks whether the results file already exists. If so, delete it

if fileReadable (resultsfile$)
	pause The file 'resultsfile$' already exists! Do you want to overwrite it?
	filedelete 'resultsfile$'
endif

if fileReadable (resultsfile_int$)
	pause The file 'resultsfile_int$' already exists! Do you want to overwrite it?
	filedelete 'resultsfile_int$'
endif

# Creates a header in the pitch results file: Duration and 25 values of F0 

header$ = "'Filename' 'tab$' 'Word' 'tab$' 'Duration' 'tab$' 'F0_1' 'tab$' 'F0_2' 'tab$' 'F0_3' 'tab$' 'F0_4' 'tab$' 'F0_5' 'tab$' 
	... 'F0_6' 'tab$' 'F0_7' 'tab$' 'F0_8' 'tab$' 'F0_9' 'tab$' 'F0_10' 'tab$' 'F0_11' 'tab$' 'F0_12' 'tab$' 'F0_13' 'tab$' 
	... 'F0_14' 'tab$' 'F0_15' 'tab$' 'F0_16' 'tab$' 'F0_17' 'tab$' 'F0_18' 'tab$' 'F0_19' 'tab$' 'F0_20' 'tab$' 'F0_21' 'tab$'
	... 'F0_22' 'tab$' 'F0_23' 'tab$' 'F0_24' 'tab$' 'F0_25' 'newline$'"
fileappend "'resultsfile$'" 'header$'

# Creates header in the intensity results file
header_int$ = "'Filename' 'tab$' 'Word' 'tab$' 'int_1' 'tab$' 'int_2' 'tab$' 'int_3' 'tab$' 'int_4' 'tab$' 'int_5' 'tab$' 
	... 'int_6' 'tab$' 'int_7' 'tab$' 'int_8' 'tab$' 'int_9' 'tab$' 'int_10' 'tab$' 'int_11' 'tab$' 'int_12' 'tab$' 'int_13' 'tab$' 
	... 'int_14' 'tab$' 'int_15' 'tab$' 'int_16' 'tab$' 'int_17' 'tab$' 'int_18' 'tab$' 'int_19' 'tab$' 'int_20' 'tab$' 'int_21' 'tab$'
	... 'int_22' 'tab$' 'int_23' 'tab$' 'int_24' 'tab$' 'int_25' 'newline$'"
fileappend "'resultsfile_int$'" 'header_int$'

# Process each file in the specified directory

for ifile to numberOfFiles
	filename$ = Get string... ifile
	Read from file... 'sound_directory$''filename$'

	soundname$ = selected$ ("Sound",1)
	#appendInfoLine: "Processing file number 'ifile'"
	
	gridfile$ = "'textGrid_directory$''soundname$'.TextGrid"

	if fileReadable (gridfile$)
		Read from file... 'gridfile$'

		select Sound 'soundname$'
		To Pitch... pitch_time_step minimum_pitch maximum_pitch

		select Sound 'soundname$'
		To Intensity... minimum_pitch time_step

		select TextGrid 'soundname$'
		numberOfIntervals = Get number of intervals... tier

		for interval to numberOfIntervals
			label$ = Get label of interval... tier interval
			if label$ <> ""
			#if label$ <> "SIL"
				# Duration:
				start = Get starting point... tier interval
				end = Get end point... tier interval 
				duration = end - start
				midpoint = (start + end) / 2
				duration_ms = duration * 1000
				# Define the time step to sample 25 points
				# (we want to ignore the values at the start and end)
				sample_step = (end - start) / 26

				# Write result in pitch file
				resultline$ = "'soundname$' 'tab$' 'label$' 'tab$' 'duration_ms:0' 'tab$'"
				fileappend "'resultsfile$'" 'resultline$'
				
				# Prepare intensity file
				result_int$ = "'soundname$' 'tab$' 'label$' 'tab$'"
				fileappend "'resultsfile_int$'" 'result_int$'

				# Pitch
				select Pitch 'soundname$'
				for ipitch to 25
					pitch_time = ( ipitch * sample_step ) + start
					f0 = Get value at time... pitch_time Hertz Linear
					# f0_mid = Get value at time... midpoint Hertz Linear
					# f0_mean = Get mean... start end Hertz					
					pitchline$ = "'f0:1' 'tab$'"
					fileappend "'resultsfile$'" 'pitchline$'
					# Check the sample step and the pitch at each one of the 25 points
					# appendInfoLine: "'sample_step' s, 'pitch_time' s : 'f0:1' Hz"
				endfor
				fileappend "'resultsfile$'" 'newline$'

				# Intensity
				select Intensity 'soundname$'
				# intensity_mean = Get mean... start end dB
				# intensity_max = Get maximum... start end Parabolic
				# intensity_mid = Get value a time... midpoint Cubic
				for iintensity to 25
					intensity_time =  ( iintensity * sample_step ) + start
					intensity = Get value at time... intensity_time Cubic
					intensityline$ = "'intensity:1' 'tab$'"
					fileappend "'resultsfile_int$'" 'intensityline$'
				endfor
				fileappend "'resultsfile_int$'" 'newline$'
					
				
				# resultline$ = "'soundname$' 'tab$' 'label$' 'tab$' 'duration_ms:0' 'tab$' 'f0_mid:1' 'tab$' 'f0_mean:1' 'tab$' 'intensity_max:1' 'tab$' 'intensity_mean:1' 'newline$'"
				# fileappend "'resultsfile$'" 'resultline$'

				select TextGrid 'soundname$'
			endif
		endfor

		select TextGrid 'soundname$'
		plus Pitch 'soundname$'
		plus Intensity 'soundname$'
		Remove
	
	endif
	select Sound 'soundname$'
	Remove
	select Strings list
endfor

Remove






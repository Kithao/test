# January 20, 2018
# TRUONG Quy Thao

# This script takes each sound file and its corresponding TextGrid file in a directory
# and computes prosodic features (duration, mean F0, max F0, mean intensity, max intensity)
# for every labeled phone

form Get pitch intensity and duration from labeled segments in file
	comment Directory of sound files. Be sure to include the final "/"
	text sound_directory C:/Users/QuyThao/Documents/Prosody analysis/Tests_ERJ_TIMIT/ERJ/Alignment/mono_align_words/ERJ.Words/
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files. Be sure to include the final "/"
	text textGrid_directory C:/Users/QuyThao/Documents/Prosody analysis/Tests_ERJ_TIMIT/ERJ/Alignment/mono_align_words/ERJ.TextGrid/
	sentence TextGrid_file_extension .TextGrid
	comment Full path of the resulting F0 text file:
	text resultsfile_F0 C:/Users/QuyThao/Documents/Prosody analysis/Tests_ERJ_TIMIT/ERJ/Alignment/mono_align_words/F0_results.txt
	comment Full path of the resulting Intensity text file:
	text resultsfile_int C:/Users/QuyThao/Documents/Prosody analysis/Tests_ERJ_TIMIT/ERJ/Alignment/mono_align_words/intensity_results.txt
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

# Checks whether the results files already exist. If so, delete them
if fileReadable (resultsfile_F0$)
	pause The file 'resultsfile_F0$' already exists! Do you want to overwrite it?
	filedelete 'resultsfile_F0$'
endif

if fileReadable (resultsfile_int$)
	pause The file 'resultsfile_int$' already exists! Do you want to overwrite it?
	filedelete 'resultsfile_int$'
endif

# Creates a header in the pitch results file
header$ = "'Filename' 'tab$' 'Phone' 'tab$' 'Duration' 'tab$' 'F0_mean' 'tab$' 'F0_mid' 'tab$' 'F0_max' 'newline$'"
fileappend "'resultsfile_F0$'" 'header$'

# Creates a header in the intensity results file
#header$ = "'Filename' 'tab$' 'Phone' 'tab$' 'Duration' 'tab$' 'Int_mean' 'tab$' 'Int_mid' 'tab$' 'Int_max' 'newline$'"
header$ = "'Filename' 'tab$' 'Phone' 'tab$' 'Duration' 'tab$' 'Int_mean' 'tab$' 'Int_max' 'newline$'"
fileappend "'resultsfile_int$'" 'header$'

# Process each file in the specified directory

for ifile to numberOfFiles
	filename$ = Get string... ifile
	Read from file... 'sound_directory$''filename$'

	soundname$ = selected$ ("Sound",1)
	appendInfoLine: "Processing file number 'ifile'"
	
	gridfile$ = "'textGrid_directory$''soundname$'.TextGrid"

	if fileReadable (gridfile$)
		Read from file... 'gridfile$'

		select Sound 'soundname$'
		To Pitch... pitch_time_step minimum_pitch maximum_pitch

		select Sound 'soundname$'
		#To Intensity... minimum_pitch time_step
		To Intensity... minimum_pitch time_step

		select TextGrid 'soundname$'
		numberOfIntervals = Get number of intervals... tier

		for interval to numberOfIntervals
			label$ = Get label of interval... tier interval
			#if label$ <> ""
			if label$ <> "SIL"
				# Duration:
				start = Get starting point... tier interval
				end = Get end point... tier interval 
				duration = end - start
				midpoint = (start + end) / 2
				duration_ms = duration * 1000

				# Write result in results files
				resultline$ = "'soundname$' 'tab$' 'label$' 'tab$' 'duration_ms:0' 'tab$'"
				fileappend "'resultsfile_F0$'" 'resultline$'
				fileappend "'resultsfile_int$'" 'resultline$'

				# Pitch
				select Pitch 'soundname$'
				f0_mean = Get mean... start end Hertz
				f0_mid = Get value at time... midpoint Hertz Linear
				f0_max = Get maximum... start end Hertz Parabolic
				f0_line$ = "'f0_mean:1' 'tab$' 'f0_mid:1' 'tab$' 'f0_max:1' 'newline$'"
				fileappend "'resultsfile_F0$'" 'f0_line$'

				# Intensity
				#select Intensity 'soundname$' 
				select Intensity 'soundname$'
				int_mean = Get mean... start end dB
				#int_mid = Get value a time... midpoint Cubic
				int_max = Get maximum... start end Cubic
				#int_line$ = "'int_mean:1' 'tab$' 'int_mid:1' 'tab$' 'int_max:1' 'newline$'"
				int_line$ = "'int_mean:1' 'tab$' 'int_max:1' 'newline$'"
				fileappend "'resultsfile_int$'" 'int_line$'

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

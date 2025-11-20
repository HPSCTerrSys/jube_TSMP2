compare_nc_*.sh compares the nc ouputs for each * component.

Input nc-files can be read:
	- as arguments on the command line (## INPUTS read as args section) or
	- as a given path to the file within the script (## INPUTS given within the script section)
	- comment/uncomment sections as needed

Variables names of the variables to be compared can also be introduced as argument or described within the script.
If variables names are entered in the command line the following lines in the script should be uncommented:
	# shift 2   # remove first two args, remaining are variables to compare
	# VARS=("$@")
	
To run manually these scripts, use `bash`:
	bash compare_nc_eclm.sh
	bash compare_nc_parflow.sh
	bash compare_nc_icon.sh

# MVFF-GUI
Multiple-Sample VCF Filtering, Graphical Interface Version. A GUI tool to filter variant call format files (VCF).  The tool supports sample sub-setting, and the choice of the minimum number of samples that must meet a user-defined coverage in order for a variant to be retained.
_______________________________________________________________________________________________________________________________________________

Use at your own risk. I cannot provide support. All information obtained/inferred with this script is without any implied warranty of fitness for any purpose or use whatsoever.

ABOUT:  

Filtering applies a user-selected depth of coverage that must be met in a minimum of samples as set by the user. Filtering a subset of samples is supported.  When a a sample subset is applied, variants are checked to ensure that there is at least one call that is neither ./. nor 0/0. In other words, at least one of the samples will harbor the alternative allele. Variants in samples that do not meet the minimum depth are converted to no call, ./., format.  This is for downstream compatibility with tools such as MFAR (https://github.com/bjtill/Mutation-Finder-Annotator-with-Relatives-GUI).  

INPUTS: 

1. A single or multi-sample VCF.  
2. A user-defined minimum depth of coverage (DP). 
3. A user-defined minimum number of samples that must have a genotype call (can be 0/0) that meets the minimum coverage.  
4. The percentage of computer CPU to devote to this program.
5. A list of samples to subset the VCF (optional). 


OUTPUTS:

1. A modified VCF containing only variants meeting the user-supplied filtering parameters, a summary table that reports the number of starting variants, the number retained and the number removed.

2. A table listing the number of starting variants, total retained and total removed. 

2. A log file.  
 

REQUIREMENTS:  

Bash, YAD, Zenity, datamash, bcftools, awk, bgzip, tabix

TO RUN:

This program was built to run on Linux and tested on Ubuntu 20.04 and 22.04.  In theory it can be on macOS by installing the various dependencies (e.g. using Homebrew). However, I experienced issues with installing YAD.  Zenity installed okay, and so one could convert the YAD inputs to Zenity, or create a command line version.  No testing has been done with Windows and a Bash emulator.  

Download the .sh file and give it permission to run on your computer.  Open a Linux terminal and type chmod +x  MVFF_V1_6.sh (or whatever the file is named).  Launch by typing ./MVFF_V1_6.sh .  A window should appear where you can select input files and set various parameters. 

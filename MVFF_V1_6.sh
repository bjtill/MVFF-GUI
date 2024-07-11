#!/bin/bash 
#BT First version June 4, 2024
#Version 1.6, first stable version. 
wget https://ucdavis.box.com/shared/static/bfkmvyp4ldq7qxneef1muazvm5xcocfa.jpeg
mv bfkmvyp4ldq7qxneef1muazvm5xcocfa.jpeg MVFFlogo.jpeg
YADINPUT=$(yad --width=1200 --title="Multi-Sample VCF Filtering (MVFF)" --image=MVFFlogo.jpeg --text="Version 1.6

ABOUT: A GUI tool to filter multi-sample.  Filtering applies a user-selected depth of coverage that must be met in a minimum of samples as set by the user. Filtering a subset of samples is supported.  When a a sample subset is applied, variants are checked to ensure that there is at least one call that is neither ./. nor 0/0. Variants in samples that do not meet the miminum depth are converted to no call, ./., format.  This is for downstream compatability with tools such as MFAR. 

OUTPUTS: 
1) A modified VCF containing only variants meeting the user-supplied filtering parameters, a summary table that reports the number of starting variants, the number retained and the number removed.  

DEPENDENCIES:  Bash, yad, Zenity, datamash, bcftools, awk, bgzip, tabix

VERSION INFORMATION: July 5, 2024 BT

LICENSE:  
MIT License, Copyright (c) 2024 Bradley John Till

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the *Software*), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE" --form --field="Your Initials for the log file" "Enter" --field="Optional notes for log file" "Enter" --field="Minimum Depth For Variant Retention (Click to edit):CBE" '20!50!80!100' --field="Minimum number samples that must have GT call (Click to edit):CBE" '5!10!20!50!100!150' --field="Percent of computer CPUs to use (click to edit):CBE" '10!20!50!80' --field="Select the VCF file:FL" --field="Select a list of samples to subset the VCF. Leave blank if no sample subsetting required:FL" --field="Name for new directory. Your data will be in here. CAUTION-No spaces or symbols" "Enter")
echo $YADINPUT |  tr '|' '\t' | datamash transpose | head -n -1  > MVFFparm1


#######################################################################################################################
#Check that the user provided the VCF
a=$(awk -F'/' 'NR==6 {print $NF}' MVFFparm1 | awk '{if ($1=="Enter") print "Missing"; else print "OK"}')
cp MVFFparm1 ${a}.vcfanswer
b=$(awk 'NR==8 {if ($1=="") print "Missing"; else print "OK"}' MVFFparm1) 
cp MVFFparm1 ${b}.diranswer
if [ -f "Missing.vcfanswer" ] || [ -f "Missing.diranswer" ] ; 
then

zenity --width 1200 --warning --text='<span font="32" foreground="red">VCF file and/or directory name not supplied. </span> \n Please close and start over.' --title="INFORMATION ENTRY FAILURE" 
exit
fi 
rm *.vcfanswer MVFFlogo.jpeg *.diranswer

#######################################################################################################################
#Enter the directory
c=$(awk 'NR==8 {print $1}' MVFFparm1)
mkdir ${c}
mv MVFFparm1 ./${c}/
cd ${c}
#######################################################################################################################
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>MVFFt.log 2>&1
now=$(date)  
echo "Multi-Sample VCF Filtering (MVFF) Version 1.6
Script Started $now" 
(#Start
echo "# Checking if VCF file is compressed and indexed and taking these actions if it is not."; sleep 2

#Check if the vcf is compressed and if there is a bcftools index associated.  Create these if they don't exist. 
a=$(awk -F'.' 'NR==6 {if ($NF=="gz") print "YESGZ"; else print "NOGZ"}' MVFFparm1)
awk 'NR==1 {print "answer"}' MVFFparm1 > ${a}.answer1
if [ -f "NOGZ.answer1" ]; 
then
b=$(awk 'NR==6 {print $1}' MVFFparm1)
bgzip $b 
#Assume no csi 
#percentage of CPUs
c=$(awk 'NR==6 {print $1".gz"}' MVFFparm1)
e=$(awk 'NR==5 {print $1}' MVFFparm1)
d=$(lscpu | grep "CPU(s):" | head -1 | awk 'NR==1{print $2}' | awk -v var=$e '{print ($1*var)/100}' | awk '{printf "%.f\n", int($1+0.5)}')
bcftools index --threads $d $c
fi
a=$(awk 'NR==6 {print $1 }' MVFFparm1 | sed 's/.gz//g' | awk '{print $1".gz.csi"}' )
 if [ ! -f $a ]; 
then
c=$(awk 'NR==6 {print $1 }' MVFFparm1 | sed 's/.gz//g' | awk '{print $1".gz"}')
e=$(awk 'NR==5 {print $1}' MVFFparm1)
d=$(lscpu | grep "CPU(s):" | head -1 | awk 'NR==1{print $2}' | awk -v var=$e '{print ($1*var)/100}' | awk '{printf "%.f\n", int($1+0.5)}')
bcftools index --threads $d $c
fi 
echo "10"
echo "# Collecting user provided parameters"; sleep 2 
#######################################################################################################################
#Collect other parameters to determine actions. There will be four classes of actions depending on user response.
f=$(awk 'NR==7 {if ($1=="") print "NOSubset"; else print "SUbset"}' MVFFparm1)
cp MVFFparm1 ${f}.subanswer
echo "10"
echo "# Performing VCF filtering. This may take a while."; sleep 2 
#######################################################################################################################

#######################################################################################################################
#section for testing version 1.4
if [ -f "SUbset.subanswer" ] ; 
then 
#Subset for samples
i=$(awk 'NR==7 {print $1}' MVFFparm1 )
cp $i MVFFSamplesList
h=$(awk 'NR==6 {print $1 }' MVFFparm1 | sed 's/.gz//g' | awk '{print $1".gz"}' )
e=$(awk 'NR==5 {print $1}' MVFFparm1)
d=$(lscpu | grep "CPU(s):" | head -1 | awk 'NR==1{print $2}' | awk -v var=$e '{print ($1*var)/100}' | awk '{printf "%.f\n", int($1+0.5)}')
bcftools view --threads $d -S MVFFSamplesList $h -O z > Ssubset.vcf.gz
bcftools index --threads $d Ssubset.vcf.gz
#End subset
#Filter for DP and Minimum Number of Samples
h=$(awk 'NR==6 {print $1 }' MVFFparm1 | sed 's/.gz//g' | awk '{print $1".gz"}' ) #VCF sample name 
 b=$(awk 'NR==3 {print $1}' MVFFparm1) #DP
c=$(awk 'NR==4 {print $1}' MVFFparm1) #Min number with data
bcftools query -f '%CHROM %POS [\t%DP]\n' Ssubset.vcf.gz | awk -v var=$b '{count = 0;for (i = 3; i <= NF; i++) {if ($i >= var) {count++;}} print $1, $2, count}' | awk -v var1=$c '{if ($3>=var1) print $1, $2, $2+1}' | tr ' ' '\t' | bcftools view -R - Ssubset.vcf.gz > S2.vcf

#July 3, 2024: While the above works, we have an issue where if you have 100 samples and you want 80 with passing data, you might have 20 with 1x coverage or something, so need to convert those lower than DP into ./.  (and then modify MFAR).  The below test code requires you 1) know which column the data starts and 2) the location of the DP information.  1 should be standard, 2 is not.  
#Determine where in the format string the DP value is, and then if a sample has less than the min DP, convert the gt to ./.
grep "#" S2.vcf > Subhead
grep -v "#" S2.vcf > NH
grep -v "#" S2.vcf | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9}' > front
grep -v "#" S2.vcf | head -1 | awk '{print $9}' > FormatString 
d=$(awk 'BEGIN{ FS = ":" }{for (i = 1; i <= NF; i++) {if ($i == "DP") {print i; break;}}}' FormatString)
b=$(awk 'NR==3 {print $1}' MVFFparm1) #DP
awk -v var=$d -v var2=$b 'BEGIN { FS = "\t"; OFS = "\t" }{printf "%s %s", $1, $2; for (i = 10; i <= NF; i++) {split($i, parts, ":"); if (parts[var] >= var2) {printf "\t%s", $i;  } else {parts[1] = "./."; printf "\t%s:%s:%s:%s:%s", parts[1], parts[2], parts[3], parts[4], parts[5];} if (i == NF) {printf "\n";}}}' NH | cut -f2- | paste front - | tr ' ' '\t' | cat Subhead -  > t2.vcf

#Next, if you subset, you need to remove any sites that are mostly 0/0 or ./.  (these are not reported in a non-subsetted multi-sample VCF, but can be when you subset). 

bcftools query -f '%CHROM %POS %DP [\t%GT]\n' t2.vcf | cut -d " " -f4- > GT1
tr '/' '|' < GT1 | sed 's/0|0/b|b/g' > GT2 #convert 0/0 to b/b to be able to count bs.  
awk '{for (i=1; i<=NF;i++) if ($i=="b|b" || $i==".|.") c++; print c; c=0}' GT2 > GT3

e=$(awk 'NR==5 {print $1}' MVFFparm1)
d=$(lscpu | grep "CPU(s):" | head -1 | awk 'NR==1{print $2}' | awk -v var=$e '{print ($1*var)/100}' | awk '{printf "%.f\n", int($1+0.5)}')
bgzip t2.vcf
bcftools index --threads $d t2.vcf.gz
j=$(awk 'NR==6 {print $1 }' MVFFparm1 | sed 's/.gz//g' | sed 's/.vcf//g' | awk -F'/' '{print $NF}' )
k=$(date +"%m_%d_%y_at_%H_%M")
l=$(wc -l MVFFSamplesList | awk '{print $1}' ) #Number of samples = need to be less than this in GT3 which is hte count of 0/0
bcftools query -f '%CHROM %POS %DP\n' t2.vcf.gz | paste - GT3 | awk -v var=$l '{if ($4<var) print $1, $2, $2+1}' | tr ' ' '\t' |  bcftools view --threads $d -R - t2.vcf.gz > ${j}_${k}.vcf  
#bgzip and tabix for MFAR input
bgzip ${j}_${k}.vcf  
tabix ${j}_${k}.vcf.gz

h=$(awk 'NR==6 {print $1 }' MVFFparm1 | sed 's/.gz//g' | awk '{print $1".gz"}' )
i=$(bcftools stats $h | grep "number of records" | tr '\t' 'A' | awk -F: 'NR==2 {print $2}' | sed 's/A//g') #Total number of variants
e=$(grep -v "#" ${j}_${k}.vcf | wc -l) #total remaining
j=$(awk 'NR==6 {print $1 }' MVFFparm1 | sed 's/.gz//g' | sed 's/.vcf//g' | awk -F'/' '{print $NF}' )
k=$(date +"%m_%d_%y_at_%H_%M")
awk -v var=$i -v var2=$e 'NR==1{print var, var2, (var-var2)}' MVFFparm1 | awk 'BEGIN{print "Total_Starting_Variants", "Total_Remaining_After_Filter", "Total_Removed"}1' > VariantStats_${j}_${k}.txt

rm Ssubset.vcf.gz S2.vcf Subhead NH front FormatString t2.vcf.gz GT1 GT2 GT3 Ssubset.vcf.gz.csi t2.vcf.gz.csi

fi
#########################################################################################################################
if [ -f "NOSubset.subanswer" ] ; 
then 
h=$(awk 'NR==6 {print $1 }' MVFFparm1 | sed 's/.gz//g' | awk '{print $1".gz"}' ) #VCF sample name 
b=$(awk 'NR==3 {print $1}' MVFFparm1) #DP
c=$(awk 'NR==4 {print $1}' MVFFparm1) #Min number with data
bcftools query -f '%CHROM %POS [\t%DP]\n' $h | awk -v var=$b '{count = 0;for (i = 3; i <= NF; i++) {if ($i >= var) {count++;}} print $1, $2, count}' | awk -v var1=$c '{if ($3>=var1) print $1, $2, $2+1}' | tr ' ' '\t' | bcftools view -R - $h > S2.vcf
grep "#" S2.vcf > Subhead
grep -v "#" S2.vcf > NH
grep -v "#" S2.vcf | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9}' > front
grep -v "#" S2.vcf | head -1 | awk '{print $9}' > FormatString 
d=$(awk 'BEGIN{ FS = ":" }{for (i = 1; i <= NF; i++) {if ($i == "DP") {print i; break;}}}' FormatString)
b=$(awk 'NR==3 {print $1}' MVFFparm1) #DP
awk -v var=$d -v var2=$b 'BEGIN { FS = "\t"; OFS = "\t" }{printf "%s %s", $1, $2; for (i = 10; i <= NF; i++) {split($i, parts, ":"); if (parts[var] >= var2) {printf "\t%s", $i;  } else {parts[1] = "./."; printf "\t%s:%s:%s:%s:%s", parts[1], parts[2], parts[3], parts[4], parts[5];} if (i == NF) {printf "\n";}}}' NH | cut -f2- | paste front - | tr ' ' '\t' | cat Subhead -  > t2.vcf

#Next, if you subset, you need to remove any sites that are mostly 0/0 or ./.  (these are not reported in a non-subsetted multi-sample VCF, but can be when you subset). 

bcftools query -f '%CHROM %POS %DP [\t%GT]\n' t2.vcf | cut -d " " -f4- > GT1
tr '/' '|' < GT1 | sed 's/0|0/b|b/g' > GT2 #convert 0/0 to b/b to be able to count bs.  
awk '{for (i=1; i<=NF;i++) if ($i=="b|b" || $i==".|.") c++; print c; c=0}' GT2 > GT3

e=$(awk 'NR==5 {print $1}' MVFFparm1)
d=$(lscpu | grep "CPU(s):" | head -1 | awk 'NR==1{print $2}' | awk -v var=$e '{print ($1*var)/100}' | awk '{printf "%.f\n", int($1+0.5)}')
bgzip t2.vcf
bcftools index --threads $d t2.vcf.gz
j=$(awk 'NR==6 {print $1 }' MVFFparm1 | sed 's/.gz//g' | sed 's/.vcf//g' | awk -F'/' '{print $NF}' )
k=$(date +"%m_%d_%y_at_%H_%M")

l=$(bcftools query -l t2.vcf.gz | wc -l ) #Number of samples = need to be less than this in GT3 which is hte count of 0/0
bcftools query -f '%CHROM %POS %DP\n' t2.vcf.gz | paste - GT3 | awk -v var=$l '{if ($4<var) print $1, $2, $2+1}' | tr ' ' '\t' |  bcftools view --threads $d -R - t2.vcf.gz > ${j}_${k}.vcf  
bgzip ${j}_${k}.vcf  
tabix ${j}_${k}.vcf.gz
h=$(awk 'NR==6 {print $1 }' MVFFparm1 | sed 's/.gz//g' | awk '{print $1".gz"}' )
i=$(bcftools stats $h | grep "number of records" | tr '\t' 'A' | awk -F: 'NR==2 {print $2}' | sed 's/A//g') #Total number of variants
e=$(grep -v "#" ${j}_${k}.vcf | wc -l) #total remaining
j=$(awk 'NR==6 {print $1 }' MVFFparm1 | sed 's/.gz//g' | sed 's/.vcf//g' | awk -F'/' '{print $NF}' )
k=$(date +"%m_%d_%y_at_%H_%M")
awk -v var=$i -v var2=$e 'NR==1{print var, var2, (var-var2)}' MVFFparm1 | awk 'BEGIN{print "Total_Starting_Variants", "Total_Remaining_After_Filter", "Total_Removed"}1' > VariantStats_${j}_${k}.txt

rm S2.vcf Subhead NH front FormatString t2.vcf.gz GT1 GT2 GT3 t2.vcf.gz.csi

fi

#######################################################################################################################
echo "90"
echo "# Tidying"; sleep 2 
#rm *.subanswer 
) | zenity --width 800 --title "MVFF PROGRESS" --progress --auto-close
now=$(date)
echo "Script Finished" $now
printf 'Initials of person running program: \nOptional notes: \nMinimum depth of coverage for retention: \nMinimum number of samples meeting coverage threshold: \nPercent of computer CPU allocated: \nPath to VCF file: \nPath to sample subset list if chosen: \nName of directory created for analysis: ' > parm
paste parm MVFFparm1 | tr '\t' ' ' > plog
k=$(date +"%m_%d_%y_at_%H_%M")
cat MVFFt.log plog > MVFF_${k}.log
rm plog MVFFparm1 MVFFt.log *answer1 *subanswer parm MVFFSamplesList


##########END OF PROGRAM###############################################################################################

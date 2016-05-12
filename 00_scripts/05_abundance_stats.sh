#!/bin/bash
#$ -N aboudance_stats
#$ -M userID
#$ -m beas
#$ -pe smp 8
#$ -l h_vmem=60G
#$ -l h_rt=20:00:00
#$ -cwd
#$ -S /bin/bash

#Move to job submission directory
cd $PBS_O_WORKDIR

#Global variables
TRANSCRIPTOME="05_assembly/Trinity.fasta"
READSLEFT="04_merged/*left.fq.gz"
READSRIGHT="04_merged/*right.fq.gz"
READSSINGLE="03_trimmed/*fq.gz"

#########################################################################
#Required

trans="--transcripts $TRANSCRIPTOME"           		#transcript fasta file
seq="--seqType fq"	               			#fq|fa

#  If Paired-end:
left="--left $READSLEFT"
right="--right $READSRIGHT"

#  or Single-end:
#single="--single $READSSINGLE"
meth="--est_method RSEM"         			#abundance estimation method.
                                        		#alignment_based:  RSEM|eXpress       
                                        		#alignment_free: kallisto|salmon
output="--output_dir 06_assembly_stats"            	#write all files to output directory

#  if alignment_based est_method:
alnmeth="--aln_method bowtie"           			#bowtie|bowtie2|(path to bam file) alignment method.  (note: RSEM requires bowtie)
                                       			#(if you already have a bam file, you can use it here instead of rerunning bowtie)
# Optional:
#strand="--SS_lib_type <string>"          		#strand-specific library type:  paired('RF' or 'FR'), single('F' or 'R').
                                         		#(note, no strand-specific mode for kallisto)
cpu="--thread_count 8"                  		#number of threads to use (default = 4)
#debug="--debug" 	          	             	#retain intermediate files
#genetrans="--gene_trans_map <string>"        		#file containing 'gene(tab)transcript' identifiers per line.
#     or  
trinmode="--trinity_mode" 	  	                #Setting --trinity_mode will automatically generate the gene_trans_map and use it.

prepref="--prep_reference"	  	             	#prep reference (builds target index)
#outpref="--output_prefix <string>"    			#prefix for output files.  Defaults to --est_method setting.

########################################
#  Parameters for single-end reads:
#
#fraglength="--fragment_length 200"   		      	#specify RNA-Seq fragment length (default: 200) 
#frgstd=" --fragment_std 80"            			#fragment length standard deviation (defalt: 80)
########################################
#   bowtie-related parameters: (note, tool-specific settings are further below)

maxins="--max_ins_size 800" 	 	     	   	#maximum insert size (bowtie -X parameter, default: 800)
coord="--coordsort_bam"                  		#provide coord-sorted bam in addition to the default (unsorted) bam.
########################################
#  RSEM opts:
#bowtie_rsem="--bowtie_RSEM <string>" 		        #if using 'bowtie', default: "--all --best --strata -m 300 --chunkmbs 512"
#bowtie2_rsem="--bowtie2_RSEM <string>"         		#if using 'bowtie2', default: "--no-mixed --no-discordant --gbar 1000 --end-to-end -k 200 "
#include_rsem_bam="--include_rsem_bam" 	    	        # provide the RSEM enhanced bam file including posterior probabilities of read assignments.
#rsem_opt="--rsem_add_opts <string>"        		#additional parameters to pass on to rsem-calculate-expression
##########################################################################
#  eXpress opts:
#  --bowtie_eXpress <string>  default: "--all --best --strata -m 300 --chunkmbs 512"
#  --bowtie2_eXpress <string> default: "--no-mixed --no-discordant --gbar 1000 --end-to-end -k 200 "
#  --eXpress_add_opts <string>  default: ""

##########################################################################
#  kallisto opts:
#  --kallisto_add_opts <string>  default:   
##########################################################################
#  salmon opts:
#  --salmon_idx_type <string>    quasi|fmd (defalt: quasi)
#  --salmon_add_opts <string>    default: 


#run reference preparation
00_scripts/trinity_utils/util/align_and_estimate_abundance.pl $trans $meth $alnmeth $trinmode \ 
	$prepref $outpref 2>&1 | tee 98_log_files/"$TIMESTAMP"_prepref.log

#Align
00_scripts/trinity_utils/util/align_and_estimate_abundance.pl $trans $seq $single $left $right \
	$meth $output $trinmode \
	$alnmeth $strand $cpu \
	$maxins $coord $bowtie_rsem $bowtie2_rsem \
	$include_rsem_bam $rsem_opt 2>&1 | tee 98_log_files/"$TIMESTAMP"_align.log


#note: Not all the commands have been integrated to data	

#!/bin/bash
#SBATCH --job-name=submit
#SBATCH --partition=sandbox
#SBATCH --time=00-04:00:00 ## time format is DD-HH:MM:SS
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --output=submit.%A.out
 
 
MODELDIR=${HOME}/cesm1_2_2
CASEDIR=${HOME}/lus_scratch/cesm_output/
EXPNAME=ood.I5
CASEROOT=$CASEDIR/$EXPNAME
 
module purge
module load lang/Perl/5.28.1-GCCcore-6.3.0
 
#================================================================;
#===================== 1. CREATE CASE ===========================;
#================================================================;
cd $MODELDIR/scripts
./create_newcase -case $CASEDIR/$EXPNAME -compset FC5 -res f19_f19 -mach mana_qdr
#  ./create_newcase -case $CASEDIR/$EXPNAME -compset FC5 -res f19_f19 -mach mana_hdr
#=================== PE LAYOUT CONTROL ====================#
cd $CASEDIR/$EXPNAME
 
./xmlchange -file env_mach_pes.xml -id NTASKS_ATM -val "24"
./xmlchange -file env_mach_pes.xml -id NTASKS_OCN -val "24"
./xmlchange -file env_mach_pes.xml -id NTASKS_LND -val "24"
./xmlchange -file env_mach_pes.xml -id NTASKS_ICE -val "24"
./xmlchange -file env_mach_pes.xml -id NTASKS_CPL -val "24"
./xmlchange -file env_mach_pes.xml -id NTASKS_GLC -val "24"
./xmlchange -file env_mach_pes.xml -id NTASKS_ROF -val "24"
./xmlchange -file env_mach_pes.xml -id NTASKS_WAV -val "24"
./xmlchange -file env_mach_pes.xml -id NTASKS_GLC -val "24"
 
./cesm_setup
#================================================================;
#========================== 2. BUILD ============================;
#================================================================;
cd $CASEDIR/$EXPNAME
 
#==================== RUN START CONTROL ==================#
./xmlchange -file env_run.xml -id RUN_TYPE -val "startup"
 
#==================== RUN TIME CONTROL =====================#
./xmlchange -file env_run.xml -id STOP_OPTION -val "nyears"
./xmlchange -file env_run.xml -id STOP_N -val "50"
 
#===================== RESTART CONTROL ==============#
./xmlchange -file env_run.xml -id REST_OPTION -val "nyears"
./xmlchange -file env_run.xml -id REST_N -val "1"
 
#================= OUTPUT CONTROL ================#
./xmlchange -file env_run.xml -id DOUT_S -val "TRUE"
./xmlchange -file env_run.xml -id DOUT_S_ROOT -val '$CASEROOT/output'
 
 
./xmlchange -file env_build.xml -id DEBUG -val "TRUE"
 
#========================= BUILD ===========================#
./$EXPNAME.build
 
#================================================================;
#========================== 3. RUN ============================;
#================================================================;
./$EXPNAME.submit
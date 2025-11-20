#!/bin/bash
# Author Ana Gonzalez-Nicolas

# Usage: ./compare_nc.sh test.nc ref.nc var1 var2 var3 ...
# Example: ./compare_nc.sh test.nc ref.nc H2OSOI NEE ER GPP QSOIL

# Uses NCO
ml Stages/2025  GCC  OpenMPI
module load NCO


## INPUTS read as args:
Name_TEST=$1
Name_REF=$2
# shift 2   # remove first two args, remaining are variables to compare
# VARS=("$@")

## INPUTS given within the script:
# Paths to files
#Name_TEST=./execute/TSMP2_workflow-engine/run/sim_eclm_20170701/eCLM_eur-11u.clm2.h0.2017-07-01-00000.nc
#Name_TEST=/p/project1/cslts/shared_data/rcmod_TSMP2_WFE_reference_CORDEX_JURECA/simres/eclm_20170701/out/eclm/eCLM_eur-11u.clm2.h0.2017-07-01-00000.nc
#Name_REF=/p/project1/cslts/shared_data/rcmod_TSMP2_WFE_reference_CORDEX_JURECA/simres/eclm_20170701/out/eclm/eCLM_eur-11u.clm2.h0.2017-07-01-00000.nc

# Variables to compare (edit this list as needed)
VARS=("TWS" "H2OSOI" "TSOI" "TG" "EFLX_LH_TOT" "FSH" "FSA" "FSR" "FIRA" "Rnet" "EFLX_SOIL_GRND")

# Threshold (set externally or here)
zero=0.00000001
fac=86400.0  # conversion factor (seconds -> days)


# STEP 0: Check if NC files exist
missing_files=0
if [ ! -f "$Name_TEST" ]; then
    echo "ERROR: TEST file does not exist: $Name_TEST"
    missing_files=1
    echo "The eCLM comparison is MISSING-NC-files-TEST"
    exit 2
fi
if [ ! -f "$Name_REF" ]; then
    echo "ERROR: REF file does not exist: $Name_REF"
    missing_files=1
    echo "The eCLM comparison is MISSING-NC-files-REF"
    exit 2	
fi


# STEP 1: Compute differences and max difference
echo "Computing differences"
ncdiff $Name_TEST $Name_REF diff.nc


# STEP 2: Compute abs(max()) for each variable
echo
echo "*** Calculating max(abs(var)) for variables"

# Initialize max.nc with the first variable
first_var=${VARS[0]}
echo "variable= $first_var"
ncap2 -O -s "max_${first_var}=abs(max(${first_var}))" diff.nc max.nc

# Append other variables
for VAR in "${VARS[@]:1}"; do
    echo "variable= $VAR"
    ncap2 -A -s "max_${VAR}=abs(max(${VAR}))" diff.nc max.nc
done


# STEP 3: Check max. difference for each variable
sumVar=0
noVar=0	   
echo
echo "*** Checking if variable has error greater than threshold $zero:"
for VAR in "${VARS[@]}"; do
    echo "variable= $VAR"
    value=$(ncks -C -H -v max_${VAR} -s "%.10f" max.nc )   
    if [ -z "$value" ]; then
        echo "Variable $VAR not found in max.nc"
        continue
    fi	
    if (( $(echo "$value > $zero" | bc -l) )); then
        echo "Variable $VAR error = $value"
        sumVar=$((sumVar+1))
    fi
done
echo
echo "There are $noVar variables not found in the nc.file"

# STEP 4: Summary report
echo
if [ $sumVar -gt 0 ]; then
    echo "Threshold is $zero"
    echo "There are $sumVar variables with an error greater than the threshold $zero"  
    echo "The eCLM comparison is FAILED"
    echo
    exit 1
else 
    echo "Threshold is $zero"
    echo "There are $sumVar variables with an error greater than the threshold $zero"
    echo "The eCLM comparison is SUCCESSFUL"
fi
echo

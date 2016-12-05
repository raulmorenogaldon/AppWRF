#!/bin/bash

WRF=$PWD/WRFV3
WPS=$PWD/WPS

echo "================================"

# Load configuration
. ./configure_env.env

echo "--------------------------------"
echo "Configuration:"
echo "Start date: "$(date -u -d @$CFG_START_DATE)
echo "End   date: "$(date -u -d @$CFG_END_DATE)
echo "Ref lat: "$CFG_REF_LAT
echo "Ref lon: "$CFG_REF_LON

# Copy namelists
echo "--------------------------------"
echo "Copying namelist.input ..."
cp namelist.wrf.template $WRF/run/namelist.input || exit 1

# Change dir
cd $WRF/run

# Print namelist
echo "--------------------------------"
echo "namelist.input:"
cat ./namelist.input

# Link met_em files
echo "--------------------------------"
echo "Linking WPS generated files..."
ln -s $WPS/met_em* .

echo "--------------------------------"
echo "Present files:"
find . -maxdepth 1 -type f -name "met_em*"

# Execute real
echo "--------------------------------"
echo "Executing EM_REAL..."
mpiexec -n [[[#CPUS]]] bash -c "set -e && ulimit -s unlimited && ./real.exe" || {
	echo "WRF failed with code: $?"
	ln -s $WRF/run/wrf* [[[#OUTPUTPATH]]]/
	exit 1
}

# Execute WRF
echo "--------------------------------"
echo "Executing WRF..."
mpiexec -n [[[#TOTALCPUS]]] bash -c "set -e && ulimit -s unlimited && ./wrf.exe" {
	echo "EM_REAL failed with code: $?"
	ln -s $WRF/run/wrf* [[[#OUTPUTPATH]]]/
	exit 1
}

# Copying
echo "--------------------------------"
echo "Copying output files..."
ln -s $WRF/run/wrf* [[[#OUTPUTPATH]]]/

echo "--------------------------------"
echo "DONE!"

echo "--------------------------------"
echo "================================"

exit 0

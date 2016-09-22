#!/bin/bash

WRF=$PWD/WRFV3
WPS=$PWD/WPS

echo "================================"
echo "--------------------------------"
icc -v >& /dev/null
if [ $? -eq 0 ]; then
	echo "Compiler is Intel"
	export COMPILER=intel
else
	echo "Compiler is GNU"
	export COMPILER=gnu
fi

# Set env
echo "--------------------------------"
echo "Setting WRFIO_NCD_LARGE_FILE_SUPPORT..."
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
echo "Setting MPI_LIB..."
export MPI_LIB=-L/$MPI_LIB

# Set error trap
set -e

# WRF compile
echo "--------------------------------"
echo "Compiling WRF..."
cd $WRF
./configure > wrf_configure.log 2>&1
./compile -j [[[#CPUS]]] wrf > wrf_compile.log 2>&1
./compile em_real > em_real_compile.log 2>&1

# WPS compile
echo "--------------------------------"
echo "Compiling WPS..."
cd $WPS
./configure > wrf_configure.log 2>&1
./compile > wps_compile.log 2>&1

# Move namelists
echo "--------------------------------"
echo "Copying namelist.wps..."
cp ../namelist.wps .

echo "--------------------------------"
echo "================================"

exit 0

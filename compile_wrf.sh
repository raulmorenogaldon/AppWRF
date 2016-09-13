#!/bin/bash

WRF=$PWD/WRFV3
WPS=$PWD/WPS

echo "================================"
echo "--------------------------------"
icc -v >& /dev/null
if [ $? -eq 0 ]; then
	echo "Compiler is Intel"
	COMPILER=intel
else
	echo "Compiler is GNU"
	COMPILER=gnu
fi

# Error checking
set -e

# Set env
echo "--------------------------------"
echo "Setting WRFIO_NCD_LARGE_FILE_SUPPORT..."
export WRFIO_NCD_LARGE_FILE_SUPPORT=1

# WRF compile
echo "--------------------------------"
echo "Compiling WRF..."
cd $WRF
./configure
./compile -j [[[#CPUS]]] wrf
./compile -j [[[#CPUS]]] em_real

# WPS compile
echo "--------------------------------"
echo "Compiling WPS..."
cd $WPS
./configure
./compile -j [[[#CPUS]]]

echo "--------------------------------"
echo "================================"

exit 0

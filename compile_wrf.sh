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

# WRF compile
echo "--------------------------------"
echo "Compiling WRF..."
cd $WRF
./configure
./compile -j [[[#CPUS]]] wrf 2>&1 wrf_compile.log
./compile em_real 2>&1 em_real_compile.log

# WPS compile
echo "--------------------------------"
echo "Compiling WPS..."
cd $WPS
./configure
./compile 2>&1 wps_compile.log

echo "--------------------------------"
echo "================================"

exit 0

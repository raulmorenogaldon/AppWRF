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

# Set error trap
set -e

# Set env
echo "--------------------------------"
echo "Loading environment variables..."
. ./configure_env.env
echo "Setting WRFIO_NCD_LARGE_FILE_SUPPORT..."
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
echo "Setting MPI_LIB..."
export MPI_LIB=-L/$MPI_LIB
#echo "Setting JASPER paths..."
#export JASPERLIB='[[[#LIBPATH]]]/lib'
#export JASPERINC='[[[#LIBPATH]]]/include'

echo "--------------------------------"
echo "Configuration:"
echo "Start date: "$(date -u -d @$CFG_START_DATE)
echo "End   date: "$(date -u -d @$CFG_END_DATE)
echo "Ref lat: "$CFG_REF_LAT
echo "Ref lon: "$CFG_REF_LON

# Extract geographic data from input
echo "--------------------------------"
echo "Extracting static geographic data..."
#ln -s /home/rmoreno2/GEOG_DATA/geog/* [[[#INPUTPATH]]]/
cd [[[#INPUTPATH]]]
if [ -f *.tar.bz2 ]; then
	tar jxf *.tar.bz2
	rm *.tar.bz2
fi

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
./configure > wps_configure.log 2>&1
./compile > wps_compile.log 2>&1

# Download GRIB files into WPS folder
echo "--------------------------------"
echo "Downloading GRIB files..."
../download_gfs.sh

echo "--------------------------------"
echo "DONE!"

echo "--------------------------------"
echo "================================"

exit 0

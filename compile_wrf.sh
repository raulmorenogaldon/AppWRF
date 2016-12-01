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
echo "Start date: "$(date -d @$CFG_START_DATE)
echo "End   date: "$(date -d @$CFG_END_DATE)
echo "Ref lat: "$CFG_REF_LAT
echo "Ref lon: "$CFG_REF_LON

# Extract geographic data from input
echo "--------------------------------"
echo "Extracting static geographic data..."
#ln -s /home/rmoreno2/GEOG_DATA/geog/* [[[#INPUTPATH]]]/
cd [[[#INPUTPATH]]]
tar jxf *.tar.bz2
rm *.tar.bz2

# WRF compile
echo "--------------------------------"
echo "Compiling WRF..."
cd $WRF
./configure > wrf_configure.log 2>&1
./compile -j 1 wrf > wrf_compile.log 2>&1
./compile em_real > em_real_compile.log 2>&1

# WPS compile
echo "--------------------------------"
echo "Compiling WPS..."
cd $WPS
./configure > wrf_configure.log 2>&1
./compile > wps_compile.log 2>&1

# Copy namelist.wps
echo "--------------------------------"
echo "Copying namelist.wps ..."
cp ../namelist.wps .

# Download GRIB files into WPS folder
echo "--------------------------------"
echo "Downloading GRIB files..."
../download_gfs.sh

# Execute geogrid
echo "--------------------------------"
echo "Executing geogrid..."
./geogrid.exe

# Set GFS Vtable
echo "--------------------------------"
echo "Linking GFS Vtable..."
ln -s ungrib/Variable_Tables/Vtable.GFS Vtable

# Ungrib files
echo "--------------------------------"
echo "Executing ungrib..."
./link_grib.csh GRIB*
./ungrib.exe

# Metgrid
echo "--------------------------------"
echo "Executing metgrib..."
./metgrid.exe

echo "--------------------------------"
echo "Generated:"
find . -maxdepth 1 -type f -name "met_em*"
find . -maxdepth 1 -type f -name "geo_em*"

echo "--------------------------------"
echo "DONE!"

echo "--------------------------------"
echo "================================"

exit 0

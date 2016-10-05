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

# Setup environment
echo "--------------------------------"
echo "Setup environment..."
. ./configure_env.env
./setup.sh $CFG_CENTER_LAT $CFG_CENTER_LON 100 $CFG_BOUNDS_HEIGHT $CFG_BOUNDS_WIDTH $CFG_DATE_INI"_"$CFG_HOUR_INI $CFG_DATE_END"_"$CFG_HOUR_END $CFG_INPUTPATH

# Extract geographic data from input
echo "--------------------------------"
echo "Extracting static geographic data..."
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
../download_gfs.sh $CFG_DATE_INI $CFG_HOUR_INI $CFG_DATE_END $CFG_HOUR_END $CFG_BOUNDS_L_LON $CFG_BOUNDS_R_LON $CFG_BOUNDS_T_LAT $CFG_BOUNDS_B_LAT

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

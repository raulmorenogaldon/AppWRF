#!/bin/bash

WRF=$PWD/WRFV3
WPS=$PWD/WPS

echo "================================"

# Error checking
set -e

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
echo "Copying namelists ..."
cp namelist.wps.template $WPS/namelist.wps
cp namelist.wrf.template $WRF/run/namelist.input

# Change dir
cd $WPS

# Execute geogrid
echo "--------------------------------"
echo "Executing geogrid..."
mpiexec -n [[[#TOTALCPUS]]] ./geogrid.exe

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
mpiexec -n [[[#TOTALCPUS]]] ./metgrid.exe

echo "--------------------------------"
echo "Generated:"
find . -maxdepth 1 -type f -name "met_em*"
find . -maxdepth 1 -type f -name "geo_em*"

# Change dir
cd $WRF/run

# Link met_em files
echo "--------------------------------"
echo "Linking WPS generated files..."
ln -s $WPS/met_em* .

# Execute real
echo "--------------------------------"
echo "Executing EM_REAL..."
mpiexec -n [[[#TOTALCPUS]]] bash -c "ulimit -s unlimited && ./real.exe"

# Execute WRF
echo "--------------------------------"
echo "Executing WRF..."
mpiexec -n [[[#TOTALCPUS]]] bash -c "ulimit -s unlimited && ./wrf.exe"

echo "--------------------------------"
echo "DONE!"

echo "--------------------------------"
echo "================================"

exit 0

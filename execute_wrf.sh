#!/bin/bash

WRF=$PWD/WRFV3
WPS=$PWD/WPS

echo "================================"
echo "--------------------------------"

# Error checking
set -e

echo "--------------------------------"
echo "Extracting static geographic data..."
cd [[[#INPUTPATH]]]
tar jxf *.tar.bz2

# Execute geogrid
echo "--------------------------------"
echo "Executing geogrid..."
cd $WPS
./geogrid.exe

# Set GFS Vtable
echo "--------------------------------"
echo "Linking GFS Vtable..."
ln -s ungrib/Variable_Tables/Vtable.GFS Vtable

# Ungrib files
echo "--------------------------------"
echo "Executing ungrib..."
./link_grib.exe [[[#INPUTPATH]]]
./ungrib.exe

# Metgrid
echo "--------------------------------"
echo "Executing metgrib..."
./metgrid.exe

echo "--------------------------------"
echo "Generated:"
find . -maxdepth 1 -type f -name "met_em*"

echo "--------------------------------"
echo "================================"

exit 0

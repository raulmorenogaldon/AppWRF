#!/usr/bin/env python

import sys
import domain
import latlon
import namelist_wps
from math import *

# Begin
# Get center coordinates
lat = float(sys.argv[1])
lon = float(sys.argv[2])

# Get grid dimensions
grid_x = int(sys.argv[3])
size_x = float(sys.argv[4])
size_y = float(sys.argv[5])

# Get dates
date_ini = sys.argv[6]
date_end = sys.argv[7]

# Get inputpath
inputpath = sys.argv[8]

# Compute resolution and grid Y dimension
res = size_x / grid_x
grid_y = int(size_y / res)

# Compute domains
first_dom = domain.define(lat, lon, grid_x, grid_y, res, date_ini, date_end)
secnd_dom = domain.define(lat, lon, grid_x, grid_y, res*3, date_ini, date_end)
third_dom = domain.define(lat, lon, grid_x, grid_y, res*9, date_ini, date_end)

# Generate namelist.wps and save to file
wps = namelist_wps.generate([third_dom, secnd_dom, first_dom], inputpath)
f = open('namelist.wps','w')
f.write(wps)
f.close()

# Create GFS bounds file
f = open('BOUNDS.env','w')
f.write("""#!/bin/sh
export CFG_BOUNDS_T_LAT={0}
export CFG_BOUNDS_L_LON={1}
export CFG_BOUNDS_B_LAT={2}
export CFG_BOUNDS_R_LON={3}
""".format(
	min(third_dom['t_lat']+1.0, 90.0),
	max(third_dom['l_lon']-1.0, -180.0),
	max(third_dom['b_lat']-1.0, -90.0),
	min(third_dom['r_lon']+1.0, 180.0)
))
f.close()

print first_dom
print secnd_dom
print third_dom

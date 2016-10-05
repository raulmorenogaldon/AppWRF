#!/usr/bin/env python

import sys
from math import *

# Earth radius
EARTH_R = 6371000 # Meters

# namelist.wps template
# {0} Num domains
# {1} Start date (yyyy-mm-dd_hh:mm:ss) (array)
# {2} End date (yyyy-mm-dd_hh:mm:ss) (array)
# {3} Grid X dimension (array)
# {4} Grid Y dimension (array)
# {5} Bigger grid resolution
# {6} Projection
# {7} Center latitudes
# {8} Center longitudes
# {9} Geo data resolution (array)
# {10} Parent grid IDs (array)
# {11} Parent ratios (array)
# {12} Grid IDs (array)
NAMELIST_WPS = """
&share
 wrf_core = 'ARW',
 max_dom = {0},
 start_date = {1}
 end_date   = {2}
 interval_seconds = 21600,
 io_form_geogrid = 2,
/

&geogrid
 parent_id = {10}
 parent_grid_ratio = {11}
 grid_id = {12}
 e_we =  {3}
 e_sn =  {4}
 dx = {5},
 dy = {5},
 map_proj = {6},
 ref_lat   =  {7},
 ref_lon   =  {8},
 truelat1  =  {7},
 truelat2  =  {7},
 stand_lon =  {8},
 geog_data_path = '[[[#INPUTPATH]]]/',
 ref_x = 50.0,
 ref_y = 39.0,
 geog_data_res = {9}
/

&ungrib
 out_format = 'WPS',
 prefix = 'FILE',
/

&metgrid
 fg_name = 'FILE'
 io_form_metgrid = 2,
/
"""

# Distance
def distance(lat1, lon1, lat2, lon2):

	# Deltas
	d_lat = lat2 - lat1
	d_lon = lon2 - lon1

	# Compute distance
	a = sin(d_lat/2.0) * sin(d_lat/2.0) + cos(lat1) * cos(lat2) * sin(d_lon/2.0) * sin(d_lon/2.0)
	c = 2.0 * atan2(sqrt(a), sqrt(1-a))
	dist = EARTH_R * c

	return dist

# Displace into direction
def displace(lat, lon, dist, theta):
	# Radians
	lat = radians(lat)
	lon = radians(lon)
	theta = radians(theta)

	# Delta
	delta = dist / EARTH_R

	# Compute
	dst_lat = asin( sin(lat) * cos(delta) + cos(lat) * sin(delta) * cos(theta) )
	dst_lon = lon + atan2( sin(theta) * sin(delta) * cos(lat), cos(delta) - sin(lat) * sin(dst_lat) )
	dst_lon = (dst_lon + 3.0 * pi) % (2.0 * pi) - pi

	return [degrees(dst_lat), degrees(dst_lon)]

# Generate a domain
def domain(lat, lon, res, size):
	# Half size
	hsize = size / 2.0

	# Domain data
	t_lat = displace(lat, lon, hsize, 0)[0]
	b_lat = displace(lat, lon, hsize, 180)[0]
	l_lon = displace(lat, lon, hsize, 270)[1]
	r_lon = displace(lat, lon, hsize, 90)[1]
	dom = {
		'center': [lat, lon],
		'res': res,
		'size': size,
		'grid': int(size / res),
		't_lat': t_lat,
		'b_lat': b_lat,
		'l_lon': l_lon,
		'r_lon': r_lon
	}

	return dom

# Generate namelist.wps
def gen_wps(doms):
# {0} Num domains
# {1} Start date (yyyy-mm-dd_hh:mm:ss) (array)
# {2} End date (yyyy-mm-dd_hh:mm:ss) (array)
# {3} Grid X dimension (array)
# {4} Grid Y dimension (array)
# {5} Bigger grid resolution
# {6} Projection
# {7} Center latitudes
# {8} Center longitudes
# {9} Geo data resolution (array)
# {10} Parent grid IDs (array)
# {11} Parent ratios (array)
# {12} Grid IDs (array)
	# General parameters
	num_dom = len(doms)
	start_date = ""
	end_date = ""
	gx = ""
	gy = ""
	res = str(int(doms[0]['res']))
	proj = "'mercator'"
	lat = str(doms[0]['center'][0])
	lon = str(doms[0]['center'][1])
	geo_res = ""
	parent_ids = ""
	parent_ratios = ""
	grid_ids = ""

	# Iterate domains
	grid_id = 0
	for dom in doms:
		# Domain parameters
		grid_id = grid_id + 1
		if grid_id == 1:
			ratio = 1
		else:
			ratio = int(doms[grid_id-2]['res']/dom['res'])

		# Fill
		start_date = start_date + "'1990-00-00_00:00:00', "
		end_date = end_date + "'1990-00-00_00:00:00', "
		gx = gx + str(dom['grid']) + ", "
		gy = gy + str(dom['grid']) + ", "
		geo_res = geo_res + "'2deg+gtopo_10m+usgs_10m+10m+nesdis_greenfrac', "
		parent_ids = parent_ids + str(grid_id - 1) + ", "
		parent_ratios = parent_ratios + str(ratio) + ", "
		grid_ids = grid_ids + str(grid_id) + ", "

	# Template
	namelist = NAMELIST_WPS.format(
		num_dom,
		start_date,
		end_date,
		gx,
		gy,
		res,
		proj,
		lat,
		lon,
		geo_res,
		parent_ids,
		parent_ratios,
		grid_ids
	)

	print namelist

# Parameters
# 1: Center lat
# 2: Center lon
# 3: Number of grid cells in one dimension
# 4: Grid cell width (m)

# Begin
# Get center coordinates
lat = float(sys.argv[1])
lon = float(sys.argv[2])

# Get grid dimensions
res = float(sys.argv[3])
size = float(sys.argv[4])

first_dom = domain(lat, lon, res, size)
second_dom = domain(lat, lon, res * 3, size * 3)
third_dom = domain(lat, lon, res * 9, size * 9)

print first_dom
print second_dom
print third_dom

gen_wps([third_dom, second_dom, first_dom])

print "Center; {0} {1};".format(first_dom['center'][0], first_dom['center'][1]) # Center Lat/Lon
print "Res; {0};".format(first_dom['res']) # Resolution (m)
print "Size; {0};".format(first_dom['size']) # Size (m)

# Bounds top-left Lat/Lon and bottom-right Lat/Lon
print "Bounds; {0} {1} {2} {3};".format(
	first_dom['t_lat'],
	first_dom['l_lon'],
	first_dom['b_lat'],
	first_dom['r_lon']
)

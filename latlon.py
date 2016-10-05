from math import *

# Earth radius
EARTH_R = 6371000 # Meters

# Distance
def distance(lat1, lon1, lat2, lon2):
        # To radians
        lat1 = radians(lat1)
        lon1 = radians(lon1)
        lat2 = radians(lat2)
        lon2 = radians(lon2)

	# Deltas
	d_lat = lat2 - lat1
	d_lon = lon2 - lon1

	# Compute distance
	a = sin(d_lat/2.0) * sin(d_lat/2.0) + cos(lat1) * cos(lat2) * sin(d_lon/2.0) * sin(d_lon/2.0)
	c = 2.0 * atan2(sqrt(a), sqrt(1-a))
	dist = EARTH_R * c

	return dist

# Displace with theta bearing
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

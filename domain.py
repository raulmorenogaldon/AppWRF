import latlon

# Define a domain
def define(lat, lon, grid_x, grid_y, res, date_ini, date_end):
	# Get distances
	size_x = grid_x * res
	size_y = grid_y * res

	# Half size
	hsize_x = size_x / 2.0
	hsize_y = size_y / 2.0
	
	# Domain data
	t_lat = latlon.displace(lat, lon, hsize_y, 0)[0]
	b_lat = latlon.displace(lat, lon, hsize_y, 180)[0]
	l_lon = latlon.displace(lat, lon, hsize_x, 270)[1]
	r_lon = latlon.displace(lat, lon, hsize_x, 90)[1]
	dom = {
		'center': [lat, lon],
		'size_x': size_x,
		'size_y': size_y,
		'res': size_x / grid_x,
		'grid_x': grid_x,
		'grid_y': grid_y,
		't_lat': t_lat,
		'b_lat': b_lat,
		'l_lon': l_lon,
		'r_lon': r_lon,
		'date_ini': date_ini,
		'date_end': date_end
	}

	return dom

import latlon
from math import *

# Earth radius
EARTH_R = 6371000 # Meters

####################################################
# namelist.wps template
# {0} Num domains
# {1} Start date (yyyy-mm-dd_hh:mm:ss) (array)
# {2} End date (yyyy-mm-dd_hh:mm:ss) (array)
# {3} Grid X dimension (array)
# {4} Grid Y dimension (array)
# {5} Bigger domain X length
# {6} Bigger domain Y length
# {7} Projection
# {8} Center latitudes
# {9} Center longitudes
# {10} Geo data resolution (array)
# {11} Parent grid IDs (array)
# {12} Parent ratios (array)
# {13} Relative i position to parent (array)
# {14} Relative j position to parent (array)
# {15} Input files path
####################################################

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
 parent_id = {11}
 parent_grid_ratio = {12}
 i_parent_start = {13}
 j_parent_start = {14}
 e_we =  {3}
 e_sn =  {4}
 dx = {5},
 dy = {6},
 map_proj = {7},
 ref_lat   =  {8},
 ref_lon   =  {9},
 truelat1  =  {8},
 truelat2  =  {8},
 stand_lon =  {9},
 geog_data_path = '{15}',
 geog_data_res = {10}
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

# Obtain parent domain bottom/left grid coordinates
def get_ij(dom, parent_dom):
    i_dist = latlon.distance(dom['center'][0], dom['l_lon'], dom['center'][0], parent_dom['l_lon'])
    j_dist = latlon.distance(dom['t_lat'], dom['center'][1], parent_dom['t_lat'], dom['center'][1])
    i_parent = int(round(i_dist / parent_dom['res'], 0)) + 1
    j_parent = int(round(j_dist / parent_dom['res'], 0)) + 1
    return [i_parent, j_parent]

# Generate namelist.wps
def generate(domains, inputpath):
    # General parameters
    num_dom = len(domains)
    start_date = ""
    end_date = ""
    gx = ""
    gy = ""
    size_x = str(int(domains[0]['size_x']))
    size_y = str(int(domains[0]['size_y']))
    proj = "'mercator'"
    lat = str(domains[0]['center'][0])
    lon = str(domains[0]['center'][1])
    geo_res = ""
    parent_ids = ""
    parent_ratios = ""
    i_parent = ""
    j_parent = ""

    # Iterate domains
    grid_id = 0
    for dom in domains:
        # Domain parameters
        grid_id = grid_id + 1
        if grid_id == 1:
            ratio = 1
            ij = [1, 1]
            parent_ids = parent_ids + "1, "
        else:
            ratio = float(domains[grid_id-2]['res']/dom['res'])
            if ratio % 1 != 0.0:
                print "Warning: Domain", grid_id,"ratio is not rounded = ", ratio
                ij = get_ij(dom, domains[grid_id-2])
                parent_ids = parent_ids + str(grid_id-1) + ", "
            ratio = int(ratio)

        # Fill
        start_date = start_date + "'{0}', ".format(dom['date_ini'])
        end_date = end_date + "'{0}', ".format(dom['date_end'])
        gx = gx + str(dom['grid_x']) + ", "
        gy = gy + str(dom['grid_y']) + ", "
        geo_res = geo_res + "'2deg+gtopo_10m+usgs_10m+10m+nesdis_greenfrac', "
        parent_ratios = parent_ratios + str(ratio) + ", "
        i_parent = i_parent + "{0}, ".format(ij[0])
        j_parent = j_parent + "{0}, ".format(ij[1])

    # Fill template
    namelist = NAMELIST_WPS.format(
        num_dom,
        start_date,
        end_date,
        gx,
        gy,
        size_x,
        size_y,
        proj,
        lat,
        lon,
        geo_res,
        parent_ids,
        parent_ratios,
        i_parent,
        j_parent,
        inputpath
    )

    return namelist


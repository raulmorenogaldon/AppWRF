#!/bin/sh
# $1: Initial DAY (format yyyymmdd)
# $2: Initial HOUR (00, 06, 12, 18)
# $3: End DAY (format yyyymmdd)
# $4: End HOUR (00, 06, 12, 18)
# $5: Left longitude
# $6: Right longitude
# $7: Top latitude
# $8: Bottom latitude

# Initial and end dates
DAY_INI=$1
HOUR_INI=$2
DATE_INI="${DAY_INI} ${HOUR_INI}"

DAY_END=$3
HOUR_END=$4
DATE_END="${DAY_END} ${HOUR_END}"

# Coordinates
LEFT_LON=$5
RIGHT_LON=$6
TOP_LAT=$7
BOTTOM_LAT=$8

# Delta hours
DELTA_HOURS=3
DELTA_SEC=$(expr $DELTA_HOURS \* 3600)

# Iterate hours
ZHOUR_INI=$(date -d "$HOUR_INI" +%H)
ZDATE_INI=$(date -d "$DATE_INI" +%Y%m%d%H)
EPOCH_END=$(date -d "$DATE_END" +%s)
EPOCH_CURR=$(date -d "$DATE_INI" +%s)
i=0
while [ $EPOCH_CURR -le $EPOCH_END ]
do
	# Date
	DATE_CURR=$(date -d @$EPOCH_CURR +%Y%m%d%H)
	HOUR_CURR=$(date -d @$EPOCH_CURR +%H)
	echo "Curr: $DATE_CURR"

	# Download file
	p=`printf "%03i" $i`
	wget -O GRIB${DATE_CURR} "http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?file=gfs.t${ZHOUR_INI}""z.pgrb2.0p25.f$p&all_lev=on&all_var=on&subregion=&leftlon=${LEFT_LON}&rightlon=${RIGHT_LON}&toplat=${TOP_LAT}&bottomlat=${BOTTOM_LAT}&dir=%2Fgfs.${ZDATE_INI}"

	# Increase 3 hours
	let EPOCH_CURR=$(date -d @$EPOCH_CURR +%s)+$DELTA_SEC
	let "i=$i+$DELTA_HOURS"
done

exit 0

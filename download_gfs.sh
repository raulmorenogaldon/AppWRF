#!/bin/sh

# Delta hours
DELTA_HOURS=6
DELTA_SEC=$(expr $DELTA_HOURS \* 3600)

# Iterate hours
EPOCH_END=$CFG_END_DATE
EPOCH_CURR=$CFG_START_DATE
i=0
while [ $EPOCH_CURR -le $EPOCH_END  ]
do
	# Date
	YEAR_CURR=$(date -d @$EPOCH_CURR +%Y)
	MONTH_CURR=$(date -d @$EPOCH_CURR +%m)
	DAY_CURR=$(date -d @$EPOCH_CURR +%d)
	HOUR_CURR=$(date -d @$EPOCH_CURR +%H)
	DATE_CURR=$(date -d @$EPOCH_CURR +%Y%m%d)
	echo "Curr: $DATE_CURR"

	# Download files
	wget -nv -O GRIB${DATE_CURR}${HOUR_CURR}_00 "ftp://nomads.ncdc.noaa.gov/GFS/analysis_only/${YEAR_CURR}${MONTH_CURR}/${YEAR_CURR}${MONTH_CURR}${DAY_CURR}/gfsanl_4_${DATE_CURR}_${HOUR_CURR}00_000.grb2" &
	wget -nv -O GRIB${DATE_CURR}${HOUR_CURR}_03 "ftp://nomads.ncdc.noaa.gov/GFS/analysis_only/${YEAR_CURR}${MONTH_CURR}/${YEAR_CURR}${MONTH_CURR}${DAY_CURR}/gfsanl_4_${DATE_CURR}_${HOUR_CURR}00_003.grb2" &
	wget -nv -O GRIB${DATE_CURR}${HOUR_CURR}_06 "ftp://nomads.ncdc.noaa.gov/GFS/analysis_only/${YEAR_CURR}${MONTH_CURR}/${YEAR_CURR}${MONTH_CURR}${DAY_CURR}/gfsanl_4_${DATE_CURR}_${HOUR_CURR}00_006.grb2" &

	# Wait downloads
	wait %1 %2 %3

	# Increase DELTA hours
	let EPOCH_CURR=$(date -d @$EPOCH_CURR +%s)+$DELTA_SEC
	let "i=$i+$DELTA_HOURS"
done

exit 0

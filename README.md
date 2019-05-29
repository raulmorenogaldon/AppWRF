# AppWRF #

These files are used to adapt the Weather Research and Forecasting Model [WRF](https://www.mmm.ucar.edu/weather-research-and-forecasting-model) to be used with a Scife system. The system has been tested with WRF [v3.9.1](http://www2.mmm.ucar.edu/wrf/users/wrfv3.9/updates-3.9.1.html).

## Usage and installation ##

* Download a copy of WRF software from its webpage and extract on a target folder.
* Overwrite the WRF files on the target folder with the files of this project.
* Use Scife to create the application with the contents of the target folder, e.g. using the `create_application` command of Scife's CLI. The compilation script must be set to `compile_wrf.sh` and the execution script must be set to `execute_wrf.sh`.

## Input data ##

WRF needs the geographic input data to work:

* Get the ID of the WRF application in Scife.
* Download the [geographic data](http://www2.mmm.ucar.edu/wrf/users/download/get_sources_wps_geog.html).
* Copy the input data (tar.gz) to the input folder with the ID of the WRF application.

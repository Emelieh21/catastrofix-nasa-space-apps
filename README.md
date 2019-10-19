# CatastroFix

### By Team _Space Cake_

_A project by Emelie Hofland and Jaime González-Arintero for the [NASA Space Apps Challenge Hackathon 2019](https://2019.spaceappschallenge.org/locations/berlin-germany/) in Berlin, on October 18-20, 2019._

## Introduction

Smashing SDGs by automatically matching places that need help with people that can help them.

## Presentation

WIP

## Solution Architecture

WIP

![](assets/catastrofix-solution-architecture.png)

## Data sets

**NOTE:** Some of the following data sets have been **converted from [ESRI ASCII raster format](http://resources.esri.com/help/9.3/arcgisengine/java/GP_ToolRef/spatial_analyst_tools/esri_ascii_raster_format.htm) to [shapefiles](https://en.wikipedia.org/wiki/Shapefile)**. A detailed explanation of the conversion procedure can be found in the [next section](https://github.com/Emelieh21/catastrofix-nasa-space-apps#esri-ascii-raster-to-shapefile-conversion).

### Global earthquake mortality risks and distribution

* Converted data set (in this repository): [`data/gdpgamrt-earthquake`](data/gdpgamrt-earthquake)
* Raw source: [NASA SEDAC, Columbia University](https://sedac.ciesin.columbia.edu/data/set/ndh-earthquake-mortality-risks-distribution)

### Global drought mortality risks and distribution

* Converted data set (in this repository): [`data/gddrgmrt-drought`](data/gddrgmrt-drought)
* Raw source: [NASA SEDAC, Columbia University](https://sedac.ciesin.columbia.edu/data/set/ndh-drought-mortality-risks-distribution)

### Global flood mortality risks and distribution

* Converted data set (in this repository): [`data/gdfldmrt-flood`](data/gdfldmrt-flood)
* Raw source: [NASA SEDAC, Columbia University](https://sedac.ciesin.columbia.edu/data/set/ndh-flood-mortality-risks-distribution)

### Global landslide mortality risks and distribution

* Converted data set (in this repository): [`data/gdlndmrt-landslide`](data/gdlndmrt-landslide)
* Raw source: [NASA SEDAC, Columbia University](https://sedac.ciesin.columbia.edu/data/set/ndh-landslide-mortality-risks-distribution)

### Global cyclone mortality risks and distribution

* Converted data set (in this repository): [`data/gdcycmrt-cyclone`](data/gdcycmrt-cyclone)
* Raw source: [NASA SEDAC, Columbia University](https://sedac.ciesin.columbia.edu/data/set/ndh-cyclone-mortality-risks-distribution)

### Subnational human development index

* Data set (in this repository): [`data/GDL-SHDI-SHP-2-human-development-index`](data/GDL-SHDI-SHP-2-human-development-index)
* Raw source: [Global Data Lab, Institute for Management Research, Radboud University](https://globaldatalab.org/shdi/shapefiles/)

### Global rural-urban mapping (human settlements)

* Data set (in this repository): [`data/gl_grumpv1_ppoints_shp-settlements`](data/gl_grumpv1_ppoints_shp-settlements)
* Raw source: [NASA SEDAC, Columbia University](https://sedac.ciesin.columbia.edu/data/collection/grump-v1)

### Database of universities and technical institutes

A [minimal database](assets/db-universities-and-tech-institutes.csv) has been created so the application can match the areas at risk with the potential help sources. **Such database has been compiled as a `.csv` file, and includes some universities and institutes of technology from all over the world.** Although the names, addresses and specialities are real, **the contact persons and their titles are fictional** (for privacy reasons).

The columns `drought`, `flood`, `hunger.medical` and `natural.disasters` indicate if each institution could effectively provide assistance in those emergency situations. For example, a `TRUE` in `hunger.medical` would mean that the institution in particular can support population suffering from hunger and/or in need of medical assistance. However, a `FALSE` in `flood` would mean that the institution doesn't count with enough resources or the right speciality to support flooded areas.

## ESRI ASCII raster to shapefile conversion

**ATTENTION: Although all commands work, this section is a work in progress and still needs to be reviewed.**

Download Miniconda.

Install Miniconda:

    sh Miniconda3-latest-MacOSX-x86_64.sh

Close and reopen the terminal.

Install `gdal`:

    conda install -c conda-forge gdal

Create Conda environment:

    conda create --yes --channel conda-forge --name TEST gdal

Activate it:

    conda activate TEST

Import `gdal` in Python:

    python -c 'import gdal;print(dir(gdal))'

Invoke `gdal` to convert ESRI ASCII rasters to shapefiles:

    gdal_polygonize.py -f "ESRI Shapefile" input-esri-ascii.asc output-shapefile.shp

## Technical setup

WIP

### R/Shiny application

WIP

## To do

* Everything.
* Solution architecture.
* Add hunger dataset to the docs.
* Document the R/Shiny application.
* Clean up the data conversion section.

## License

Copyright (C) 2019 Emelie Hofland <emelie_hofland@hotmail.com>, Jaime González-Arintero <a.lie.called.life@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
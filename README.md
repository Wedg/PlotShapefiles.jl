PlotShapefiles.jl
=================

A package to plot shapefiles with Julia.

The package started by copying the method shared by Keno Fischer [here](http://nbviewer.jupyter.org/github/JuliaX/iap2014/blob/master/GeoData.ipynb) and then extended to catering for each of the different types of shapefile (polygons, polylines, points, multipoints and their variants but does not currently support the Multipatch type) as well as overlaying the image onto a Google map.

There are three main functions - with methods described in the demo:
- plotshape() - for basic plotting of each type of shapefiles as well as layering different shapefile plots
- choropleth() - for plotting a choropleth with polygon shapefiles
- google_overlay() - for overlaying the shape plot onto a Google map image fetched from their static map API

## Demo / Documentation

A detailed demo describing the functionality and creating the example images below is available:  
1. [here as an html](http://htmlpreview.github.com/?https://github.com/Wedg/PlotShapefiles.jl/blob/master/demo/PlotShapefiles_Demo1.html) file, or  
2. [here as an ipynb file](demo/PlotShapefiles_Demo1.ipynb) that you can run in Jupyter (all the files needed are contained in the repository)

## Examples of outputs.
![](demo/mexico_shp1.png)
![](demo/mexico_shp2.png)
![](demo/mexico_ch1.png)
![](demo/mexico_google.png)


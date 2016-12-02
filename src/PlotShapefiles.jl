module PlotShapefiles

##############################################################################
##
## Dependencies and Reexports
##
##############################################################################

using Reexport
@reexport using Shapefile
@reexport using Measures
@reexport using Compose
@reexport using Images
@reexport using Colors
import Cairo
import FixedPointNumbers

import Base.identity

##############################################################################
##
## Exported methods and types
##
##############################################################################

export open_shapefile,
       lonlat_to_webmercator, identity,
       plotshape,
       choropleth,
       google_overlay, #CairoARGBSurface,
       rootpath, testdatapath

##############################################################################
##
## Load source files
##
##############################################################################

include("utils.jl")
include("coordinate_conversions.jl")
include("shp_point.jl")
include("shp_multipoint.jl")
include("shp_polygon.jl")
include("shp_polyline.jl")
include("plotshape.jl")
include("choropleth.jl")
include("google_overlay.jl")

end # module

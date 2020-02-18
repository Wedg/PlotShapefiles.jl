module PlotShapefiles

##############################################################################
##
## Dependencies and Reexports
##
##############################################################################

using Reexport
@reexport using Shapefile
@reexport using Compose
@reexport using Measures
@reexport using Colors
@reexport using Images
using Cairo: CairoARGBSurface
using FixedPointNumbers: Normed
using Missings

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

include("coordinate_conversions.jl")
include("shp_point.jl")
include("shp_multipoint.jl")
include("shp_polygon.jl")
include("shp_polyline.jl")
include("utils.jl")
include("plotshape.jl")
include("choropleth.jl")
include("google_overlay.jl")

end # module

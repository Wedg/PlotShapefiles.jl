####################
#
# Multipoint
#
####################

# Union of Shapefile MultiPoint types
ShpMultiPoint = Union{Shapefile.MultiPoint, Shapefile.MultiPointZ, Shapefile.MultiPointM}

# Plot an array of multipoints
function draw_shp{T<:ShpMultiPoint}(shapes::AbstractArray{T, 1}, canvas, convertcoords, line_width, line_color, fill_color, radius)
    for multipoint in shapes
        canvas = draw_shp(multipoint.points, canvas, convertcoords, line_width, line_color, fill_color, radius)
    end
    canvas
end

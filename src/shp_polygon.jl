####################
#
# Polygon
#
####################

# Union of Shapefile Polygon types
ShpPolygon = Union{Shapefile.Polygon, Shapefile.PolygonZ, Shapefile.PolygonM}

#=
For an array of ESRIShape points
1. convert to a different coordinate system (optional)
2. convert to a Compose polygon

Note:
Units in Compose can be either:
- Context - cx, cy - using the axis coordinates
- Relative - w (width), h (height) - using the size of the image
- Absolute - pt, mm, cm, inch
If you just provide numbers e.g. if pts below was an array of tuples of Float64
the units would default to context units.
=#
function ESRItoComposePolygon(points::AbstractArray{T, 1},
                              convertcoords) where {T<:ShpPoint}
    pts = Array{Tuple{Measures.Length{:cx, Float64}, Measures.Length{:cy, Float64}}}(undef, 0)
    for pt in points
        x, y = convertcoords(pt.x, pt.y)
        push!(pts, (x*cx, y*cy))
    end
    Compose.polygon(pts)
end

# Plot a single part polygon
function compose_single(polygon::T, canvas, convertcoords, line_width,
                        line_color, fill_color) where {T<:ShpPolygon}
    compose(canvas, (context(), ESRItoComposePolygon(polygon.points, convertcoords),
                     linewidth(line_width), stroke(line_color), fill(fill_color)))
end

# Plot a multi part polygon
function compose_multi(polygon::T, canvas, convertcoords, line_width,
                       line_color, fill_color) where {T<:ShpPolygon}
    start = 1
    finish = length(polygon.points)
    for idx in polygon.parts[2:end]
        canvas = compose(canvas, (context(),
                                  ESRItoComposePolygon(polygon.points[start:idx], convertcoords),
                                  linewidth(line_width), stroke(line_color), fill(fill_color)))
        start = idx + 1
    end
    canvas = compose(canvas, (context(),
                              ESRItoComposePolygon(polygon.points[start:finish], convertcoords),
                              linewidth(line_width), stroke(line_color), fill(fill_color)))
end

# Plot an array of polygons
function draw_shp(shapes::AbstractArray{T, 1}, canvas, convertcoords,
                  line_width, line_color, fill_color, radius) where {T<:ShpPolygon}
    for polygon in shapes
        if length(polygon.parts) == 1
            canvas = compose_single(polygon, canvas, convertcoords, line_width, line_color,
                                    fill_color)
        else
            canvas = compose_multi(polygon, canvas, convertcoords, line_width, line_color,
                                   fill_color)
        end
    end
    canvas
end

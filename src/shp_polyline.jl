####################
#
# Polyline
#
####################

# Union of Shapefile Polyline types
ShpPolyline = Union{Shapefile.Polyline, Shapefile.PolylineZ, Shapefile.PolylineM}

#=
For an array of ESRIShape points
1. convert to a different coordinate system (optional)
2. convert to a Compose line

Note:
Units in Compose can be either:
- Context - cx, cy - using the axis coordinates
- Relative - w (width), h (height) - using the size of the image
- Absolute - pt, mm, cm, inch
If you just provide numbers e.g. if pts below was an array of tuples of Float64
the units would default to context units.
=#
function ESRItoComposeLine(points::AbstractArray{T, 1},
                           convertcoords) where {T<:ShpPoint}
    pts = Array{Tuple{Measures.Length{:cx, Float64}, Measures.Length{:cy, Float64}}}(undef, 0)
    for pt in points
        x, y = convertcoords(pt.x, pt.y)
        push!(pts, (x*cx, y*cy))
    end
    Compose.line(pts)
end

# Plot a single part polyline
function compose_single(polyline::T, canvas, convertcoords, line_width,
                        line_color) where {T<:ShpPolyline}
    compose(canvas, (context(), ESRItoComposeLine(polyline.points, convertcoords),
                     linewidth(line_width), stroke(line_color)))
end

# Plot a multi part polyline
function compose_multi(polyline::T, canvas, convertcoords, line_width,
                       line_color) where {T<:ShpPolyline}
    start = 1
    finish = length(polyline.points)
    for idx in polyline.parts[2:end]
        canvas = compose(canvas, (context(),
                                  ESRItoComposeLine(polyline.points[start:idx], convertcoords),
                                  linewidth(line_width), stroke(line_color)))
        start = idx + 1
    end
    canvas = compose(canvas, (context(),
                              ESRItoComposeLine(polyline.points[start:finish], convertcoords),
                              linewidth(line_width), stroke(line_color)))
end

# Plot an array of polylines
function draw_shp(shapes::AbstractArray{T, 1}, canvas, convertcoords,
                  line_width, line_color, fill_color,
                  radius) where {T<:ShpPolyline}
    for polyline in shapes
        if length(polyline.parts) == 1
            canvas = compose_single(polyline, canvas, convertcoords, line_width, line_color)
        else
            canvas = compose_multi(polyline, canvas, convertcoords, line_width, line_color)
        end
    end
    canvas
end

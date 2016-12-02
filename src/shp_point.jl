####################
#
# Point
#
####################

# Union of Shapefile Point types
ShpPoint = Union{Shapefile.Point, Shapefile.PointZ, Shapefile.PointM}

#=
For an array of ESRIShape points ???
1. convert to a different coordinate system (optional)
2. convert to a Compose circle

Note:
Units in Compose can be either:
- Context - cx, cy - using the axis coordinates
- Relative - w (width), h (height) - using the size of the image
- Absolute - pt, mm, cm, inch
If you just provide numbers e.g. if x_pts below was an array of Float64
the units would default to context units.
=#
function ESRItoComposeCircle(points::Vector{Shapefile.Point{Float64}}, convertcoords, radius)
    x_pts = Array(Measures.Length{:cx, Float64}, 0)
    y_pts = Array(Measures.Length{:cy, Float64}, 0)
    for pt in points
        x, y = convertcoords(pt.x, pt.y)
        push!(x_pts, x*cx)
        push!(y_pts, y*cy)
    end
    Compose.circle(x_pts, y_pts, radius)
end

# Plot an array of points
function draw_shp{T<:ShpPoint}(shapes::AbstractArray{T, 1}, canvas, convertcoords, line_width, line_color, fill_color, radius)
    compose(canvas, (context(), ESRItoComposeCircle(shapes, convertcoords, radius),
                     linewidth(line_width), stroke(line_color), fill(fill_color)))
end

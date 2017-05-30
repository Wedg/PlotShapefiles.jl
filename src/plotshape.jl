####################
#
# Plot Shapefile
#
####################

# Shapefile Abstract
AbstractGeom = Shapefile.GeoInterface.AbstractGeometry

# Plot Shapefile - given array of shapes and a canvas
function plotshape{T<:AbstractGeom}(shparray::AbstractArray{T, 1},
                   canvas::Compose.Context;
                   convertcoords=lonlat_to_webmercator, img_width=12cm,
                   line_width=0.05mm, line_color="black", fill_color=nothing,
                   radius=[0.5cm])

    # Plot and return canvas
    draw_shp(shparray, canvas, convertcoords, line_width, line_color, fill_color, radius)

end

# Plot Shapefile - given array of shapes and an MBR
function plotshape{T<:AbstractGeom}(shparray::AbstractArray{T, 1},
                   MBR::Shapefile.Rect{Float64};
                   convertcoords=lonlat_to_webmercator, img_width=12cm, options...)

    # Create canvas
    canvas = create_canvas(MBR, convertcoords, img_width)

    # Plot
    plotshape(shparray, canvas,
              convertcoords=convertcoords, img_width=img_width; options...)

end

# Plot Shapefile - given an array of shapes
function plotshape{T<:AbstractGeom}(shparray::AbstractArray{T, 1};
                   options...)

    # Create MBR
    MBR = minBR(shparray)

    # Plot
    plotshape(shparray, MBR; options...)
end

# Plot Shapefile - given the Shapefile Handle
function plotshape(shp::Shapefile.Handle; options...)
    plotshape(shp.shapes, shp.MBR; options...)
end

# Plot Shapefile - given the Shapefile Handle and an MBR
function plotshape(shp::Shapefile.Handle, MBR::Shapefile.Rect{Float64}; options...)
    plotshape(shp.shapes, MBR; options...)
end

# Plot Shapefile - given the Shapefile Handle and a canvas
function plotshape(shp::Shapefile.Handle, canvas::Compose.Context; options...)
    plotshape(shp.shapes, canvas; options...)
end

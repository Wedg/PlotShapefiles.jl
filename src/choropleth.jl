####################
#
# Choropleth Plot
#
####################

# Plot choropleth  - given array of shapes and a canvas
function choropleth(shparray::Union{AbstractArray{T, 1}, AbstractArray{Union{Missing, T},1}},
                    canvas::Compose.Context, fill_data, fill_color_map;
                    convertcoords=lonlat_to_webmercator, img_width=12cm,
                    line_width=0.05mm, line_color="black",
                    transform=identity) where {T<:Shapefile.GeoInterface.AbstractGeometry}

    # Check for missings
    try
        shparray = disallowmissing(shparray)
    catch
        error("Error: Shape array contains missing values")
    end

    # This method is only for polygons
    @assert typeof(shparray[1]) <: ShpPolygon

    # Colours
    n_colors = length(fill_color_map)
    minval = transform(minimum(fill_data))
    maxval = transform(maximum(fill_data))
    range = maxval - minval

    # Plot outlines to canvas
    i = 1
    for polygon in shparray
        val = transform(Float64(isnan(fill_data[i]) ? 0.0 : fill_data[i]))  # CHECK CHANGE FROM ISNA TO ISNAN !!!
        i += 1
        normval = (val - minval) / range
        color_idx = round(Int, normval * (n_colors - 1) + 1)
        if length(polygon.parts) == 1
            canvas = compose_single(polygon, canvas, convertcoords, line_width, line_color, fill_color_map[color_idx])
        else
            canvas = compose_multi(polygon, canvas, convertcoords, line_width, line_color, fill_color_map[color_idx])
        end
    end

    # Return canvas
    canvas
end

# Plot choropleth - given array of shapes and an MBR
function choropleth(shparray::Union{AbstractArray{T, 1}, AbstractArray{Union{Missing, T},1}},
                    MBR::Shapefile.Rect,
                    fill_data, fill_color_map;
                    convertcoords=lonlat_to_webmercator, img_width=12cm,
                    options...) where {T<:Shapefile.GeoInterface.AbstractGeometry}

    # Check for missings
    try
        shparray = disallowmissing(shparray)
    catch
        error("Error: Shape array contains missing values")
    end

    # Create canvas
    canvas = create_canvas(MBR, convertcoords, img_width)

    # Plot
    choropleth(shparray, canvas, fill_data, fill_color_map,
               convertcoords=convertcoords, img_width=img_width; options...)
end

# Plot choropleth - given an array of shapes
function choropleth(shparray::Union{AbstractArray{T, 1}, AbstractArray{Union{Missing, T},1}},
                    fill_data, fill_color_map;
                    options...) where {T<:Shapefile.GeoInterface.AbstractGeometry}

    # Check for missings
    try
        shparray = disallowmissing(shparray)
    catch
        error("Error: Shape array contains missing values")
    end

    # Create MBR
    MBR = minBR(shparray)

    # Plot
    choropleth(shparray, MBR, fill_data, fill_color_map; options...)
end

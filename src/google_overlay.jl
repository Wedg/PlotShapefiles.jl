#=
This is the main function that does the google overlay.
Uses the various functions below to:
    1. Work out the Lon | Lat coordinates from the bounding box
    2. Use those coordinates and the zoom to calc the inputs for
       the Googe API - center and size
    3. Calls the Google API with calculated and user provided Inputs
    4. Saves that to a temp picture
    5. Overlays the canvas with the Google image
=#
function google_overlay(canvas::Compose.Context, key::String, zoom::Int;
                        scale::Int=1, maptype::String=roadmap)

    # Get MBR from the canvas units
    MBR = canvas_to_MBR(canvas::Compose.Context)

    # Coordinates from the MBR
    cxEast, cyNorth, cxWest, cySouth = MBR.right, MBR.bottom, MBR.left, MBR.top

    # Use coordinates to get Google API parameters
    mid_Lon, mid_Lat, p_width, p_height = bbox_coords_and_zoom_to_center_and_size(cxEast, cyNorth, cxWest, cySouth, zoom)

    # Build a dictionary of the google options for the API call
    options = Dict(
    :center => "$(mid_Lat),$(mid_Lon)",
    :zoom => "$zoom",
    :size => "$(p_width)x$(p_height)",
    :scale => "$scale",
    :maptype => maptype,
    :key => key)

    # Fetch the Google map image
    google_img = load_google_image(options)

    # Overlay the canvas onto the Google map image
    overlay(canvas, google_img)
end

#=
Takes the Compose.Context canvas bounding box and converts the units back to
longitude and lattitude to use in fetching the right image from Google.
=#
function canvas_to_MBR(canvas::Compose.Context)

    # From UnitBox
    left = canvas.units.value.x0
    bottom = canvas.units.value.y0
    width = canvas.units.value.width
    height = canvas.units.value.height
    right = left + width
    top = bottom + height

    # Convert back to longitude and lattitude
    left, top = webmercator_to_lonlat(left, top)
    right, bottom = webmercator_to_lonlat(right, bottom)

    # Create an MBR
    Shapefile.Rect(top, left, bottom, right)
end

function bbox_coords_and_zoom_to_center_and_size(cxEast, cyNorth, cxWest, cySouth, zoom)

    # Convert Lon and Lat to pixel numbers
    pxEast, pyNorth = lonlat_to_pixels(cxEast, cyNorth, zoom)
    pxWest, pySouth = lonlat_to_pixels(cxWest, cySouth, zoom)

    # Calculate image size in pixels
    width = pxEast - pxWest
    height = pySouth - pyNorth

    # Google has max size of 640x640 so give error if choice exceeds this
    (width > 640 || height > 640) &&
    throw("Bounds Error - Google sets 640 as the upper limit on the width and height. Select a lower zoom.")

    # Calculate centre point in pixels
    mid_px = (pxEast + pxWest) / 2
    mid_py = (pyNorth + pySouth) / 2

    # Convert center coordinates to Lon/Lat
    mid_cxLon, mid_cyLat = pixels_to_lonlat(mid_px, mid_py, zoom)

    # Return center x, center y, width and height - these are used in the google API call
    mid_cxLon, mid_cyLat, ceil(Int, width), ceil(Int, height)
end

# Fetch the image from the Google static ... API
function load_google_image(params::Dict)
    img = load(fetch_google_image("temp_google_api_img.png", params))
end
function fetch_google_image(save_path::AbstractString, params::Dict)
    download(google_staticmap_url(params), save_path)
end

# Build the url string to be used in the Google API
# Inputs are the options ...
function google_staticmap_url(params::Dict)
    url = "https://maps.googleapis.com/maps/api/staticmap?"
    for (key, value) in params
        url *= "$key=$value"
        url *= "&"
    end
    return url[1:end-1]
end

#=
Overlays the shape plot canvas onto the Google image.
The transparency in the color used in the shape plot is used.
=#
function overlay(shape_plot, google_img)

    # Image dimensions
    width, height = size(google_img)

    # Create Cairo surface, draw polygon to surface, reinterpret as an array of RGB fixed point numbers
    surface = Cairo.CairoARGBSurface(zeros(UInt32, height, width))
    draw(PNG(surface), shape_plot)
    overlay = reinterpret(BGRA{FixedPointNumbers.UFixed{UInt8, 8}}, surface.data)

    # Create combined image
    outimg = similar(google_img)
    for i=1:width, j=1:height

        # Transparency value at pixel i,j
        α = overlay[i,j].alpha

        # Convert pixel value to same element type (RGB of FixedPointNumbers) as the image
        overlay_pixel = convert(eltype(google_img), overlay[i,j])

        # Merge the two pixels - weighting determined by the transparency
        β = one(α) - α
        outimg[i,j] = β*google_img[i,j] + α*overlay_pixel
    end

    # Return the combined image
    return outimg
end

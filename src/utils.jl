####################
#
# Utils
#
####################

# Open a shapefile
function open_shapefile(location::AbstractString)
    shp = open(location) do fd
        read(fd, Shapefile.Handle)
    end
    shp
end

#=
Create a canvas to draw on
The correspondence of Compose.UnitBox fields to the Shapefile.Rect fields are as follows:
x0 := left, y0 := top, width := right-left, height := -(top-bottom)
The UnitBox typically has origin at top left and moves down and right (an image convention).
To change to the convention of having the origin at the bottom left we use a negative height.
=#
function create_canvas(MBR::Shapefile.Rect{Float64}, convertcoords, img_width)

    # Coordinate conversion
    left, top = convertcoords(MBR.left, MBR.top)
    right, bottom = convertcoords(MBR.right, MBR.bottom)

    # Canvas size
    width, height = right - left, top - bottom
    ratio = width / height
    Compose.set_default_graphic_size(img_width, img_width/ratio)

    # Dimensions of canvas
    # Add 5% padding on border (TODO - make padding a parameter)
    left -= width * 0.05
    width *= 1.1
    top += height * 0.05
    height *= 1.1
    dims = Compose.UnitBox(left, top, width, -height)

    # Return blank canvas
    return context(units = dims)
end

# Calculate a minimum bounding rectangle from a selection of shapes
# Useful for drawing a subset of shapes and not using the "global" MBR
function minBR(shapes::AbstractArray{T, 1}) where {T<:Shapefile.GeoInterface.AbstractGeometry}
    box = shapes[1].MBR
    for i = 2:length(shapes)
        (shapes[i].MBR.top > box.top) && (box.top = shapes[i].MBR.top)
        (shapes[i].MBR.left < box.left) && (box.left = shapes[i].MBR.left)
        (shapes[i].MBR.bottom < box.bottom) && (box.bottom = shapes[i].MBR.bottom)
        (shapes[i].MBR.right > box.right) && (box.right = shapes[i].MBR.right)
    end
    return box
end

# Calculate a minimum bounding rectangle from a selection of points
# Point types don't have field MBR so need it's own method
function minBR(shapes::AbstractArray{T, 1}) where {T<:ShpPoint}
    box = Shapefile.Rect(shapes[1].y, shapes[1].x, shapes[1].y, shapes[1].x)
    for i = 2:length(shapes)
        (shapes[i].y > box.top) && (box.top = shapes[i].y)
        (shapes[i].x < box.left) && (box.left = shapes[i].x)
        (shapes[i].y < box.bottom) && (box.bottom = shapes[i].y)
        (shapes[i].x > box.right) && (box.right = shapes[i].x)
    end
    return box
end

# Convert shapes from Abstract Type Array{ESRIShape, 1} to concrete type
# No longer needed after changes to Shapefile.jl package
#=
function concrete{T<:Shapefile.GeoInterface.AbstractGeometry}(shapes::AbstractArray{T, 1})
    convert(Array{typeof(shapes[1]), 1}, shapes)
end
=#

# Root and dataset paths
rootpath = dirname(@__FILE__)[1:end-4]
testdatapath = joinpath(rootpath, "test", "testdata")

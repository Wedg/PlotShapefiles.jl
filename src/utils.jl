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
Note: The mapping of the shape file bounding box elements to the MBR fields are:
Xmin->left, Ymin->top, Xmax->right, Ymax->bottom
The reason the y-coordinate is flipped is - I think - to help with Compose where
an image has top left as the origin.
The Compose.UnitBox type has the following fields that are created as follows:
x0 := left/Xmin, y0 := bottom/Ymax, width := right-left/Xmax-Xmin, height:=bottom-top/Ymax-Ymin
=#
function create_canvas(MBR::Shapefile.Rect{Float64}, convertcoords, img_width)

    # Coordinate conversion
    left, top = convertcoords(MBR.left, MBR.top)
    right, bottom = convertcoords(MBR.right, MBR.bottom)

    # Canvas size
    width, height = right-left, bottom-top
    ratio = width / height
    Compose.set_default_graphic_size(img_width, img_width/ratio)

    # Dimensions of canvas
    # Could also include padding here if needed
    dims = UnitBox(left, bottom, width, -height)

    # Return blank canvas
    return context(units=dims)
end

# Calculate a minimum bounding rectangle from a selection of shapes
# Useful for drawing a subset of shapes and not using the "global" MBR
function minBR(shapes::AbstractArray{T, 1}) where {T<:Shapefile.GeoInterface.AbstractGeometry}
    box = shapes[1].MBR
    for i = 2:length(shapes)
        (shapes[i].MBR.top < box.top) && (box.top = shapes[i].MBR.top)
        (shapes[i].MBR.left < box.left) && (box.left = shapes[i].MBR.left)
        (shapes[i].MBR.bottom > box.bottom) && (box.bottom = shapes[i].MBR.bottom)
        (shapes[i].MBR.right > box.right) && (box.right = shapes[i].MBR.right)
    end
    return box
end

# Point types don't have field MBR so need it's own method
function minBR(shapes::AbstractArray{T, 1}) where {T<:ShpPoint}
    box = Shapefile.Rect(shapes[1].y, shapes[1].x, shapes[1].y, shapes[1].x)
    for i = 2:length(shapes)
        (shapes[i].y < box.top) && (box.top = shapes[i].y)
        (shapes[i].x < box.left) && (box.left = shapes[i].x)
        (shapes[i].y > box.bottom) && (box.bottom = shapes[i].y)
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

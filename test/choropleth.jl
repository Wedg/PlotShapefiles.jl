# Load the shape file
mexicopath = joinpath(testdatapath, "shape_eg_data", "mexico")
states = open_shapefile(joinpath(mexicopath, "states.shp"))

# Create plots and test whether they output a Compose.Context (i.e. check if they run)

# Create choropleth with random colors and test that it returns a Compose.Context type
num_shapes = length(states.shapes)
canvas = choropleth(states.shapes, rand(num_shapes), colormap("blues"), transform=log)
test = (typeof(canvas) == Compose.Context)

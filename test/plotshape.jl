# Load the shape files
mexicopath = joinpath(testdatapath, "shape_eg_data", "mexico")
states = open_shapefile(joinpath(mexicopath, "states.shp"))
cities = open_shapefile(joinpath(mexicopath, "cities.shp"))
rivers = open_shapefile(joinpath(mexicopath, "rivers.shp"))

# Create plots and test whether they output a Compose.Context (i.e. check if they run)

# Test polygon
canvas1 = plotshape(states)
test1 = (typeof(canvas) == Compose.Context)

# Test point
canvas2 = plotshape(cities, canvas1, line_width=0.25mm, line_color="red", fill_color=RGB(1,1,0), radius=[0.05cm])
test2 = (typeof(canvas2) == Compose.Context)

# Test polyline
canvas3 = plotshape(rivers, canvas2, line_color=RGB(0.2,0.6,0.8), line_width=0.25mm)
test3 = (typeof(canvas3) == Compose.Context)

# Return
test1 && test2 && test3

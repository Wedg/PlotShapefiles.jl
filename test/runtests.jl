#Start Test Script
using PlotShapefiles
using Base.Test

# Run tests

tic()
println("Test 1")
@time @test include("plotshape.jl")
println("Test 2")
@time @test include("choropleth.jl")
toc()

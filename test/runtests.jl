#Start Test Script
using PlotShapefiles
using Test

# Run tests

@time begin
    println("Test 1 ...")
    @time @test include("plotshape.jl")
    println("Test 2 ...")
    @time @test include("choropleth.jl")
end

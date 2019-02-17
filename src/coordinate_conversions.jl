####################
#
# Coordinate Conversions
#
####################

# Identity i.e. no change - use the given coordinates
identity(xLon, yLat) = Base.identity(xLon), Base.identity(yLat)

#=
Converts WGS84 coordinates to Web Mercator projection (without zoom level)
See:
http://earth-info.nga.mil/GandG/wgs84/web_mercator/(U)%20NGA_SIG_0011_1.0.0_WEBMERC.pdf
=#
function lonlat_to_webmercator(xLon, yLat)

    # Check coordinates are in range
    abs(xLon) <= 180 || throw("Maximum longitude is 180.")
    abs(yLat) < 85.051129 || throw("Web Mercator maximum lattitude is 85.051129. This is the lattitude at which the full map becomes a square.")

    # Ellipsoid semi-major axis for WGS84 (metres)
    # This is the equatorial radius - the Polar radius is 6356752.0
    a = 6378137.0

    # Convert to radians
    λ = xLon * 0.017453292519943295    # λ = xLon * π / 180
    ϕ = yLat * 0.017453292519943295    # ϕ = yLat * π / 180

    # Convert to Web Mercator
    # Note that:
    # atanh(sin(ϕ)) = log(tan(π/4 + ϕ/2)) = 1/2 * log((1 + sin(ϕ)) / (1 - sin(ϕ)))
    x = a * λ
    y = a * atanh(sin(ϕ))

    return x, y
end

#=
Inverse of the above function - converts back to longitude and lattitude coordinates
=#
function webmercator_to_lonlat(x, y)
    a = 6378137.0
    xLon = x / (a * 0.017453292519943295)
    yLat = asin(tanh(y / a)) / 0.017453292519943295
    return xLon, yLat
end

#=
Converts WGS84 coordinates to Web Mercator projection pixel numbers for use with
the Google API
=#
function lonlat_to_pixels(xLon, yLat, zoom)

    # Check coordinates are in range
    abs(xLon) <= 180 || throw("Maximum longitude is 180.")
    abs(yLat) < 85.051129 || throw("Web Mercator maximum lattitude is 85.051129. This is the lattitude at which the full map becomes a square.")

    # Convert to radians
    λ = xLon * 0.017453292519943295    # λ = xLon * π / 180
    ϕ = yLat * 0.017453292519943295    # ϕ = yLat * π / 180

    # Convert to Web Mercator projection pixel number
    # E.g. world coordinate range x ∈ (0,256) and y ∈ (0,256) at zoom level 0
    # Note that:
    # atanh(sin(ϕ)) = log(tan(π/4 + ϕ/2)) = 1/2 * log((1 + sin(ϕ)) / (1 - sin(ϕ)))
    # 256/2π = 40.74366543152521
    px = 40.74366543152521 * 2^zoom * (λ + π)
    py = 40.74366543152521 * 2^zoom * (π - atanh(sin(ϕ)))

    return px, py
end

#=
Returns WGS84 coordinates given the pixel numbers and zoom level
Note: This is the inverse of the above function - lonlat_to_pixels
=#
function pixels_to_lonlat(px, py, zoom)

    xLon = 180 * (px / (128 * 2^zoom) - 1)
    yLat = 180 / π * asin(tanh(π - py * π / (128 * 2^zoom)))

    return xLon, yLat
end

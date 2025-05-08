include("./modules/flux_heatmap.jl")

using .FluxPlot
using CairoMakie

fig = Figure(size=(1500, 800), fontsize=12)
lat = range(-180, stop=45, length=300)
lon = range(-120, stop=80, length=300)
alti = range(0, stop=81, length=9)

title = L"\mathrm{Angular\ integrated\ flux\ (/cm^2/s/(MeV/n))}"

plot_coordinate33!(fig, lat, lon, alti, title=title)

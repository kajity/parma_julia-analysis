using Revise
import Pkg
Pkg.develop(path="./ParmaAnalysis/")
using ParmaAnalysis

using CairoMakie


fig = Figure(size=(1500, 800), fontsize=12)
lat = range(-90, stop=90, length=300)
lon = range(-180, stop=180, length=300)
alti = range(0, stop=81, length=9)

title = L"\mathrm{Angular\ integrated\ flux\ (/cm^2/s/(MeV/n))}"

ParmaAnalysis.ip[] = 0
plot_coordinate!(fig, lat, lon, (3, 3), altitude=3., energy=(10., 90.), title=title)
# save("./figures/flux_coordinate.png", fig)
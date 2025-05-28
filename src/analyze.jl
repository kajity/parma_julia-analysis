using Revise
import Pkg
Pkg.develop(path="./ParmaAnalysis/")
using ParmaAnalysis

using CairoMakie

set_theme!(theme_latexfonts())

fig = Figure(size=(1500, 800), fontsize=12, fonts=(; regular="Dejavu", weird="Blackchancery"))
lat = range(-90, stop=90, length=300)
lon = range(-180, stop=180, length=300)
# alti = range(0, stop=81, length=9)
alti = range(0, stop=81, length=300)
energy = exp10.(range(-1.0, stop=3.0, length=9))

# title = L"\mathrm{angular\ integrated\ flux\ (neutron, 100 MeV)\ (/cm^2/s/(MeV/n))}"
title = L"\mathrm{angular\ integrated\ flux\ (proton, 20 km)\ (/cm^2/s/(MeV/n))}"

ParmaAnalysis.ip[] = 1

# plot_coordinate!(fig, lat, lon, (3, 3), altitude=alti, energy=100., title=title)
# plot_coordinate!(fig, lat, lon, (3, 3), altitude=alti, energy=100., title=title, colorscale=identity)
# plot_coordinate!(fig, lat, lon, (3, 3), altitude=20., energy=energy, title=title)
# plot_longalti!(fig, lon, alti, (3, 3), latitude=(-90., 90.), energy=10., title=title)
plot_latalti!(fig, lat, alti, (3, 3), longitude=(-180., 180.), energy=100., title=title, logscale=true)
# save("./figures/flux_coordinate_n_e100.png", fig)
# save("./figures/flux_coordinate_p_e100.png", fig)
save("./figures/flux_latalti_p_e100.png", fig)

fig


using Revise
import Pkg
Pkg.develop(path="./ParmaAnalysis/")
using ParmaAnalysis
using CairoMakie
using Printf

# func = :coordinate
func = :latalti
# func = :longalti

# target = :p  # Proton
# target = :n  # Neutron
# target = :e  # Electron
target = :photon  # Photon

lat = []
lon = []
alti = []
energy = []

if func == :coordinate
  lat = range(-90, stop=90, length=300)
  lon = range(-180, stop=180, length=300)
  alti = range(0, stop=81, length=9)
  energy = 0.1
  # alti = 20.0
  # energy = logrange(1e-1, 1e3, length=9)
elseif func == :latalti
  lat = range(-90, stop=90, length=300)
  alti  = range(0, stop=81, length=300)
  lon = range(-180, stop=180, length=9)
  energy = 0.1
elseif func == :longalti
  lon = range(-180, stop=180, length=300)
  alti = range(0, stop=81, length=300)
  lat = range(-90, stop=90, length=9)
  energy = 0.1
else
  error("Unsupported func: $func")
end

if (target == :n)
  ParmaAnalysis.ip[] = 0
elseif (target == :p)
  ParmaAnalysis.ip[] = 1
elseif (target == :e)
  ParmaAnalysis.ip[] = 31
elseif (target == :photon)
  ParmaAnalysis.ip[] = 33
else
  error("Unsupported target: $target")
end

set_theme!(theme_latexfonts())
fig = Figure(size=(1500, 800), fontsize=12, fonts=(; regular="Dejavu", weird="Blackchancery"))

# title = L"\mathrm{angular\ integrated\ flux\ (neutron, 100 MeV)\ (/cm^2/s/(MeV/n))}"
title = L"\mathrm{angular\ integrated\ flux\ (%$(ParmaAnalysis.ip_name()))\ (/cm^2/s/(MeV/n))}"


if func == :coordinate
  plot_coordinate!(fig, lat, lon, (3, 3), altitude=alti, energy=energy, title=title, logscale=true)
elseif func == :latalti
  plot_latalti!(fig, lat, alti, (3, 3), longitude=lon, energy=energy, title=title, logscale=true)
elseif func == :longalti
  plot_longalti!(fig, lon, alti, (3, 3), latitude=lat, energy=energy, title=title, logscale=true)
else
  error("Unsupported func: $func")
end

  isaltitudevector = alti isa AbstractVector
  axistitle = !isaltitudevector ? "a$(@sprintf("%.1f", alti))" : "e$(@sprintf("%.1f", energy))"
# save(joinpath(@__DIR__, "..", "figures", "flux_$(func)_$(target)_$(axistitle).png"), fig)
println("Title: $title")
fig

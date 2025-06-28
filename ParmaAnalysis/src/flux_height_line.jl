include("parma_wrapper.jl")
include("variables.jl")
include("utils.jl")

using CairoMakie
using GeoMakie
using LaTeXStrings
using LinearAlgebra
using Statistics
using Printf



function plot_energy!(ax, altitude, latitude, longitude; energy=10.0, label="", color=:auto,)
  s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)


  println("Plotting flux")

  flux = []
  for alti in altitude
    flux_mean = get_fluxmean(latitude, longitude, alti, energy, s)
    push!(flux, flux_mean)
  end

  # scatter!(ax, altitude, flux; color=color, label=label)
  lines!(ax, altitude, flux; color=color, linewidth=1.2, label=label)
  fig
end

energy = 10.
altitude = range(0., stop=80., length=1000)
longitude = range(-180, stop=180, length=30)
# latitude = range(-90, stop=90, length=30)
# latitude = range(80, stop=90, length=30)
latitude = range(-90, stop=-80, length=30)
# longitude = [-104.2]
# latitude = [30.0]

set_theme!(theme_latexfonts())
fig = Figure(size=(1000, 500), fontsize=12)
ax = Axis(fig[1, 1], title="",
  titlesize=14,
  yscale=log10,
  limits=(altitude[1], altitude[end], 10^-8, 10^0),
)

ip[] = 0
plot_energy!(ax, altitude, latitude, longitude; energy=energy, label="neutron", color=:blue)
ip[] = 1
plot_energy!(ax, altitude, latitude, longitude; energy=energy, label="proton", color=:red)
ip[] = 31
plot_energy!(ax, altitude, latitude, longitude; energy=energy, label="electron", color=:green)
ip[] = 33
plot_energy!(ax, altitude, latitude, longitude; energy=energy, label="photon", color=:orange)
ip[] = 29
plot_energy!(ax, altitude, latitude, longitude; energy=energy, label="muon+", color=:purple)

# situation = "whole_globe"
# situation = "north"
# situation = "south"
situation = "-100_30"

Legend(fig[:, 2], ax)
title = "Angular integrated flux $(situation) (altitude vs flux)"
Label(fig[0, :], title, fontsize=18)
Label(fig[end+1, :], L"\mathrm{altitude\ (km)}", fontsize=14)
Label(fig[:, 0], L"\mathrm{flux\ (/cm^2/s/(MeV/n))}", fontsize=14,
  rotation=π / 2)

# save("./figures/line_flux_altitude.png", fig)
# save("./figures/line_flux_altitude_511.png", fig)
# save("./figures/line_flux_altitude_whole_globe.png", fig)
# save("./figures/line_flux_altitude_north.png", fig)

save("./figures/line_flux_altitude_$(situation).pdf", fig)
fig
include("parmawrapper.jl")
include("variables.jl")
include("utils.jl")

using CairoMakie
using GeoMakie
using LaTeXStrings
using LinearAlgebra
using Statistics
using Printf


function plot_energy!(ax, energy; altitude=20.0, label="", color=:auto,)
  s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

  function get_fluxmean(lat, lon, alti, energy)
    flux_mat = @. getSpec(ip[], s, getr(lat', lon), getd(alti, lat'), energy, g[])
    mean(flux_mat)
  end

  longitude = range(-180, stop=180, length=30)
  latitude = range(-90, stop=90, length=30)
  flux = []
  println("Plotting flux")


  for e in energy
    flux_mean = get_fluxmean(latitude, longitude, altitude, e)
    push!(flux, flux_mean)
  end

  lines!(ax, energy, flux; color=color, linewidth=1.2, label=label)
  fig
end

energy = exp10.(range(-1.0, stop=3.0, length=300))

fig = Figure(size=(1000, 500), fontsize=12)
ax = Axis(fig[1, 1], title="",
  titlesize=14,
  xscale=log10,
  yscale=log10,
  limits=(energy[1], energy[end], 10^-6, 10^3),
)

ip[] = 0
plot_energy!(ax, energy; altitude=20.0, label="neutron", color=:blue)
ip[] = 1
plot_energy!(ax, energy; altitude=20.0, label="proton", color=:red)
ip[] = 31
plot_energy!(ax, energy; altitude=20.0, label="electron", color=:green)
ip[] = 33
plot_energy!(ax, energy; altitude=20.0, label="photon", color=:orange)
ip[] = 29
plot_energy!(ax, energy; altitude=20.0, label="muon+", color=:purple)

Legend(fig[:, 2], ax)
title = L"\mathrm{angular\ integrated\ flux}"
Label(fig[0, :], title, fontsize=18)
Label(fig[end + 1, :], L"\mathrm{energy\ (MeV/n)}", fontsize=14)
Label(fig[:, 0], L"\mathrm{flux\ (/cm^2/s/(MeV/n))}", fontsize=14, 
  rotation=π / 2)
save("./figures/line_flux_energy.png", fig)
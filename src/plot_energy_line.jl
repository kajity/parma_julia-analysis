using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using CairoMakie
using LaTeXStrings

energy = exp10.(range(-1.0, stop=3.0, length=300))
# energy = 500:0.05:520
# longitude = range(-180, stop=180, length=30)
# latitude = range(-90, stop=90, length=30)
# latitude = range(-90, stop=-80, length=30)
# latitude = range(-80, stop=90, length=30)
longitude = [-100.0]
latitude = [30.0]

set_theme!(theme_latexfonts())
fig = Figure(size=(1000, 500), fontsize=12)
ax = Axis(fig[1, 1], title="",
  titlesize=14,
  xscale=log10,
  yscale=log10,
  limits=(energy[1], energy[end], 10^-7, 10^3),
)

ParmaAnalysis.ip[] = 0
plot_energy_flux!(ax, energy, latitude, longitude; altitude=20.0, label="neutron", color=:blue)
ParmaAnalysis.ip[] = 1
plot_energy_flux!(ax, energy, latitude, longitude; altitude=20.0, label="proton", color=:red)
ParmaAnalysis.ip[] = 31
plot_energy_flux!(ax, energy, latitude, longitude; altitude=20.0, label="electron", color=:green)
ParmaAnalysis.ip[] = 33
plot_energy_flux!(ax, energy, latitude, longitude; altitude=20.0, label="photon", color=:orange)
ParmaAnalysis.ip[] = 29
plot_energy_flux!(ax, energy, latitude, longitude; altitude=20.0, label="muon+", color=:purple)

# situation = "whole_globe"
# situation = "511"
# situation = "south"
# situation = "north"
situation = "-100_30"

Legend(fig[:, 2], ax)
title = "Angular integrated flux $(situation) (energy vs flux)"
Label(fig[0, :], title, fontsize=18)
Label(fig[end+1, :], L"\mathrm{energy\ (MeV/n)}", fontsize=14)
Label(fig[:, 0], L"\mathrm{flux\ (/cm^2/s/(MeV/n))}", fontsize=14,
  rotation=π / 2)

# save("./figures/line_flux_energy.png", fig)
# save("./figures/line_flux_energy_511.png", fig)
# save("./figures/line_flux_energy_whole_globe.png", fig)
# save("./figures/line_flux_energy_north.png", fig)

# save("./figures/line_flux_energy_$(situation).png", fig)
fig
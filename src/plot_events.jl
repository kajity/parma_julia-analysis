using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using CairoMakie

material = "silver"
energy = range(0.1, stop=20., length=2000)
latitude = [34.5]
longitude = [-104.0]
title = "Detected events for $material (density is based on CdTe)"

set_theme!(theme_latexfonts())
fig = Figure(size=(800, 500), fontsize=12)
ax = Axis(
  fig[1, 1],
  # xscale=log10,
  # yscale=log10,
  # limits=(energy[1], energy[end], 10^-7, 10^3),
)

ParmaAnalysis.ip[] = 1

plot_detected_events!(ax, energy, latitude, longitude, material,
  altitude=20.0, label="proton", n_bin=100, dx=0.000005, x_max=0.1, exposure_time=1000., area=100.,)
Label(fig[1, :, Top()], title, fontsize=22, padding=(0, 0, 10, 0))

save(joinpath(@__DIR__, "..", "figures", "detected_events_$material.png"), fig)
fig


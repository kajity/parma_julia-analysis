using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using CairoMakie

material = "silver"
energy = exp10.(range(-2, stop=5, length=2000))
latitude = [34.5]
longitude = [-104.0]
title = "Stopping power for $material"

set_theme!(theme_latexfonts())
fig = Figure(size=(800, 500), fontsize=12)
ax = Axis(
  fig[1, 1],
  xscale=log10,
  yscale=log10,
  xticks=exp10.(range(-2, stop=5, length=8)),
  # limits=(energy[1], energy[end], 10^-7, 10^3),
)

ParmaAnalysis.ip[] = 1

plot_stopping_power_p!(ax, energy, material,
  label="proton", dx=0.000005,)
Label(fig[1, :, Top()], title, fontsize=22, padding=(0, 0, 10, 0))

save(joinpath(@__DIR__, "..", "figures", "stopping_power_$material.png"), fig)
fig


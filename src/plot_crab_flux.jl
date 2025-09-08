using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis

using CairoMakie
using LaTeXStrings


energy = range(1, stop=50, length=20000)

set_theme!(theme_latexfonts())
fig = Figure(size=(800, 500), fontsize=12)
ax = Axis(
  fig[1, 1],
  xscale=log10,
  yscale=log10,
  # limits=(1e-2, 1e1, nothing, nothing),
)

plot_Crab_photon_flux!(ax, energy, label="Crab Nebula Photon Flux")
Label(fig[1, :, Top()], "Crab Nebula Photon Flux", fontsize=22, padding=(0, 0, 10, 0))
# save(joinpath(@__DIR__, "..", "figures", "crab_photon_flux.pdf"), fig)

fig
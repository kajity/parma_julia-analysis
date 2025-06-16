using Revise
using Pkg
Pkg.develop(path="./ParmaAnalysis")
using ParmaAnalysis

using CairoMakie
using LaTeXStrings
using Printf

energy = 10.
x_begin = 0.0
# dx = 0.000005
x_max = 1.
dx = x_max / 1e6
iteration = 1e5
# material = "silver"
# target = "p"
material = "cadmium"
target = "e"  # Electron
# title = "Path Length vs Stopping Power ($(@sprintf("%.1f", energy)) keV $material)"
title = "Path length vs stopping power of $material for $target (density is based on CdTe)"

set_theme!(theme_latexfonts())
fig = Figure(size=(1000, 600))
ax = Axis(fig[1, 1],
  # width=800, height=400
)

plot_energyloss!(ax, energy, material, target; dx=dx, x_max=0.3, x_begin)

plot_energyloss!(ax, 2energy, material, target; dx=dx, x_max=3., x_begin, iteration)
plot_energyloss!(ax, 3energy, material, target; dx=dx, x_max=3., x_begin, iteration)
plot_energyloss!(ax, 4energy, material, target; dx=dx, x_max=3., x_begin, iteration)
plot_energyloss!(ax, 5energy, material, target; dx=dx, x_max=3.3, x_begin, iteration)
plot_energyloss!(ax, 6energy, material, target; dx=dx, x_max=5., x_begin, iteration)
plot_energyloss!(ax, 7energy, material, target; dx=dx, x_max=5., x_begin, iteration)
plot_energyloss!(ax, 8energy, material, target; dx=dx, x_max=5., x_begin, iteration)
plot_energyloss!(ax, 9energy, material, target; dx=dx, x_max=5., x_begin, iteration)
leg = Legend(fig[1, 2], ax, position=:bottomright, fontsize=14, title="Energy (keV)", titlefontsize=16)
Label(fig[1, 1, Top()], title, fontsize=22, padding=(0, 0, 10, 0))

resize_to_layout!(fig)

# save(joinpath(@__DIR__, "..", "figures", "energyloss_$material.png"), fig)
fig
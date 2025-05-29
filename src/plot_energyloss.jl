
using Pkg
Pkg.develop(path="./ParmaAnalysis")
using ParmaAnalysis

using CairoMakie
using LaTeXStrings
using Printf

energy = 4.
x_begin = 0.05
# dx = 0.000005
x_max = 0.1
dx = x_max / 1e6
material = "silver"
title = "Path Length vs Stopping Power ($(@sprintf("%.1f", energy)) keV $material)"

set_theme!(theme_latexfonts())
fig = Figure(size=(800, 600))
ax = Axis(fig[1, 1], aspect=1.5
)

plot_energyloss_p!(ax, material, energy; dx=dx, x_max=x_max, x_begin, title=title)

# resize_to_layout!(fig)
fig

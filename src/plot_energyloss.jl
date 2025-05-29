using Revise
using Pkg
Pkg.develop(path="./ParmaAnalysis")
using ParmaAnalysis

using CairoMakie
using LaTeXStrings
using Printf

energy = 20.
x_begin = 0.0
# dx = 0.000005
x_max = 1.
dx = x_max / 1e6
material = "silver"
title = "Path Length vs Stopping Power ($(@sprintf("%.1f", energy)) keV $material)"

set_theme!(theme_latexfonts())
fig = Figure(size=(800, 600))
ax = Axis(fig[1, 1], width=600, height=400)

plot_energyloss_p!(ax, material, energy; dx=dx, x_max=x_max, x_begin=0.6, title=title)

# plot_energyloss_p!(ax, material, energy / 2; dx=dx, x_max=x_max, x_begin, title=title * " (zoomed in)", iteration=1000)
# plot_energyloss_p!(ax, material, energy / 3; dx=dx, x_max=x_max, x_begin, title=title * " (zoomed in)", iteration=1000)

leg = Legend(fig[1, 2], ax, position=:bottomright, fontsize=14, title="Energy (keV)", titlefontsize=16)
ax.tellheight = true
Label(fig[0, :], title, fontsize=22)
Box(fig[1, 1], color=(:red, 0.2))

resize_to_layout!(fig)

fig
using Revise
using Pkg
Pkg.develop(path="./ParmaAnalysis")
using ParmaAnalysis

using CairoMakie
using LaTeXStrings
using Printf

target = :e  # Electron
# target = :p  # Proton

material = :none
x_maxs = []
energy = 10.:10.:90.
if (target == :e)
  ParmaAnalysis.ip[] = 31
  material = :cadmium
  x_maxs = [2., 3., 3., 3., 3.3, 5., 5., 5., 5.]
elseif (target == :p)
  ParmaAnalysis.ip[] = 1
  material = :silver
  x_maxs = [0.05, 0.2, 0.3, 1., 1., 1.5, 2., 2., 2.]
else
  error("Unsupported target: $target")
end

x_begin = 0.0
# dx = 0.000005
iteration = 1e6
title = "Path length vs stopping power of $material for $target (density is based on CdTe)"

set_theme!(theme_latexfonts())
fig = Figure(size=(1000, 600))
ax = Axis(
  fig[1, 1],
  # width=800, height=400
)

for (i, e) in enumerate(energy)
  plot_energyloss!(ax, e, material, target; x_max=x_maxs[i], x_begin, iteration)
end

leg = Legend(fig[1, 2], ax, position=:bottomright, fontsize=14, title="Energy (keV)", titlefontsize=16)
Label(fig[1, 1, Top()], title, fontsize=22, padding=(0, 0, 10, 0))

resize_to_layout!(fig)

save(joinpath(@__DIR__, "..", "figures", "energyloss_$material.png"), fig)
fig
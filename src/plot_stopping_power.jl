using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using CairoMakie


# target = "p"  # Proton
target = "e"  # Electron

material = ""
if (target == "e")
  ParmaAnalysis.ip[] = 31
  material = "cadmium"
elseif (target == "p")
  ParmaAnalysis.ip[] = 1
  material = "silver"
else
  error("Unsupported target: $target")
end

energy = exp10.(range(-3, stop=5, length=2000))
latitude = [34.5]
longitude = [-104.0]
title = "Stopping power of $material for $target"

set_theme!(theme_latexfonts())
fig = Figure(size=(800, 500), fontsize=12)
ax = Axis(
  fig[1, 1],
  xscale=log10,
  yscale=log10,
  xticks=exp10.(-3:1:5),
  # limits=(energy[1], energy[end], 10^-7, 10^3),
)

ParmaAnalysis.ip[] = 1

plot_stopping_power!(ax, energy, material, target,
  label="proton", dx=0.000005,)
Label(fig[1, :, Top()], title, fontsize=22, padding=(0, 0, 10, 0))

# save(joinpath(@__DIR__, "..", "figures", "stopping_power_$material.png"), fig)
fig


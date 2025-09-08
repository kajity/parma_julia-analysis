using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using CairoMakie


target = :p  # Proton
# target = :e  # Electron

material = :none
if (target == :e)
  ParmaAnalysis.ip[] = 31
  material = :cadmium
elseif (target == :p)
  ParmaAnalysis.ip[] = 1
  material = :silver
else
  error("Unsupported target: $target")
end

energy = logrange(1e-3, 1e5, length=2000) # stopping power data is supported up to 10^4 MeV!!
latitude = [34.8]
longitude = [-104.2]
title = "Stopping power of $material for $target"

set_theme!(theme_latexfonts())
fig = Figure(size=(800, 500), fontsize=12)
ax = Axis(
  fig[1, 1],
  xscale=log10,
  yscale=log10,
  xticks=LogTicks(-3:5),
  limits=(energy[1], energy[end], nothing, nothing),
)
ax.xlabelsize = 18
ax.ylabelsize = 18

plot_stopping_power!(ax, energy, material, target,
  label="proton", dx=0.000005,)
# Label(fig[1, :, Top()], title, fontsize=22, padding=(0, 0, 10, 0))
println(title)

# save(joinpath(@__DIR__, "..", "figures", "stopping_power_$material.png"), fig)
fig


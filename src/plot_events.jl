using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using CairoMakie

target = "e"  # Electron
# target = "p"  # Proton

material = ""
bin_max = 0.0
energy = []

if (target == "e")
  ParmaAnalysis.ip[] = 31
  material = "cadmium"
  bin_max = 0.5
  energy = range(1e-2, stop=5e1, length=20000)
elseif (target == "p")
  ParmaAnalysis.ip[] = 1
  material = "silver"
  bin_max = 1.
  energy = range(1e-2, stop=1e1, length=20000)
  # energy = range(1e2, stop=1e4, length=20000)
else
  error("Unsupported target: $target")
end

latitude = [34.5]
longitude = [-104.0]
title = "Detected events of $material for $target (density is based on CdTe)"

set_theme!(theme_latexfonts())
fig = Figure(size=(800, 500), fontsize=12)
ax = Axis(
  fig[1, 1],
  # xscale=log10,
  yscale=log10,
  # limits=(energy[1], energy[end], 10^-7, 10^3),
)


plot_detected_events!(ax, energy, latitude, longitude, material, target,
  altitude=20.0, label=target, n_bin=100, dx=0.000005, x_max=0.1, exposure_time=1000., area=100., bin_max=bin_max)
Label(fig[1, :, Top()], title, fontsize=22, padding=(0, 0, 10, 0))

# save(joinpath(@__DIR__, "..", "figures", "detected_events_$material.png"), fig)
save(joinpath(@__DIR__, "..", "figures", "detected_events_log_$(target)_$(material).png"), fig)
fig


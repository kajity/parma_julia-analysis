using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using CairoMakie

# target = "e"  # Electron
# target = "p"  # Proton
# target = "photon"  # Photon
target = "Crab"  # Crab Nebula Photon Flux

material = ""
bin_max = 0.0
energy = []

if (target == "e")
  ParmaAnalysis.ip[] = 31
  material = "cadmium"
  bin_max = 1.
  energy = range(1e-2, stop=1e1, length=20000)
elseif (target == "p")
  ParmaAnalysis.ip[] = 1
  material = "silver"
  bin_max = 1.
  # energy = range(1e-2, stop=1e1, length=20000)
  energy = vcat(collect(range(1e-2, stop=1e1, length=2000)), collect(range(10^2.5, 10^5, length=20000)))
elseif (target == "photon")
  ParmaAnalysis.ip[] = 33
  material = "cadmium"
  # bin_max = 1.
  bin_max = 0.05
  energy = range(1e-2, stop=0.05, length=20000)
elseif (target == "Crab")
  material = "cadmium"
  bin_max = 50.
  energy = range(1e-2, stop=50, length=20000)
else
  error("Unsupported target: $target")
end

latitude = [34.8]
longitude = [-104.0]
altitude = 20.0
title = "Detected events of $target for $material (density is based on CdTe)"

set_theme!(theme_latexfonts())
fig = Figure(size=(800, 500), fontsize=12)
ax = Axis(
  fig[1, 1],
  # xscale=log10,
  yscale=log10,
  limits=(0., bin_max, nothing, nothing),
)

if target == "photon"
  plot_detected_events_photon!(ax, energy, latitude, longitude,
    altitude=altitude, label=target, n_bin=100, area=100., bin_max=bin_max)
elseif target == "Crab"
  plot_detected_events_crab!(ax, energy,
    altitude=altitude, label=target, n_bin=100, area=100., bin_max=bin_max)
else
  plot_detected_events!(ax, energy, latitude, longitude, material, target,
    altitude=altitude, label=target, n_bin=100, dx=0.000005, thickness=0.1, area=100., bin_max=bin_max)
  local_minimum_detected_energy, local_maximum_detected_energy = search_extremum_detected_energy(energy, material, target; dx=0.00005, x_max=0.1)
  println("Local minimum detected energy for $material with target $target: $local_minimum_detected_energy MeV")
  println("Local maximum detected energy for $material with target $target: $local_maximum_detected_energy MeV")
  vlines!(ax, [local_minimum_detected_energy, local_maximum_detected_energy], color=:red)
end
Label(fig[1, :, Top()], title, fontsize=22, padding=(0, 0, 10, 0))


save(joinpath(@__DIR__, "..", "figures", "detected_events_$(target)_$(material).png"), fig)

fig


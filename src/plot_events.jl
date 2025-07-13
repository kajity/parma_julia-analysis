using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using CairoMakie
using Printf

# target = :e  # Electron
# target = :p  # Proton
# target = :photon  # Photon
# target = :Crab  # Crab Nebula Photon Flux
target = :all

plot_type = :line
# plot_type = :histogram

# telescope_magnification = 30.
telescope_magnification = 1.

material = :cadmium
bin_max = 0.0
y_max = nothing
y_min = nothing
n_bin = 100
energy = []

if (target == :e)
  ParmaAnalysis.ip[] = 31
  material = :cadmium
  n_bin = 100
  bin_max = 1.
  energy = range(1e-2, stop=1e1, length=20000)
elseif (target == :p)
  ParmaAnalysis.ip[] = 1
  material = :silver
  bin_max = 1.
  # energy = range(1e-2, stop=1e1, length=20000)
  energy = vcat(collect(range(1e-2, stop=1e1, length=2000)), collect(range(10^2.5, 10^5, length=20000)))
elseif (target == :photon)
  ParmaAnalysis.ip[] = 33
  material = :cadmium
  # bin_max = 1.
  bin_max = 5e-2
  energy = range(1e-2, stop=5e-2, length=20000)
elseif (target == :Crab)
  material = :cadmium
  bin_max = 5e-2
  n_bin = 200
  energy = range(1e-4, stop=5e-2, length=20000)
elseif (target == :all)
  bin_max = 5e-2
  energy = range(1e-2, stop=5e-2, length=20000)
  y_max = telescope_magnification < 2.0 ? 1e2 : 1e4
  y_min = 1e-6
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
  limits=(0., bin_max * 1e3, y_min, y_max),
)

if target == :photon
  plot_detected_events_photon!(ax, energy, latitude, longitude,
    altitude=altitude, label=target, n_bin=n_bin, area=100., bin_max=bin_max, type=plot_type)
elseif target == :Crab
  plot_detected_events_crab!(ax, energy,
    altitude=altitude, label=target, n_bin=n_bin, area=100., bin_max=bin_max, type=plot_type)
elseif target == :e || target == :p
  plot_detected_events!(ax, energy, latitude, longitude, material, target,
    altitude=altitude, label=target, n_bin=n_bin, dx=0.000005, thickness=0.1, area=100., bin_max=bin_max, type=plot_type)
  local_minimum_detected_energy, local_maximum_detected_energy = search_extremum_detected_energy(energy, material, target; dx=0.00005, x_max=0.1)
  local_minimum_detected_energy *= 1e3  # Convert to keV
  local_maximum_detected_energy *= 1e3  # Convert to keV
  println("Local minimum detected energy for $material with target $target: $local_minimum_detected_energy MeV")
  println("Local maximum detected energy for $material with target $target: $local_maximum_detected_energy MeV")
  vlines!(ax, [local_minimum_detected_energy, local_maximum_detected_energy], color=:red)
elseif target == :all
  ParmaAnalysis.ip[] = 31
  material = :cadmium
  plot_detected_events!(ax, energy, latitude, longitude, material, :e,
    altitude=altitude, label="electron", n_bin=n_bin, dx=0.000005, thickness=0.1, area=100., bin_max=bin_max, type=plot_type, color=:green)
  ParmaAnalysis.ip[] = 1
  material = :silver
  plot_detected_events!(ax, energy, latitude, longitude, material, :p,
    altitude=altitude, label="proton", n_bin=n_bin, dx=0.000005, thickness=0.1, area=100., bin_max=bin_max, type=plot_type, color=:red)
  ParmaAnalysis.ip[] = 33
  material = :cadmium
  plot_detected_events_photon!(ax, energy, latitude, longitude,
    altitude=altitude, label="photon", n_bin=n_bin, area=100., bin_max=bin_max, type=plot_type, color=:orange)
  energy_crab = range(5e-3, stop=bin_max, length=energy.len)
  label = "Crab ($(@sprintf("%.1f", telescope_magnification))x)"
  plot_detected_events_crab!(ax, energy_crab, altitude=altitude, label=label, n_bin=n_bin, area=100., bin_max=bin_max, type=plot_type, magnification=telescope_magnification)
  material = :cadmium
  plot_detected_events_photon_albedo_crab!(ax, energy, latitude, longitude,
    altitude=altitude, label="albedo + Crab", n_bin=n_bin, area=100., bin_max=bin_max, type=plot_type, color=:blue, magnification=telescope_magnification)
  Legend(fig[:, 2], ax)
else
  error("Unsupported target: $target")
end
Label(fig[1, :, Top()], title, fontsize=22, padding=(0, 0, 10, 0))

filename = (target == :all ? "detected_events_all" : "detected_events_$(target)_$(material)") * ".png"
save(joinpath(@__DIR__, "..", "figures", filename), fig)

fig


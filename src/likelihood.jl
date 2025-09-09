using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using CairoMakie
using Printf


target = :all
plot_type = :stairs

# telescope_magnification = 30.
telescope_magnification = 1.
time = 1000.0  # in seconds
  bin_max = 5e-2
  energy = range(1e-2, stop=5e-2, length=20000)

latitude = [34.8]
longitude = [-104.0]
altitude = 20.0
title = "Detected events of $target for $material (density is based on CdTe)"


_, events_e, _ = get_binned_events_data(energy, latitude, longitude, :e; altitude=altitude, n_bin=n_bin, area=100., bin_max=bin_max, exposure_time=time)
_, events_p, _ = get_binned_events_data(energy, latitude, longitude, :p; altitude=altitude, n_bin=n_bin, area=100., bin_max=bin_max, exposure_time=time)
_, events_albedo, _ = get_binned_events_data(energy, latitude, longitude, :photon; altitude=altitude, n_bin=n_bin, area=100., bin_max=bin_max, exposure_time=time)
_, events_crab, _ = get_binned_events_data(energy, latitude, longitude, :Crab; altitude=altitude, n_bin=n_bin, area=100., bin_max=bin_max, exposure_time=time)

# println(events_e , ", ", events_p, ", ", events_albedo, ", ", events_crab, ", ", events_photon, ", ", events_crab + events_albedo)
println(sum(events_e), ", ", sum(events_p), ", ", sum(events_albedo), ", ", sum(events_crab), ", ", sum(events_crab) + sum(events_albedo))


filename = (target == :all ? "detected_events_all" : "detected_events_$(target)_$(material)") * ".png"
save(joinpath(@__DIR__, "..", "figures", filename), fig)

fig


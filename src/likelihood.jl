using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using GLMakie
using SpecialFunctions
using Printf
using Distributions


target = :all
plot_type = :stairs

# telescope_magnification = 30.
telescope_magnification = 1.
time = 1000.0  # in seconds
bin_max = 5e-2
n_bin = 81
energy = range(1e-2, stop=5e-2, length=20000)

latitude = [34.8]
longitude = [-104.0]
altitude = 20.0
title = "Detected events of $target (density is based on CdTe)"


_, events_e, _ = get_binned_events_data(energy, latitude, longitude, :e; altitude=altitude, n_bin=n_bin, area=100., bin_max=bin_max, exposure_time=time)
_, events_p, _ = get_binned_events_data(energy, latitude, longitude, :p; altitude=altitude, n_bin=n_bin, area=100., bin_max=bin_max, exposure_time=time)
_, events_albedo, _ = get_binned_events_data(energy, latitude, longitude, :photon; altitude=altitude, n_bin=n_bin, area=100., bin_max=bin_max, exposure_time=time)
_, events_crab, _ = get_binned_events_data(energy, latitude, longitude, :Crab; altitude=altitude, n_bin=n_bin, area=100., bin_max=bin_max, exposure_time=time)

# println(events_e , ", ", events_p, ", ", events_albedo, ", ", events_crab, ", ", events_photon, ", ", events_crab + events_albedo)
println(sum(events_e), ", ", sum(events_p), ", ", sum(events_albedo), ", ", sum(events_crab), ", ", sum(events_crab) + sum(events_albedo))

b = events_e + events_p + events_albedo
s = events_crab

function ln_L(mu::Float64)
  nu = b .+ s .* mu
  n = b .+ s
  n_obs = n + sqrt.(n) .* randn(length(n))
  ln_poisson = @. n_obs * log(nu) - nu - loggamma(n_obs + 1)
  sum(ln_poisson)
end

function ln_L2(mu::Float64)
  nu = b .+ s .* mu
  n = b .+ s
  ln_gaussian = @. -(n - nu)^2 / nu / 2 - log(2π * nu) / 2
  sum(ln_gaussian)
end

t = -2 * (ln_L(0.0) - ln_L(1.0))


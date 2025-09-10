using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using GLMakie
using SpecialFunctions
using Printf
using Distributions
using Optim


# use_random = true
use_random = false
time = 0.5 # in seconds
n_bin = 81


target = :all
plot_type = :stairs

# telescope_magnification = 30.
telescope_magnification = 1.
bin_max = 5e-2
energy = range(1e-2, stop=5e-2, length=20000)

latitude = [34.8]
longitude = [-104.0]
altitude = 20.0


_, events_e, _ = get_binned_events_data(energy, latitude, longitude, :e; altitude=altitude, n_bin=n_bin, area=100., bin_max=bin_max, exposure_time=time)
_, events_p, _ = get_binned_events_data(energy, latitude, longitude, :p; altitude=altitude, n_bin=n_bin, area=100., bin_max=bin_max, exposure_time=time)
_, events_albedo, _ = get_binned_events_data(energy, latitude, longitude, :photon; altitude=altitude, n_bin=n_bin, area=100., bin_max=bin_max, exposure_time=time)
_, events_crab, _ = get_binned_events_data(energy, latitude, longitude, :Crab; altitude=altitude, n_bin=n_bin, area=100., bin_max=bin_max, exposure_time=time)

println("time: $time s, n_bin: $n_bin")

b = events_e + events_p + events_albedo
s = events_crab

println(sum(events_e), ", ", sum(events_p), ", ", sum(events_albedo), ", ", sum(events_crab))
println(sum(b), ", ", sum(s), ", ", sum(b) + sum(s))

n_obs = begin
  if use_random
    n = @. round(b) + round(s)
    n .+ sqrt.(n) .* randn(length(n))
  else
    @. round(b) + round(s)
  end
end

function ln_L(mu::Float64)
  nu = b .+ s .* mu
  ln_poisson = @. n_obs * log(nu) - nu - loggamma(n_obs + 1)
  sum(ln_poisson)
end

function ln_L2(mu::Float64)
  nu = b .+ s .* mu
  ln_gaussian = @. -(n_obs - nu)^2 / nu / 2 - log(2π * nu) / 2
  sum(ln_gaussian)
end

res = optimize(mu -> -ln_L(mu), 0., 2.)
mu_hat = res.minimizer
if (mu_hat < 0.3) || (mu_hat > 1.7)
  println("mu_hat out of range: $mu_hat !!")
end

println("mu_hat = $mu_hat, lnL(mu_hat) = $(-res.minimum)")

q_0 = -2 * (ln_L(0.0) - ln_L(mu_hat))
# p = 1 - cdf(Chisq(1), q_0)
# p = 1 - cdf(Normal(), sqrt(q_0))
p = cdf(Normal(), -sqrt(q_0))
Z = sqrt(q_0)

println("TS = $q_0, p-value = $p, Z = $Z")

# x = range(0, stop=2.0, length=200)
# y = ln_L.(x)
# fig = lines(x, y)
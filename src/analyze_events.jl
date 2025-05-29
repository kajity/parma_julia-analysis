using CSV
using DataFrames
using CairoMakie
using LaTeXStrings
using Printf

struct StoppingPower
  E::Vector{Float64}  # Energy in MeV
  e::Vector{Float64}  # Stopping power in MeV cm^2/g
end

function path_length(stopping_power::StoppingPower, energy::Float64; dx=0.000005, x_max=15.0)
  # Interpolate the stopping power data to find the path length
  S = linear_interpolation(stopping_power.E, stopping_power.e)
  # e_min = minimum(stopping_power.E)
  # S2 = linear_interpolation(stopping_power.E, stopping_power.e)

  # println(typeof(S))
  # println(typeof(S2))

  x = 0.0:dx:x_max
  for i in x
    energy -= S(energy) * dx
    if energy <= 0.0001
      return [i, energy, i / dx]
    end
  end
  return [x_max, energy, x_max / dx]
end

energy = 10.
dx = 0.0000000005
x_max = 0.1
material = "silver"

data_path = joinpath(@__DIR__, "..", "data", "stopping-p_$material.csv")
stopping_power = CSV.read(data_path, DataFrame)
sp = StoppingPower(Float64.(stopping_power.E), Float64.(stopping_power.e))

S = linear_interpolation(sp.E, sp.e)

# @time path_length_values = path_length(S, energy, dx=dx, x_max=x_max)
@time path_length_values = path_length(sp, energy; dx=dx, x_max=x_max)
println(path_length_values)

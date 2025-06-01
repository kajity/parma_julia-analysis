using Interpolations
using CSV
using DataFrames


struct StoppingPower
  E::Vector{Float64}  # Energy in MeV
  e::Vector{Float64}  # Stopping power in MeV / cm
end


function get_stopping_power(material::String)
  data_path = joinpath(@__DIR__, "..", "data", "stopping-p_$material.csv") # stopping power [MeV cm^2/g]
    density = 5.85 # g/cm^3 for CdTe
  try
    stopping_power_raw = CSV.read(data_path, DataFrame)
    return StoppingPower(Float64.(stopping_power_raw.E), Float64.(stopping_power_raw.e) .* density)
  catch e
    error("Stopping power data for $material not found. Please check the file path: $data_path")
  end
end

function path_length(S, energy::Float64, e_min::Float64; dx=0.000005, iteration=nothing, x_max=15.0)
  if energy <= e_min
    return 0.0, energy, 0
  end
  dx = iteration !== nothing ? x_max / iteration : dx
  x = 0.0:dx:x_max
  for i in 1:lastindex(x)-1
    energy -= S(energy) * dx
    if energy <= e_min
      return (i + 1) * dx, 0., i + 1
    end
  end
  energy -= S(energy) * dx
  return x_max, energy, lastindex(x)
end

function path_length(stopping_power::StoppingPower, energy::Float64, e_min::Float64; dx=0.000005, iteration=nothing, x_max=15.0)
  # Interpolate the stopping power data to find the path length
  S = linear_interpolation(stopping_power.E, stopping_power.e)
  path_length(S, energy, e_min; dx=dx, iteration=iteration, x_max=x_max)
end


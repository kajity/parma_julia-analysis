using Interpolations

const FluxArg = Union{Float64,NTuple{2,Float64},AbstractVector{Float64},}

function get_fluxarg(flux::Float64, length::Int)
  return flux
end
function get_fluxarg(flux::NTuple{2,Float64}, length::Int)
  return length == 1 ? flux[end] : range(flux[1], stop=flux[end], length=length)
end
function get_fluxarg(flux::AbstractVector{Float64}, length::Int)
  if size(flux, 1) == length
    return flux
  else
    error("argument length does not match number of plots")
  end
end

function check_fluxarg(length, args...)
  if length == 1 || count(x -> x isa AbstractVector, args) == 1
    println("OK: one vector and the rest Float64s")
  else
    error("Invalid input")
  end
end

struct StoppingPower
  E::Vector{Float64}  # Energy in MeV
  e::Vector{Float64}  # Stopping power in MeV cm^2/g
end

function path_length(S, energy::Float64, e_min::Float64; dx=0.000005, iteration=nothing, x_max=15.0)
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

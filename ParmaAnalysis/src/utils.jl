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

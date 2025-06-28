const FluxArg = Union{Float64,NTuple{2,Float64},AbstractVector{Float64},}

function ip_name(ip)
  # Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)
  ip == 0 ? "neutron" :
  ip == 1 ? "proton" :
  ip == 2 ? "deuteron" :
  ip == 3 ? "triton" :
  ip == 29 ? "muon+" :
  ip == 30 ? "muon-" :
  ip == 31 ? "electron" :
  ip == 32 ? "positron" :
  ip == 33 ? "photon" :
  "unknown"
end

function ip_angle(ip)
  ip == 0 ? 1 :
  ip == 1 ? 2 :
  ip == 2 ? 3 :
  ip == 29 || ip == 30 ? 4 :
  ip == 31 || ip == 32 ? 5 :
  ip == 33 ? 6 :
  0
end

function ip_name()
  ip_name(ip[])
end

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


function get_fluxmean(lat::AbstractVector{Float64}, lon::AbstractVector{Float64}, alti::Float64, energy::Float64, s::Float64)
  flux_mat = @. getSpec(ip[], s, getr(lat, lon'), getd(alti, lat), energy, g[]) # flux_mat[lat, lon]
  factor = @. cosd(lat)
  flux_mat .= flux_mat .* factor
  area = sum(factor) * size(lon, 1)
  sum(flux_mat) / area
end

function get_fluxmean_ang(lat::AbstractVector{Float64}, lon::AbstractVector{Float64}, alti::Float64, energy::Float64, s::Float64, angle::Float64)
  ipa = ip_angle(ip[])
  if ipa == 0
    error("Particle ID $(ip[]) does not support angular differential flux")
  end
  flux_mat = @. getSpecAngFinal(ipa, s, getr(lat, lon'), getd(alti, lat), energy, g[], angle)
  factor = @. cosd(lat)
  flux_mat .= flux_mat .* factor
  area = sum(factor) * size(lon, 1)
  sum(flux_mat) / area
end

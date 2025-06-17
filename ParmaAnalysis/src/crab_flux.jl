using CairoMakie
using LaTeXStrings



# dN / dE = N E^(-gamma)
# N = 9.71 +- 0.16 [cm^-2 keV^-1 s^-1]
# gamma = 2.106 +- 0.006

function Crab_photon_flux(energy::AbstractVector{Float64})
  N = 9.71
  gamma = 2.106

  dN_dE(e) = N * e^(-gamma)

  flux = Vector{Float64}(undef, length(energy) + 1)
  e = 0.0
  flux[1] = 0.0

  for (i, e_next) in enumerate(energy)
    flux[i+1] = flux[i] + dN_dE(e_next) * (e_next - e)
    e = e_next
  end
  return flux[2:end]  # Exclude the first element which is zero
end

function plot_Crab_photon_flux!(ax, energy::AbstractVector{Float64}; label::String="")
  flux = Crab_photon_flux(energy)

  l = lines!(ax, energy, flux, label=label, linewidth=2)
  ax.xlabel = "Energy (keV)"
  ax.ylabel = "Flux (cm⁻² s⁻¹)"
  # ax.title = "Crab Nebula Photon Flux"
  return l
end

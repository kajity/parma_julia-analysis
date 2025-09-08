using CairoMakie
using LaTeXStrings



# dN / dE = N E^(-gamma)
# N = 9.71 +- 0.16 [cm^-2 keV^-1 s^-1]
# gamma = 2.106 +- 0.006

function Crab_photon_flux(energy::AbstractVector{Float64})
  N = 9.71
  gamma = 2.106

  @. N * energy^(-gamma)
end

function Crab_photon_flux(energy::Float64)
  N = 9.71
  gamma = 2.106

  N * energy^(-gamma)
end

function plot_Crab_photon_flux!(ax, energy::AbstractVector{Float64}; label::String="")
  flux = Crab_photon_flux(energy)

  l = lines!(ax, energy, flux, label=label, linewidth=2)
  ax.xlabel = "Energy (keV)"
  ax.ylabel = L"\mathrm{Flux\ (cm^{-2}\ s^{-1}\ keV^{-1})}"
  # ax.title = "Crab Nebula Photon Flux"
  return l
end

using CairoMakie
using LaTeXStrings
using LinearAlgebra
using Statistics
using Printf


function plot_energy_flux!(ax, energy, latitude, longitude; altitude=20.0, label="", color=:auto)
  s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

  flux = Vector{Float64}(undef, length(energy))
  println("Plotting flux")

  for i in eachindex(energy)
    flux[i] = get_fluxmean(latitude, longitude, altitude, energy[i], s)
  end

  l = lines!(ax, energy, flux, linewidth=1.5, label=label)
  ax.xlabel = L"\mathrm{Energy\ (MeV)}"
  ax.ylabel = L"\mathrm{Detected\ flux\ (cm^{-2}\ s^{-1})}"
  l.color = color == :auto ? l.color : color

  l
end

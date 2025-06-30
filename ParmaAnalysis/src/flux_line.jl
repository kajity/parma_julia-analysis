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
  ax.ylabel = L"\mathrm{Flux\ (cm^{-2}\ s^{-1}\ (MeV/n)^{-1})}"
  color !== :auto && (l.color = color)

  l
end

function plot_height_flux!(ax, altitude, latitude, longitude; energy=10.0, label="", color=:auto,)
  s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

  println("Plotting flux")

  flux = get_fluxmean.(Ref(latitude), Ref(longitude), altitude, energy, s)

  l = lines!(ax, altitude, flux; linewidth=1.2, label=label)
  ax.xlabel = "Altitude (km)"
  ax.ylabel = L"\mathrm{Flux\ (cm^{-2}\ s^{-1}\ (MeV/n)^{-1})}"
  color !== :auto && (l.color = color)

  l
end

function plot_angle_flux!(ax, angle, latitude, longitude; altitude=20.0, energy=10.0, label="", color=:auto,)
  s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

  println("Plotting flux")

  flux = get_fluxmean_angdiff.(Ref(latitude), Ref(longitude), altitude, energy, s, angle)

  l = lines!(ax, angle, flux; linewidth=1.2, label=label)
  ax.xlabel = "Zenith angle (rad)"
  ax.ylabel = L"\mathrm{Flux\ (cm^{-2}\ s^{-1}\ str^{-1}\ (MeV/n)^{-1})}"
  color !== :auto && (l.color = color)

  l
end

function plot_angle_factor_flux!(ax, angle, latitude, longitude; altitude=20.0, energy=10.0, label="", color=:auto,)
  s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

  println("Plotting flux")

  flux = get_fluxmean_angdiff_factor.(Ref(latitude), Ref(longitude), altitude, energy, s, angle)

  l = lines!(ax, angle, flux; linewidth=1.2, label=label)
  ax.xlabel = "Zenith angle (rad)"
  ax.ylabel = L"\mathrm{factor\ (str^{-1})}"
  color !== :auto && (l.color = color)

  l
end
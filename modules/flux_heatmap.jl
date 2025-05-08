include("./parma_wrapper.jl")
using .Parma
using CairoMakie
using LaTeXStrings
using LinearAlgebra
using Printf


ip = 0            # Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)
e = 100.0        # Energy (MeV/n)
iyear = 2019      # Year
imonth = 2        # Month
iday = 1          # Day
g = 0.15       # Local geometry parameter, 0=< g =< 1: water weight fraction, 10:no-earth, 100:blackhole, -10< g < 0: pilot, g < -10: cabin
ang = -0.5     # cosine of zenith angle (e.g. ang=1.0 for vertical direction, ang=0.0 for holizontal direction)

lat = range(-90, stop=90, length=300)
lon = range(-180, stop=180, length=300)
title = L"\mathrm{Angular\ integrated\ flux\ (/cm^2/s/(MeV/n))}"
fig = Figure(title=title, size=(1500, 800), fontsize=12)
hms = Heatmap[]
flux_maxs = []

for i in 1:3, j in 1:3
  alti = 9. * ((i - 1) + 3 * (j - 1)) # altitude in km
  flux = @. getSpec(ip, s, getr(lat', lon), getd(alti, lat'), e, g)
  push!(flux_maxs, maximum(flux))
  
  ax = Axis(fig[i, j], title="altitude = $(alti) km")
  hm = heatmap!(ax, lon, lat, flux; colormap=:inferno)
  colsize!(fig.layout, j, Aspect(1, 1.6))
  hidedecorations!(ax)
  if i != 3
    ax.xticksvisible = false
    ax.xticklabelsvisible = false
  end
  if j != 1
    ax.yticksvisible = false
    ax.yticklabelsvisible = false
  end
  ax.xticks = -180:60:180
  ax.yticks = -90:30:90
  push!(hms, hm)
end
for i in 1:9
  flux_max = maximum(flux_maxs)
  hms[i].colorrange = (0, flux_max)
end

rowgap!(fig.layout, 10)
colgap!(fig.layout, 10)

Colorbar(fig[:, end+1], hms[1], label="Flux", labelrotation=π / 2)
Label(fig[0, :], title, fontsize=22)
resize_to_layout!(fig)
fig
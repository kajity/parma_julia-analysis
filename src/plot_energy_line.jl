using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using CairoMakie
using LaTeXStrings

# Choose the situation for plotting.
# situation = "whole_globe"
# situation = "511"
# situation = "south"
# situation = "north"
situation = "Fort_Sumner"

particles = [(0, :blue), (1, :red), (31, :green), (33, :orange), (29, :purple),]  # Particle IDs for different particles
energy = exp10.(range(-2.0, stop=5.0, length=300))
altitude = 20.0  # Altitude in km

if (situation == "whole_globe")
  latitude = range(-90, stop=90, length=30)
  longitude = range(-180, stop=180, length=30) 
elseif (situation == "511")
  # energy = 511.0
  latitude = range(-90, stop=90, length=30)
  longitude = range(-180, stop=180, length=30)
  energy = 500:0.05:520
elseif (situation == "south")
  latitude = range(-90, stop=-80, length=30)
  longitude = range(-180, stop=180, length=30)
elseif (situation == "north")
  latitude = range(80, stop=90, length=30)
  longitude = range(-180, stop=180, length=30)
elseif (situation == "Fort_Sumner")
  latitude = [34.8]
  longitude = [-104.2]
else
  error("Unsupported situation: $situation")
end

set_theme!(theme_latexfonts())
fig = Figure(size=(1000, 500), fontsize=12)
ax = Axis(fig[1, 1], title="",
  titlesize=14,
  xscale=log10,
  yscale=log10,
  limits=(energy[1], energy[end], 10^-9, 10^3),
)

for ip in particles
  ParmaAnalysis.ip[] = ip[1]
  color = length(ip) > 1 ? ip[2] : :auto
  label = ParmaAnalysis.ip_name()
  plot_energy_flux!(ax, energy, latitude, longitude; altitude=altitude, label=label, color=color)
end


Legend(fig[:, 2], ax)
title = "Angular integrated flux for $(situation) (energy vs flux)"
Label(fig[0, :], title, fontsize=18)

save("./figures/line_flux_energy_$(situation).pdf", fig)
fig
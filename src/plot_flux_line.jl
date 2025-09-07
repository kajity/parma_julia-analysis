using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using CairoMakie
using LaTeXStrings
using Printf

# Choose the situation for plotting.
# situation = "whole_globe"
# situation = "511"
# situation = "south"
# situation = "north"
situation = "Fort_Sumner"

x_axis = :energy
# x_axis = :height
# x_axis = :angle
# x_axis = :angle_factor

particles = []  # List of particles to plot
energy = []
altitude = []
angle = []
title = ""

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
ax = Axis(
  fig[1, 1],
  titlesize=14,
  xscale=log10,
  yscale=log10,
)
ax.xlabelsize = 18
ax.ylabelsize = 18

if x_axis == :energy
  # Plotting energy vs flux
  particles = [(0, :blue), (1, :red), (31, :green), (33, :orange), (29, :purple),]  # Particle IDs for different particles
  energy = exp10.(range(-2.0, stop=5.0, length=300))
  altitude = [20.0] # Altitude in km
  ax.limits = (energy[1], energy[end], nothing, nothing)
  ax.yticks = LogTicks(-15:1:4)
elseif x_axis == :height
  # Plotting :angle
  particles = [(0, :blue), (1, :red), (31, :green), (33, :orange),]
  # particles = [(33,)]
  energy = [5e-2]  # Fixed energy in MeV
  altitude = range(0.0, stop=80.0, length=10000)
  ax.xscale = identity
elseif x_axis == :angle_factor || x_axis == :angle
  # Plotting angle vs flux
  particles = [(0, :blue), (1, :red), (31, :green), (33, :orange),]
  # particles = [(33,)]
  energy = [5e-2]  # Fixed energy in MeV
  altitude = [20.0]  # Fixed altitude in km
  angle = range(0, stop=π, length=1000)  # Angle in radians
  ax.xscale = identity
  # ax.xticks = range(0, stop=π, length=5)
  # ax.xtickformat = values -> ["$(@sprintf("%.2f", value / π)) π" for value in values]
  ax.xticks = Makie.MultiplesTicks(5, π, "π")
else
  error("Unsupported x_axis: $x_axis")
end


for ip in particles
  ParmaAnalysis.ip[] = ip[1]
  color = length(ip) > 1 ? ip[2] : :auto
  label = ParmaAnalysis.ip_name()

  if x_axis == :energy
    plot_energy_flux!(ax, energy, latitude, longitude, altitude=altitude[1],
      label=label, color=color)
  elseif x_axis == :height
    plot_height_flux!(ax, altitude, latitude, longitude, energy=energy[1],
      label=label, color=color)
  elseif x_axis == :angle
    plot_angle_flux!(ax, angle, latitude, longitude, altitude=altitude[1], energy=energy[1],
      label=label, color=color)
  elseif x_axis == :angle_factor
    plot_angle_factor_flux!(ax, angle, latitude, longitude, altitude=altitude[1], energy=energy[1],
      label=label, color=color)
  end
end


Legend(fig[:, 2], ax)
title = "Angular integrated flux for $(situation) ($(x_axis) vs flux)"
# Label(fig[0, :], title, fontsize=18)
println("Title: $title")

save(joinpath(@__DIR__, "..", "figures", "flux_$(x_axis)_$(situation).png"), fig)
fig
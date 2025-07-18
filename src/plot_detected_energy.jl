using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using CairoMakie

target = :e
# target = :p  # Proton
twin_plot = true  # Set to true to plot detected energy and flux together
# twin_plot = false  # Set to false to plot detected energy only

material = :none

if (target == :e)
  ParmaAnalysis.ip[] = 31
  material = :cadmium
elseif (target == :p)
  ParmaAnalysis.ip[] = 1
  material = :silver
else
  error("Unsupported target: $target")
end

# energy = range(0.1, stop=1000., length=2000)
energy = exp10.(range(-2, stop=5, length=2000)) # stopping power data is supported up to 10^4 MeV!!
latitude = [34.8]
longitude = [-104.2]
altitude = 20.0

set_theme!(theme_latexfonts())
fig = Figure(size=(800, 500), fontsize=12)
ax1 = Axis(
  fig[1, 1],
  xscale=log10,
  yscale=log10,
  xticks=exp10.(-2:1:5),
  # limits=(energy[1], energy[end], 10^-7, 10^3),
)


plot_detected_energy!(ax1, energy, material, target, label="Energy", dx=0.000005, x_max=0.1)

local_minimum_detected_energy, local_maximum_detected_energy = search_extremum_detected_energy(energy, material, target; dx=0.000005, x_max=0.1)
println("Local minimum detected energy for $material with target $target: $local_minimum_detected_energy MeV")
println("Local maximum detected energy for $material with target $target: $local_maximum_detected_energy MeV")

if !twin_plot
  # ----------------- detected energy only------------------
  title = "Detected energy of $target for $material (density is based on CdTe)"
  Label(fig[1, :, Top()], title, fontsize=22, padding=(0, 0, 10, 0))
  # save(joinpath(@__DIR__, "..", "figures", "detected_energy_$(material)_$(target).png"), fig)
else
  # ----------------- detected energy and flux ------------------
  ax2 = Axis(
    fig[1, 1],
    yaxisposition=:right,
    xscale=log10,
    yscale=log10,
    xticks=exp10.(-2:1:5),
    # limits=(energy[1], energy[end], 10^-7, 10^3),
  )
  plot_energy_flux!(ax2, energy, latitude, longitude, altitude=altitude, label="Flux", color=:orange)

  title = "Detected energy and flux of $target for $material (density is based on CdTe)"
  Label(fig[1, :, Top()], title, fontsize=22, padding=(0, 0, 10, 0))
  # Legend(fig[:, 2], ax1)
  # Legend(fig[:, 2], ax2)
  save(joinpath(@__DIR__, "..", "figures", "detected_energy_flux_$(material)_$(target).png"), fig)
end

fig


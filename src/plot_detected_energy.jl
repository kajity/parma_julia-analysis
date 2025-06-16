using Revise
using Pkg
Pkg.develop(path=joinpath(@__DIR__, "..", "ParmaAnalysis"))
using ParmaAnalysis
using CairoMakie

# target = "e"
target = "p"  # Proton

material = ""

if (target == "e")
  ParmaAnalysis.ip[] = 31
  material = "cadmium"
elseif (target == "p")
  ParmaAnalysis.ip[] = 1
  material = "silver"
else
  error("Unsupported target: $target")
end

# energy = range(0.1, stop=1000., length=2000)
energy = exp10.(range(-2, stop=5, length=2000))
latitude = [34.5]
longitude = [-104.0]
altitude = 20.0

set_theme!(theme_latexfonts())
fig = Figure(size=(800, 500), fontsize=12)
ax1 = Axis(
  fig[1, 1],
  xscale=log10,
  yscale=log10,
  # limits=(energy[1], energy[end], 10^-7, 10^3),
)


plot_detected_energy!(ax1, energy, material, target, label="Detected energy", dx=0.000005, x_max=0.1)



# ----------------- Choose this to plot detected energy only------------------
# title = "Detected energy for $material (density is based on CdTe)"
# Label(fig[1, :, Top()], title, fontsize=22, padding=(0, 0, 10, 0))
# save(joinpath(@__DIR__, "..", "figures", "detected_energy_$material.png"), fig)
# fig


# ----------------- Choose this to plot detected energy and flux ------------------
ax2 = Axis(
  fig[1, 1],
  yaxisposition=:right,
  xscale=log10,
  yscale=log10,
  # limits=(energy[1], energy[end], 10^-7, 10^3),
)
plot_energy_flux!(ax2, energy, latitude, longitude, altitude=altitude, label="Flux", color=:orange)

title = "Detected energy and flux for $material (density is based on CdTe)"
Label(fig[1, :, Top()], title, fontsize=22, padding=(0, 0, 10, 0))
# save(joinpath(@__DIR__, "..", "figures", "detected_energy_flux_$material.png"), fig)

fig


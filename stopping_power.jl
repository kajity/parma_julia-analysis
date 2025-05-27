using CSV
using DataFrames
using CairoMakie
using LaTeXStrings
using Interpolations
using Printf

function path_length(stopping_power, energy; dx=0.000005, x_max=15.0)
  # Interpolate the stopping power data to find the path length
  S = linear_interpolation(stopping_power.E, stopping_power.e)
  e_min = minimum(stopping_power.E)
  x = 0.0:dx:x_max
  y = zeros(length(x))
  for i in eachindex(x)
    y[i] = S(energy)
    energy -= y[i] * dx
    if energy <= e_min
      return [x[1:i + 1] y[1:i + 1]]
    end
  end
  return [x y]
end

energy = 100.
dx = 0.0000005
x_max = 15
material = "silver"

stopping_power = CSV.read("data/stopping-p_$material.csv", DataFrame)


path_length_values = path_length(stopping_power, energy, dx=dx, x_max=x_max)
# CSV.write("data/path_length_silver.csv", DataFrame(path_length_values, :auto), writeheader=true)

println(size(path_length_values))
fig = Figure(size=(800, 600))
ax = Axis(fig[1, 1], xlabel="Path Length (cm * g/cm^3)", ylabel="Energy (MeV)",
  title="Path Length vs Stopping Power ($(@sprintf("%.1f", energy)) keV $material)", 

)

tail_size = 6000
lines!(ax, path_length_values[end-tail_size:end, 1], path_length_values[end-tail_size:end, 2], color=:blue, linewidth=2)
# lines!(ax, path_length_values[:, 1], path_length_values[:, 2], color=:blue, linewidth=2)
# save("figures/path_length_silver.png", fig)
fig
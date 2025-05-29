using CSV
using DataFrames
using CairoMakie
using LaTeXStrings
using Interpolations
using Printf

function plot_energyloss_p!(ax, material, energy; dx=0.000005, iteration=nothing, x_max=15.0, x_begin=0., color=:auto)
  energy_tmp = energy

  data_path = joinpath(@__DIR__, "..", "data", "stopping-p_$material.csv")
  stopping_power_raw = CSV.read(data_path, DataFrame)
  stopping_power = StoppingPower(Float64.(stopping_power_raw.E), Float64.(stopping_power_raw.e))

  # Interpolate the stopping power data to find the path length
  S = linear_interpolation(stopping_power.E, stopping_power.e)
  e_min = minimum(stopping_power.E)
  dx = iteration !== nothing ? x_max / iteration : dx
  x = 0.0:dx:x_max

  (path, _, n) = path_length(S, energy_tmp, e_min; dx=dx, x_max=x_max)
  if (n * sizeof(Float64) > 1e9)
    error("Too many points to plot ($n), consider increasing dx or decreasing x_max.")
  else
    println(@sprintf("Allocated %e bytes for this plot", n * sizeof(Float64)))
  end

  println("Path length: ", path, " cm g/cm^3")
  y = Vector{Float64}(undef, n)

  for i in eachindex(x)
    loss = S(energy_tmp)
    energy_tmp -= loss * dx
    y[i] = loss
    if energy_tmp <= e_min
      y[i+1:end] .= 0.0
      break
    end
  end

  x_end = x[length(y)]
  tail_size = length(y) - 1
  if 0. < x_begin < x_end
    tail_size = floor(Int64, (x_end - x_begin) / dx)
  end

  x_data = x[1:length(y)][end-tail_size:end]
  y_data = @view y[end-tail_size:end]


  l = lines!(ax, x_data, y_data,
    linewidth=2, label="$(@sprintf("%.2f", energy)) MeV")
  ax.xlabel = L"\mathrm{Path\ Length\ (cm\ g/cm^3)}"
  ax.ylabel = L"\mathrm{Energy\ Loss\ (MeV\ cm^2/g)}"
  # ax.title = title
  ax.titlesize = 22
  ax.titlefont = :regular
  l
end

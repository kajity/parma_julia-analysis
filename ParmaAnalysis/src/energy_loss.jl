using CSV
using DataFrames
using CairoMakie
using LaTeXStrings
using Interpolations
using Printf

function plot_energyloss!(ax, energy, material::Symbol, target::Symbol; dx=0.000005, iteration=nothing, x_max=15.0, x_begin=0., color=:auto)
  energy_tmp = energy

  stopping_power = get_stopping_power(material, target)

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

  println("Path length: ", path, " cm")
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
  ax.xlabel = L"\mathrm{Path\ length\ (cm)}"
  ax.ylabel = L"\mathrm{Energy\ loss\ (MeV/cm)}"
  # ax.title = title
  ax.titlesize = 22
  ax.titlefont = :regular
  l
end

function plot_detected_energy!(ax, energy, material, target; label="proton", dx=0.005, x_max=0.1, color=:auto)
  stopping_power = get_stopping_power(material, target)

  e_min = minimum(stopping_power.E)

  println("Plotting detected energy for $material with dx=$dx and x_max=$x_max")

  energy_end = getindex.(path_length.(Ref(stopping_power), energy, e_min; dx=dx, x_max=x_max), 2)
  energy_detected = energy .- energy_end

  # Plot the detected flux
  l = lines!(ax, energy, energy_detected,
    linewidth=1.5, label="$label ($material)")
  ax.xlabel = L"\mathrm{Energy\ (MeV)}"
  ax.ylabel = L"\mathrm{Detected\ energy\ (MeV)}"
  ax.titlesize = 22
  ax.titlefont = :regular
  l.color = color == :auto ? l.color : color

  l
end

function search_extremum_detected_energy(energy::AbstractVector{Float64}, material, target; dx=0.005, x_max=0.1)
  stopping_power = get_stopping_power(material, target)

  e_min::Float64 = minimum(stopping_power.E)

  println("Searching for minimum detected energy for $material with dx=$dx and x_max=$x_max")

  energy_end::Vector{Float64} = getindex.(path_length.(Ref(stopping_power), energy, e_min; dx=dx, x_max=x_max), 2)
  energy_detected = energy .- energy_end

  energy_diff = @view(energy_detected[2:end]) .- @view(energy_detected[1:end-1])
  turning_point = findfirst(energy_diff .< 0)
  if turning_point === nothing
    println("No turning point found, returning minimum energy detected.")
    return (minimum(energy_detected), maximum(energy_detected))
  end
  return (minimum(@view energy_detected[turning_point:end]), energy_detected[turning_point])
end


function plot_stopping_power!(ax, energy, material, target; label="proton", dx=0.005, x_max=0.1, color=:auto)
  stopping_power = get_stopping_power(material, target)

  println("Plotting detected energy for $material with dx=$dx and x_max=$x_max")

    S_interp = interpolate((stopping_power.E,), stopping_power.e, Gridded(Linear()))
  # S = extrapolate(S_interp, Flat())
  S = extrapolate(S_interp, Linear())

  stopping_power = S.(energy)

  # Plot the detected flux
  l = lines!(ax, energy, stopping_power,
    linewidth=1.5, label="$label ($material)")
  ax.xlabel = L"\mathrm{Energy\ (MeV)}"
  ax.ylabel = L"\mathrm{Stopping\ power\ (MeV cm^2 / g)}"
  ax.titlesize = 22
  ax.titlefont = :regular
  l.color = color == :auto ? l.color : color

  l
end

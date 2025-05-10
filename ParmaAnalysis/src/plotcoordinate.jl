include("parmawrapper.jl")
include("variables.jl")

using CairoMakie
using GeoMakie
using LaTeXStrings
using LinearAlgebra
using Printf

const FluxArg = Union{Float64,NTuple{2,Float64},AbstractVector{Float64},}

function get_fluxarg(flux::Float64, length::Int)
  return flux
end
function get_fluxarg(flux::NTuple{2,Float64}, length::Int)
  return length == 1 ? flux[end] : range(flux[1], stop=flux[end], length=length)
end
function get_fluxarg(flux::AbstractVector{Float64}, length::Int)
  if size(flux, 1) == length
    return flux
  else
    error("argument length does not match number of plots")
  end
end

function check_fluxarg(length, args...)
  if length == 1 || count(x -> x isa AbstractVector, args) == 1
    println("OK: one vector and the rest Float64s")
  else
    error("Invalid input")
  end
end

function plot_coordinate!(fig, latitude, longitude, num=(3, 3); altitude::FluxArg=0.0, energy::FluxArg=100.0, title="", colorrange=:auto,)
  println("Plotting flux (longitude, latitude)...")


  s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

  numi, numj = num
  altitude = get_fluxarg(altitude, numi * numj)
  energy = get_fluxarg(energy, numi * numj)
  println("altitude = $altitude km, energy = $energy MeV")
  check_fluxarg(numi * numj, altitude, energy)
  hms = Heatmap[]
  flux_maxs = []

  for i in 1:numi, j in 1:numj
    isaltitudevector = altitude isa AbstractVector
    alti = isaltitudevector ? altitude[(i-1)*numj+j] : altitude
    e = isaltitudevector ? energy : energy[(i-1)*numj+j]
    axistitle = isaltitudevector ? "altitude = $(@sprintf("%.2f", alti)) km" : "energy = $(@sprintf("%.2f", e)) MeV"
    println("Plotting ($i, $j) $axistitle")
    flux = @. getSpec(ip[], s, getr(latitude', longitude), getd(alti, latitude'), e, g[])
    push!(flux_maxs, maximum(flux))
    xdata = range(longitude[1], stop=longitude[end], length=longitude.len + 1)
    ydata = range(latitude[1], stop=latitude[end], length=latitude.len + 1)

    ax = Axis(fig[i, j], title=axistitle,
      titlesize=14,
      limits=(longitude[1], longitude[end], latitude[1], latitude[end]),
      xticklabelrotation=π / 4,
    )
    hm = heatmap!(ax, xdata, ydata, flux; colormap=(:inferno, 0.85))
    lines!(ax, GeoMakie.coastlines(), color=(:black, 0.8), linewidth=0.8)
    colsize!(fig.layout, j, Aspect(1, 1.6))

    if i != numi
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
  for i in LinearIndices(hms)
    flux_max = maximum(flux_maxs)
    hms[i].colorrange = colorrange == :auto ? (0, flux_max) : colorrange
  end
  rowgap!(fig.layout, 10)
  colgap!(fig.layout, 20)

  Colorbar(fig[:, end+1], hms[1], label="Flux", labelrotation=π / 2)
  Label(fig[0, :], title, fontsize=22)
  Label(fig[end + 1, :], L"Longitude\ (\degree)", fontsize=18)
  Label(fig[:, 0], L"Latitude\ (\degree)", fontsize=18, rotation=π / 2)
  resize_to_layout!(fig)
  fig
end

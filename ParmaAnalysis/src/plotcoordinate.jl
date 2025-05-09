include("parmawrapper.jl")
include("variables.jl")

using CairoMakie
using GeoMakie
using LaTeXStrings
using LinearAlgebra
using Printf



function plot_coordinate!(fig, latitude, longitude, altitude=(0.0, 86.0), num=(3, 3); title="", colorrange=:auto,)
  println("Plotting flux heatmap (longitude, latitude)...")
  s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

  numi, numj = num
  altitude = num == (1, 1) ? [altitude[end]] : range(altitude[1], stop=altitude[end], length=numi * numj)
  hms = Heatmap[]
  flux_maxs = []

  for i in 1:numi, j in 1:numj
    alti = altitude[(i-1)*numj+j]
    println("Plotting ($i, $j) altitude = $alti km")
    flux = @. getSpec(ip[], s, getr(latitude', longitude), getd(alti, latitude'), e[], g[])
    push!(flux_maxs, maximum(flux))
    xdata = range(longitude[1], stop=longitude[end], length=longitude.len + 1)
    ydata = range(latitude[1], stop=latitude[end], length=latitude.len + 1)

    ax = Axis(fig[i, j], title="altitude = $(@sprintf("%.2f", alti)) km",
      titlesize=18,
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
  resize_to_layout!(fig)
  fig
end

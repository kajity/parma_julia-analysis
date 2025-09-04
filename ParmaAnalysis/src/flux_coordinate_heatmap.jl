using CairoMakie
using GeoMakie
using LaTeXStrings
using LinearAlgebra
using Printf

function plot_coordinate!(fig, latitude, longitude, num=(3, 3); altitude::FluxArg=0.0, energy::FluxArg=100.0, title="", colorrange=:auto, logscale=false, colormap=:inferno)
  println("Plotting flux (longitude, latitude)...")

  s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

  numi, numj = num
  altitude = get_fluxarg(altitude, numi * numj)
  energy = get_fluxarg(energy, numi * numj)
  check_fluxarg(numi * numj, altitude, energy)
  isaltitudevector = altitude isa AbstractVector
  hms = Heatmap[]
  flux_extrema = []

  for i in 1:numi, j in 1:numj
    alti = isaltitudevector ? altitude[(i-1)*numj+j] : altitude
    e = isaltitudevector ? energy : energy[(i-1)*numj+j]
    axistitle = isaltitudevector ? "altitude = $(@sprintf("%.2f", alti)) km" : "energy = $(@sprintf("%.2f", e)) MeV"
    println("Plotting ($i, $j) $axistitle")
    flux = @. getSpec(ip[], s, getr(latitude', longitude), getd(alti, latitude'), e, g[])
    push!(flux_extrema, extrema(flux)...)
    hm = heatmapadd!(fig, (i, j, numi, numj), longitude, latitude, flux;
      xticks=(-180:60:180),
      yticks=(-90:30:90),
      axistitle=axistitle,
      colormap=(colormap, 0.85),
      colorscale=logscale ? log10 : identity,
      geo=true)
    push!(hms, hm)

  end
  for hm in hms
    flux_max = maximum(flux_extrema)
    flux_min = minimum(flux_extrema)
    hm.colorrange = colorrange == :auto ? (flux_min, flux_max) : colorrange
  end
  rowgap!(fig.layout, 10)
  colgap!(fig.layout, 20)

  Colorbar(fig[:, end+1], hms[1], label="Flux", labelrotation=π / 2)
  # Label(fig[0, :], title, fontsize=30)
  Label(fig[end+1, :], L"\mathrm{Longitude}\ (\degree)", fontsize=18)
  Label(fig[:, 0], L"\mathrm{Latitude}\ (\degree)", fontsize=18, rotation=π / 2)
  resize_to_layout!(fig)
  fig
end

using CairoMakie
using GeoMakie
using LaTeXStrings
using LinearAlgebra
using Printf


function plot_longalti!(fig, longitude, altitude, num=(3, 3); latitude::FluxArg=0.0, energy::FluxArg=100.0, title="", colorrange=:auto, logscale=false, colormap=:inferno)
  println("Plotting flux (longitude, altitude)...")

  s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

  numi, numj = num
  latitude = get_fluxarg(latitude, numi * numj)
  energy = get_fluxarg(energy, numi * numj)
  check_fluxarg(numi * numj, latitude, energy)
  isenergyvector = energy isa AbstractVector
  hms = Heatmap[]
  flux_extrema = []

  for i in 1:numi, j in 1:numj
    e = isenergyvector ? energy[(i-1)*numj+j] : energy
    lat = isenergyvector ? latitude : latitude[(i-1)*numj+j]
    axistitle = isenergyvector ? "energy = $(@sprintf("%.2f", e)) MeV" : "latitude = $(@sprintf("%.2f", lat)) deg"
    println("Plotting ($i, $j) $axistitle")
    flux = @. getSpec(ip[], s, getr(lat, longitude), getd(altitude', lat), e, g[])
    push!(flux_extrema, extrema(flux)...)
    xdata = range(longitude[1], stop=longitude[end], length=longitude.len + 1)
    ydata = range(altitude[1], stop=altitude[end], length=altitude.len + 1)

    hm = heatmapadd!(fig, (i, j, numi, numj), xdata, ydata, flux,
      xticks=-180:60:180,
      yticks=0:20:80,
      axistitle=axistitle,
      colormap=(colormap, 0.85),
      colorscale=logscale ? log10 : identity,
    )

    push!(hms, hm)
  end
  for i in LinearIndices(hms)
    flux_max = maximum(flux_extrema)
    flux_min = minimum(flux_extrema)
    hms[i].colorrange = colorrange == :auto ? (flux_min, flux_max) : colorrange
  end
  rowgap!(fig.layout, 10)
  colgap!(fig.layout, 20)

  Colorbar(fig[:, end+1], hms[1], label="Flux", labelrotation=π / 2)
  Label(fig[0, :], title, fontsize=22)
  Label(fig[end+1, :], L"\mathrm{Longitude}\ (\degree)", fontsize=18)
  Label(fig[:, 0], L"\mathrm{Altitude}\ (\degree)", fontsize=18, rotation=π / 2)
  resize_to_layout!(fig)
  fig
end


function plot_latalti!(fig, latitude, altitude, num=(3, 3); longitude::FluxArg=0.0, energy::FluxArg=100.0, title="", colorrange=:auto, logscale=false, colormap=:inferno)
  println("Plotting flux (latitude, altitude)...")

  s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

  numi, numj = num
  longitude = get_fluxarg(longitude, numi * numj)
  energy = get_fluxarg(energy, numi * numj)
  check_fluxarg(numi * numj, longitude, energy)
  isenergyvector = energy isa AbstractVector
  hms = Heatmap[]
  flux_extrema = []

  for i in 1:numi, j in 1:numj
    e = isenergyvector ? energy[(i-1)*numj+j] : energy
    lon = isenergyvector ? longitude : longitude[(i-1)*numj+j]
    axistitle = isenergyvector ? "energy = $(@sprintf("%.2f", e)) MeV" : "longitude = $(@sprintf("%.2f", lon)) deg"
    println("Plotting ($i, $j) $axistitle")
    flux = @. getSpec(ip[], s, getr(latitude, lon), getd(altitude', latitude), e, g[])
    push!(flux_extrema, extrema(flux)...)
    xdata = range(latitude[1], stop=latitude[end], length=latitude.len + 1)
    ydata = range(altitude[1], stop=altitude[end], length=altitude.len + 1)

    hm = heatmapadd!(fig, (i, j, numi, numj), xdata, ydata, flux,
      xticks=-90:30:90,
      yticks=0:20:80,
      axistitle=axistitle,
      colormap=(colormap, 0.85),
      colorscale=logscale ? log10 : identity,
    )
    push!(hms, hm)
  end

  for i in LinearIndices(hms)
    flux_max = maximum(flux_extrema)
    flux_min = minimum(flux_extrema)
    hms[i].colorrange = colorrange == :auto ? (flux_min, flux_max) : colorrange
  end
  rowgap!(fig.layout, 10)
  colgap!(fig.layout, 20)

  Colorbar(fig[:, end+1], hms[1], label="Flux", labelrotation=π / 2)
  Label(fig[0, :], title, fontsize=22)
  Label(fig[end+1, :], L"\mathrm{Latitude}\ (\degree)", fontsize=18)
  Label(fig[:, 0], L"\mathrm{Altitude}\ (\degree)", fontsize=18, rotation=π / 2)
  resize_to_layout!(fig)
  fig
end

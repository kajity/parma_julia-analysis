using Makie

function heatmapadd!(fig, (i, j, numi, numj), xaxis, yaxis, data;
  xticks=automatic, yticks=automatic,
  axistitle="", colorrange=:auto, colorscale=log10, geo=false)

  xdata = range(xaxis[1], stop=xaxis[end], length=xaxis.len + 1)
  ydata = range(yaxis[1], stop=yaxis[end], length=yaxis.len + 1)

  ax = Axis(fig[i, j], title=axistitle,
    titlesize=14,
    limits=(xaxis[1], xaxis[end], yaxis[1], yaxis[end]),
    xticklabelrotation=π / 4,
    xticks=xticks,
    yticks=yticks,
  )
  hm = heatmap!(ax, xdata, ydata, data; colormap=(:inferno, 0.85), colorscale=colorscale)
  if geo
    lines!(ax, GeoMakie.coastlines(), color=(:black, 0.8), linewidth=0.8)
  end
  colsize!(fig.layout, j, Aspect(1, 1.6))

  if i != numi
    ax.xticksvisible = false
    ax.xticklabelsvisible = false
  end
  if j != 1
    ax.yticksvisible = false
    ax.yticklabelsvisible = false
  end
  hm
end
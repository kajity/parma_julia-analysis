include("ParmaAnalysis/src/parmawrapper.jl")

npart = 33
IangPart::Vector{Cint} = [1, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 5, 5, 6]

# Set condition
ip = 0            # Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)
e = 100.0        # Energy (MeV/n)
iyear = 2019      # Year
imonth = 2        # Month
iday = 1          # Day
glat = 30.5    # Latitude (deg), -90 =< glat =< 90
glong = -76.2  # Longitude (deg), -180 =< glong =< 180
alti = 0.0     # Altitude (km)
g = 0.15       # Local geometry parameter, 0=< g =< 1: water weight fraction, 10:no-earth, 100:blackhole, -10< g < 0: pilot, g < -10: cabin
ang = -0.5     # cosine of zenith angle (e.g. ang=1.0 for vertical direction, ang=0.0 for holizontal direction)

# calculate parameters
s = getHP(iyear, imonth, iday)  # W-index (solar activity)
r = getr(glat, glong)           # Vertical cut-off rigidity (GV)
d = getd(alti, glat)            # Atmospheric depth (g/cm2), set glat = 100 for use US Standard Atmosphere 1976.

Flux, DifFlux = 0.0, 0.0

Flux = getSpec(ip, s, r, d, e, g)
println("Angular Integrated Flux(/cm2/s/(MeV/n))= ", Flux)

if (IangPart[ip+1] > 0)
  DifFlux = Flux * getSpecAngFinal(IangPart[ip+1], s, r, d, e, g, ang)
  println("Angular Differential Flux(/cm2/s/(MeV/n)/sr)= ", DifFlux)
end

# using CairoMakie
# lat = range(-90, stop=90, length=300)
# lon = range(-180, stop=180, length=300)
# alti = 18.
# title=L"\mathrm{Angular\ integrated\ flux\ (/cm^2/s/(MeV/n))}"
# flux = @. getSpec(ip, s, getr(lat, lon'), getd(alti, lat), e, g)
# fig = Figure()
# ax = Axis(fig[1, 1], title=title)
# heatmap!(ax, lon, lat, flux, colormap=:plasma)
# fig
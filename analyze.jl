include("./modules/parma_wrapper.jl")
using .Parma

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

glat=-3:0.2:3
glong=-3:0.2:5
f(lat, long) = @. getSpec(ip, s, getr(lat, long'), d, e, g)
z=f(glat, glong)

using Plots
# gr()
pyplot()
p = heatmap(z, 
    title="Angular Integrated Flux(/cm2/s/(MeV/n))", 
    xlabel="Longitude (deg)", ylabel="Latitude (deg)", 
    color=:viridis,  
    size=(800, 600))
plot(p, fmt=:png)
savefig(p, "flux2.png")
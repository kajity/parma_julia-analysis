ip = Ref(0)        # Particle ID (Particle ID, 0:neutron, 1-28:H-Ni, 29-30:muon+-, 31:e-, 32:e+, 33:photon)
e = Ref(100.0)     # Energy (MeV/n)
iyear = Ref(2018)  # Year
imonth = Ref(2)    # Month
iday = Ref(1)      # Day
g = Ref(0.15)      # Local geometry parameter, 0=< g =< 1: water weight fraction, 10:no-earth, 100:blackhole, -10< g < 0: pilot, g < -10: cabin
ang = Ref(-0.5)    # cosine of zenith angle (e.g. ang=1.0 for vertical direction, ang=0.0 for holizontal direction)

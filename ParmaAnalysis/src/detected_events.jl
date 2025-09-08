using DataFrames
using Interpolations
using StructArrays
using Base.Threads

struct EnergyEvents
    energy::Float64
    events::Float64
end


function plot_detected_events!(ax, energy, latitude, longitude, material::Symbol, target::Symbol; x_end=20., altitude=20.0, n_bin=64, area=100., label="", color=:auto, dx=0.000005, iteration=nothing, thickness=15.0, bin_max=20.0, type=:line, exposure_time=1000.0,)
    s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

    flux = get_fluxmean.(Ref(latitude), Ref(longitude), altitude, energy, s)

    stopping_power = get_stopping_power(material, target)
    energy_events = StructArray{EnergyEvents}(energy=range(1e-2, stop=bin_max, length=n_bin), events=zeros(n_bin))
    S_interp = interpolate((stopping_power.E,), stopping_power.e, Gridded(Linear()))
    # S = extrapolate(S_interp, Flat())
    S = extrapolate(S_interp, Linear())
    e_min = minimum(stopping_power.E)

    println("Calculating detected events for $target with material $material...")
    @threads for i in 1:lastindex(energy)-1
        dE = energy[i+1] - energy[i]
        e = energy[i] + dE * 0.5  # Use the midpoint for the energy
        (_, e_end, _) = path_length(S, e, e_min; dx=dx, iteration=iteration, x_max=thickness)
        e_detected = e - e_end

        if e_detected < 0.
            error("Detected energy is non-positive for energy $e MeV")
        end

        bin_index = findfirst(x -> x >= e_detected, energy_events.energy)
        if isnothing(bin_index) || bin_index == 1
            # error("Detected energy $e_detected MeV is out of bounds for the defined energy range.")
            print("\rDetected energy $e_detected MeV is out of bounds for the defined energy range. Skipping this event.")
            continue
        end
        bin_index -= 1  # minを超えた直後は1にしたいのでずらす
        energy_events.events[bin_index] += flux[i] * area * dE # エネルギーで積分
        # energy_events.events[bin_index] += 1
    end
    println("")

    energy_keV = (energy_events.energy[1:end-1] + energy_events.energy[2:end]) / 2 * 1e3  # Convert energy to keV
    events = energy_events.events[1:end-1] .* exposure_time
    events_sum = sum(events)

    if type == :stairs
        l = stairs!(ax, energy_keV, events,
            label=label, step=:center)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts)}"
    elseif type == :line
        bar_width_keV = (bin_max - 1e-2) / n_bin * 1e3
        events ./= bar_width_keV
        l = lines!(ax, energy_keV, events,
            label=label, linewidth=1.5)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts\ keV^{-1})}"
    else
        error("Unsupported plot type: $type")
    end
    ax.xlabel = L"\mathrm{Detected\ energy\ (keV)}"
    color !== :auto && (l.color = color)

    l, events_sum
end

function plot_detected_events_photon!(ax, energy, latitude, longitude; altitude=20.0, n_bin=64, area=100., label="", color=:auto, bin_max=20.0, type=:line, exposure_time=1000.0)
    s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)
    events_sum = 0.0

    println("Calculating detected events for photon...")
    if type == :stairs
        flux = get_fluxmean.(Ref(latitude), Ref(longitude), altitude, energy, s)
        get_flux(e) = get_fluxmean(latitude, longitude, altitude, e, s)
        energy_events = StructArray{EnergyEvents}(energy=range(1e-2, stop=bin_max, length=n_bin), events=zeros(n_bin))

        for i in 1:lastindex(energy)-1
            dE = energy[i+1] - energy[i]
            e = energy[i] + dE * 0.5  # Use the midpoint for the energy
            e_detected = e

            if e_detected < 0.
                error("Detected energy is non-positive for energy $e MeV")
            end

            bin_index = findfirst(x -> x >= e_detected, energy_events.energy)
            if isnothing(bin_index) || bin_index == 1
                # error("Detected energy $e_detected MeV is out of bounds for the defined energy range.")
                print("Detected energy $e_detected MeV is out of bounds for the defined energy range. Skipping this event.\r")
                continue
            end
            bin_index -= 1  # minを超えた直後は1にしたいのでずらす
            # energy_events.events[bin_index] += flux[i] * area * dE # エネルギーで積分
            energy_events.events[bin_index] += get_flux(e_detected) * area * dE # エネルギーで積分
        end

        energy_keV = (energy_events.energy[1:end-1] + energy_events.energy[2:end]) * 0.5 * 1e3  # Convert energy to keV
        events = energy_events.events[1:end-1] .* exposure_time
        events_sum = sum(events)

        l = stairs!(ax, energy_keV, events,
            label=label, step=:center)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts)}"
    elseif type == :line
        energy_MeV = range(energy[1], stop=bin_max, length=n_bin)
        flux = get_fluxmean.(Ref(latitude), Ref(longitude), altitude, energy_MeV, s)
        energy_keV = energy_MeV * 1e3
        events = flux .* (area * 1e-3 * exposure_time)  # (/cm^2/s/(MeV/n)) -> (/(keV/n))
        events_sum = sum(events) * (energy_keV[2] - energy_keV[1])  # Total events
        # Normalize events by the bin width in keV
        l = lines!(ax, energy_keV, events,
            label=label, linewidth=1.5)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts\ keV^{-1})}"
    else
        error("Unsupported plot type: $type")
    end
    ax.xlabel = L"\mathrm{Detected\ energy\ (keV)}"
    color !== :auto && (l.color = color)

    l, events_sum
end

function plot_detected_events_crab!(ax, energy; altitude=20.0, n_bin=64, area=100., label="", color=:auto, bin_max=20.0, type=:line, magnification=1.0, exposure_time=1000.0)
    s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)
    events_sum = 0.0

    println("Calculating detected events for Crab...")

    bin_max *= 1e3 # Convert to keV
    energy *= 1e3 # Convert to keV

    if type == :stairs
        flux = Crab_photon_flux(energy)

        # energy [keV], bin_max [keV]
        energy_events = StructArray{EnergyEvents}(energy=range(10, stop=bin_max, length=n_bin), events=zeros(n_bin))

        for i in 1:lastindex(energy)-1
            dE = energy[i+1] - energy[i]
            e = energy[i] + dE * 0.5  # Use the midpoint for the energy
            e_detected = e

            if e_detected < 0.
                error("Detected energy is non-positive for energy $e keV")
            end

            bin_index = findfirst(x -> x >= e_detected, energy_events.energy)
            if isnothing(bin_index) || bin_index == 1
                # error("Detected energy $e_detected MeV is out of bounds for the defined energy range.")
                print("Detected energy $e_detected keV is out of bounds for the defined energy range. Skipping this event.\r")
                continue
            end
            bin_index -= 1  # minを超えた直後は1にしたいのでずらす
            # energy_events.events[bin_index] += flux[i] * area * magnification * dE # エネルギーで積分
            energy_events.events[bin_index] += Crab_photon_flux(e_detected) * area * magnification * dE
        end

        energy_keV = (energy_events.energy[1:end-1] + energy_events.energy[2:end]) * 0.5
        events = energy_events.events[1:end-1] .* exposure_time
        events_sum = sum(events)

        l = stairs!(ax, energy_keV, events,
            label=label, step=:center)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts)}"

    elseif type == :line
        energy_keV = range(10, stop=bin_max, length=n_bin)
        flux = Crab_photon_flux(energy_keV)
        events = flux .* (area * magnification * exposure_time)
        events_sum = sum(events) * (energy_keV[2] - energy_keV[1])  # Total events

        l = lines!(ax, energy_keV, events,
            label=label, linewidth=1.5)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts\ keV^{-1})}"
    else
        error("Unsupported plot type: $type")
    end
    ax.xlabel = L"\mathrm{Detected\ energy\ (keV)}"
    color !== :auto && (l.color = color)

    l, events_sum
end


function plot_detected_events_photon_angle!(ax, energy, latitude, longitude, zenith; altitude=20.0, n_bin=64, area=100., label="", color=:auto, bin_max=20.0, type=:line, exposure_time=1000.0)
    s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

    println("Calculating detected events for photon within zenith angle $zenith...")

    # flux = get_fluxmean_angle.(Ref(latitude), Ref(longitude), altitude, energy, s, Ref(zenith))
    get_flux(e) = get_fluxmean_angle(latitude, longitude, altitude, e, s, zenith)
    energy_events = StructArray{EnergyEvents}(energy=range(1e-2, stop=bin_max, length=n_bin), events=zeros(n_bin))

    for i in 1:lastindex(energy)-1
        dE = energy[i+1] - energy[i]
        e = energy[i] + dE * 0.5  # Use the midpoint for the energy
        e_detected = e

        if e_detected < 0.
            error("Detected energy is non-positive for energy $e MeV")
        end

        bin_index = findfirst(x -> x >= e_detected, energy_events.energy)
        if isnothing(bin_index) || bin_index == 1
            # error("Detected energy $e_detected MeV is out of bounds for the defined energy range.")
            print("Detected energy $e_detected MeV is out of bounds for the defined energy range. Skipping this event.\r")
            continue
        end
        bin_index -= 1  # minを超えた直後は1にしたいのでずらす
        # energy_events.events[bin_index] += flux[i] * area * dE # エネルギーで積分
        energy_events.events[bin_index] += get_flux(e_detected) * area * dE
    end

    energy_keV = (energy_events.energy[1:end-1] + energy_events.energy[2:end]) * 0.5 * 1e3  # Convert energy to keV
    events = energy_events.events[1:end-1] .* exposure_time
    events_sum = sum(events)

    if type == :stairs
        l = stairs!(ax, energy_keV, events,
            label=label, step=:center)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts)}"
    elseif type == :line
        bar_width_keV = (bin_max - 1e-2) / n_bin * 1e3
        println(bar_width_keV)
        events ./= bar_width_keV
        l = lines!(ax, energy_keV, events,
            label=label, linewidth=1.5)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts\ keV^{-1})}"
    else
        error("Unsupported plot type: $type")
    end
    ax.xlabel = L"\mathrm{Detected\ energy\ (keV)}"
    color !== :auto && (l.color = color)

    l, events_sum
end

function plot_detected_events_photon_albedo_crab!(ax, energy, latitude, longitude; altitude=20.0, n_bin=64, area=100., label="", color=:auto, bin_max=20.0, type=:line, magnification=1.0, exposure_time=1000.0)
    s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

    println("Calculating detected events for Crab and albedo photon...")

    bin_max *= 1e3
    energy_MeV = energy
    energy *= 1e3 # Convert to keV

    events_sum = 0.0

    if type == :stairs
        flux_albedo = get_fluxmean.(Ref(latitude), Ref(longitude), altitude, energy_MeV, s)
        flux_albedo *= 1e-3 # (/cm^2/s/(MeV/n)) -> (/cm^2/s/(keV/n))
        flux_crab = Crab_photon_flux(energy)
        albedo_photon_flux(e_keV) = get_fluxmean(latitude, longitude, altitude, e_keV * 1e-3, s) * 1e-3

        # energy [keV], bin_max [keV]
        energy_events = StructArray{EnergyEvents}(energy=range(10, stop=bin_max, length=n_bin), events=zeros(n_bin))

        for i in 1:lastindex(energy)-1
            dE = energy[i+1] - energy[i]
            e = energy[i] + dE * 0.5  # Use the midpoint for the energy
            e_detected = e

            if e_detected < 0.
                error("Detected energy is non-positive for energy $e keV")
            end

            bin_index = findfirst(x -> x >= e_detected, energy_events.energy)
            if isnothing(bin_index) || bin_index == 1
                # error("Detected energy $e_detected MeV is out of bounds for the defined energy range.")
                print("Detected energy $e_detected keV is out of bounds for the defined energy range. Skipping this event.\r")
                continue
            end
            bin_index -= 1  # minを超えた直後は1にしたいのでずらす
            # energy_events.events[bin_index] += (flux_albedo[i] + flux_crab[i] * magnification) * area * dE # エネルギーで積分
            energy_events.events[bin_index] += (albedo_photon_flux(e_detected) + Crab_photon_flux(e_detected) * magnification) * area * dE
        end

        energy_keV = (energy_events.energy[1:end-1] + energy_events.energy[2:end]) * 0.5
        events = energy_events.events[1:end-1] .* exposure_time
        events_sum = sum(events)

        println(energy_events.energy)
        l = stairs!(ax, energy_keV, events,
            label=label, step=:center)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts)}"

    elseif type == :line
        energy_keV = range(energy[1], stop=bin_max, length=n_bin)
        flux_crab = Crab_photon_flux(energy_keV)
        flux_albedo = get_fluxmean.(Ref(latitude), Ref(longitude), altitude, energy_keV * 1e-3, s)
        flux_albedo *= 1e-3 # (/cm^2/s/(MeV/n)) -> (/cm^2/s/(keV/n))
        events = (flux_albedo + flux_crab .* magnification) .* (area * exposure_time)
        events_sum = sum(events) * (energy_keV[2] - energy_keV[1])  # Total events

        l = lines!(ax, energy_keV, events,
            label=label, linewidth=1.5)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts\ keV^{-1})}"
    else
        error("Unsupported plot type: $type")
    end
    ax.xlabel = L"\mathrm{Detected\ energy\ (keV)}"
    color !== :auto && (l.color = color)

    l, events_sum
end
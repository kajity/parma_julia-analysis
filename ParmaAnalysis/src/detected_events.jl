using DataFrames
using Interpolations
using StructArrays
using Base.Threads

struct EnergyEvents
    energy::Float64
    events::Float64
end


function plot_detected_events!(ax, energy, latitude, longitude, material::Symbol, target::Symbol; x_end=20., altitude=20.0, n_bin=64, area=100., label="", color=:auto, dx=0.000005, iteration=nothing, thickness=15.0, bin_max=20.0, type=:histogram)
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
    events = energy_events.events[1:end-1]

    if type == :histogram
        l = barplot!(ax, energy_keV, events,
            label=label)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts s^{-1})}"
    elseif type == :line
        bar_width_keV = (bin_max - 1e-2) / n_bin * 1e3
        energy_events.events ./= bar_width_keV
        l = lines!(ax, energy_keV, events,
            label=label, linewidth=1.5)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts\ s^{-1}\ keV^{-1})}"
    else
        error("Unsupported plot type: $type")
    end
    ax.xlabel = L"\mathrm{Detected\ energy\ (keV)}"
    color !== :auto && (l.color = color)

    l
end

function plot_detected_events_photon!(ax, energy, latitude, longitude; altitude=20.0, n_bin=64, area=100., label="", color=:auto, bin_max=20.0, type=:histogram)
    s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

    flux = get_fluxmean.(Ref(latitude), Ref(longitude), altitude, energy, s)
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
        energy_events.events[bin_index] += flux[i] * area * dE # エネルギーで積分
        # energy_events.events[bin_index] += 1
    end

    energy_keV = (energy_events.energy[1:end-1] + energy_events.energy[2:end]) * 0.5 * 1e3  # Convert energy to keV
    events = energy_events.events[1:end-1]

    if type == :histogram
        l = barplot!(ax, energy_keV, events,
            label=label)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts s^{-1})}"
    elseif type == :line
        bar_width_keV = (bin_max - 1e-2) / n_bin * 1e3
        println(bar_width_keV)
        events ./= bar_width_keV
        l = lines!(ax, energy_keV, events,
            label=label, linewidth=1.5)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts\ s^{-1}\ keV^{-1})}"
    else
        error("Unsupported plot type: $type")
    end
    ax.xlabel = L"\mathrm{Detected\ energy\ (keV)}"
    color !== :auto && (l.color = color)

    l
end

function plot_detected_events_crab!(ax, energy; altitude=20.0, n_bin=64, area=100., label="", color=:auto, bin_max=20.0, type=:histogram)
    s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

    energy *= 1e3
    bin_max *= 1e3
    flux = Crab_photon_flux(energy)
    # energy [keV], bin_max [keV]
    energy_events = StructArray{EnergyEvents}(energy=range(1e-2, stop=bin_max, length=n_bin), events=zeros(n_bin))

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
        energy_events.events[bin_index] += flux[i] * area * dE # エネルギーで積分
        # energy_events.events[bin_index] += 1
    end

    energy_keV = (energy_events.energy[1:end-1] + energy_events.energy[2:end]) * 0.5
    events = energy_events.events[1:end-1]

    if type == :histogram
        l = barplot!(ax, energy_keV, events,
            label=label)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts\ s^{-1})}"
    elseif type == :line
        bar_width_keV = (bin_max - 1e-2) / n_bin
        events ./= bar_width_keV
        l = lines!(ax, energy_keV, events,
            label=label, linewidth=1.5)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts\ s^{-1}\ keV^{-1})}"
    else
        error("Unsupported plot type: $type")
    end
    ax.xlabel = L"\mathrm{Detected\ energy\ (keV)}"
    color !== :auto && (l.color = color)

    l
end


function plot_detected_events_photon_angle!(ax, energy, latitude, longitude, zenith; altitude=20.0, n_bin=64, area=100., label="", color=:auto, bin_max=20.0, type=:histogram)
    s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

    flux = get_fluxmean_angle.(Ref(latitude), Ref(longitude), altitude, energy, s, Ref(zenith))
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
        energy_events.events[bin_index] += flux[i] * area * dE # エネルギーで積分
        # energy_events.events[bin_index] += 1
    end

    energy_keV = (energy_events.energy[1:end-1] + energy_events.energy[2:end]) * 0.5 * 1e3  # Convert energy to keV
    events = energy_events.events[1:end-1]

    if type == :histogram
        l = barplot!(ax, energy_keV, events,
            label=label)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts s^{-1})}"
    elseif type == :line
        bar_width_keV = (bin_max - 1e-2) / n_bin * 1e3
        println(bar_width_keV)
        events ./= bar_width_keV
        l = lines!(ax, energy_keV, events,
            label=label, linewidth=1.5)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts\ s^{-1}\ keV^{-1})}"
    else
        error("Unsupported plot type: $type")
    end
    ax.xlabel = L"\mathrm{Detected\ energy\ (keV)}"
    color !== :auto && (l.color = color)

    l
end
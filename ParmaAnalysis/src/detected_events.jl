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

    energy_keV, events, events_sum = get_binned_events_data(energy, latitude, longitude, target; material=material, altitude=altitude, n_bin=n_bin, area=area, dx=dx, iteration=iteration, thickness=thickness, bin_max=bin_max, exposure_time=exposure_time)

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

    if type == :stairs
        energy_keV, events, events_sum = get_binned_events_data(energy, latitude, longitude, :photon; altitude=altitude, n_bin=n_bin, area=area, bin_max=bin_max, exposure_time=exposure_time)

        l = stairs!(ax, energy_keV, events,
            label=label, step=:center)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts)}"
    elseif type == :line
        energy_tmp = range(1e-2, stop=bin_max, length=n_bin)
        energy_MeV = (energy_tmp[1:end-1] .+ energy_tmp[2:end]) .* 0.5
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


    if type == :stairs
        energy_keV, events, events_sum = get_binned_events_data(energy, [], [], :Crab; altitude=altitude, n_bin=n_bin, area=area, bin_max=bin_max, exposure_time=exposure_time)
        println(energy_keV)
        events .*= magnification

        l = stairs!(ax, energy_keV, events,
            label=label, step=:center)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts)}"

    elseif type == :line
        energy_tmp = range(10, stop=bin_max * 1e3, length=n_bin)
        energy_keV = (energy_tmp[1:end-1] .+ energy_tmp[2:end]) .* 0.5
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
    events_sum = 0.0

    if type == :stairs
        energy_keV, events_Crab, events_sum_Crab = get_binned_events_data(energy, latitude, longitude, :Crab; altitude=altitude, n_bin=n_bin, area=area, bin_max=bin_max, exposure_time=exposure_time)
        _, events_albedo, events_sum_albedo = get_binned_events_data(energy, latitude, longitude, :photon; altitude=altitude, n_bin=n_bin, area=area, bin_max=bin_max, exposure_time=exposure_time)
        events = events_Crab .* magnification .+ events_albedo
        events_sum = events_sum_Crab * magnification + events_sum_albedo

        l = stairs!(ax, energy_keV, events,
            label=label, step=:center)
        ax.ylabel = L"\mathrm{Detected\ events\ (counts)}"

    elseif type == :line
        energy_tmp = range(10, stop=bin_max * 1e3, length=n_bin)
        energy_keV = (energy_tmp[1:end-1] .+ energy_tmp[2:end]) .* 0.5
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


function get_binned_events_data(energy, latitude, longitude, target::Symbol; material::Symbol=:auto, altitude=20.0, n_bin=64, area=100., dx=0.000005, iteration=nothing, thickness=15.0, bin_max=20.0, exposure_time=1000.0)
    s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)
    energy_keV = []
    events = []
    events_sum = 0.0

    get_flux = if target == :Crab
        e -> Crab_photon_flux(e * 1e3) * 1e3 # Convert keV to MeV
    elseif target in [:p, :e, :photon]
        e -> get_fluxmean(latitude, longitude, altitude, e, s, target == :p ? 1 : target == :e ? 31 : 33)
    else
        e -> get_fluxmean(latitude, longitude, altitude, e, s)
    end

    energy_detected = if target == :Crab || target == :photon
        e -> e
    else
        if target == :p
            if material == :auto
                material = :silver
            end
        elseif target == :e
            if material == :auto
                material = :cadmium
            end
        end
        stopping_power = get_stopping_power(material, target)
        S_interp = interpolate((stopping_power.E,), stopping_power.e, Gridded(Linear()))
        S = extrapolate(S_interp, Linear())
        e_min = minimum(stopping_power.E)
        e -> begin
            (_, e_end, _) = path_length(S, e, e_min; dx=dx, iteration=iteration, x_max=thickness)
            e - e_end
        end
    end

    println("Calculating detected events for $target with material $material...")
    energy_events = StructArray{EnergyEvents}(energy=range(1e-2, stop=bin_max, length=n_bin), events=zeros(n_bin))

    for i in 1:lastindex(energy)-1
        dE = energy[i+1] - energy[i]
        e = energy[i] + dE * 0.5  # Use the midpoint for the energy
        e_detected = energy_detected(e)

        if e_detected < 0.
            error("Detected energy is non-positive for energy $e MeV")
        end

        bin_index = findfirst(x -> x >= e_detected, energy_events.energy)
        if isnothing(bin_index) || bin_index == 1
            print("\r$target : Detected energy $e_detected MeV is out of bounds for the defined energy range. Skipping this event.")
            continue
        end
        bin_index -= 1  # minを超えた直後は1にしたいのでずらす
        energy_events.events[bin_index] += get_flux(e_detected) * area * dE
    end
    println("")

    energy_keV = (energy_events.energy[1:end-1] + energy_events.energy[2:end]) / 2 * 1e3  # Convert energy to keV
    events = energy_events.events[1:end-1] .* exposure_time
    events_sum = sum(events)

    return energy_keV, events, events_sum
end



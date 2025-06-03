using DataFrames
using Interpolations
using StructArrays

struct EnergyEvents
    energy::Float64
    events::Float64
end


function plot_detected_events!(ax, energy, latitude, longitude, material::String; altitude=20.0, n_bin=64, exposure_time = 1000., area = 100., label="", color=:auto, dx=0.000005, iteration=nothing, x_max=15.0)
    s = getHP(iyear[], imonth[], iday[]) # W-index (solar activity)

    flux = get_fluxmean.(Ref(latitude), Ref(longitude), altitude, energy, s)

    stopping_power = get_stopping_power(material)
    S = interpolate((stopping_power.E,), stopping_power.e, Gridded(Linear()))
    e_min = minimum(stopping_power.E)

    energy_events = StructArray{EnergyEvents}(energy=range(energy[1], stop=20., length=n_bin), events=zeros(n_bin))

    for i in 1:lastindex(energy)-1
        dE = energy[i+1] - energy[i]
        e = energy[i] + dE * 0.5  # Use the midpoint for the energy
        (_, e_end, _) = path_length(S, e, e_min; dx=dx, iteration=iteration, x_max=x_max)
        e_detected = e - e_end

        if e_detected < 0.
            error("Detected energy is non-positive for energy $e MeV")
        end

        bin_index = findfirst(x -> x >= e_detected, energy_events.energy)
        if isnothing(bin_index)
            error("Detected energy $e_detected MeV is out of bounds for the defined energy range.")
        end
        bin_index -= 1  # minを超えた直後は1にしたいのでずらす
        energy_events.events[bin_index] += flux[i] * exposure_time * area * dE # エネルギーで積分
    end

    l = barplot!(ax, energy_events.energy, energy_events.events,
        label=label)
    ax.xlabel = L"\mathrm{Energy\ (MeV)}"
    ax.ylabel = L"\mathrm{Detected\ events\ (counts)}"
    l.color = color == :auto ? l.color : color
end

module ParmaAnalysis
__precompile__()

include("parma_wrapper.jl")
include("variables.jl")
include("utils.jl")
include("stopping_power.jl")
include("heatmap_wrapper.jl")
include("crab_flux.jl")
include("flux_coordinate_heatmap.jl")
include("flux_altitude_heatmap.jl")
include("flux_line.jl")
include("energy_loss.jl")
include("detected_events.jl")

export plot_coordinate!
export plot_longalti!
export plot_latalti!
export plot_energy_flux!
export plot_height_flux!
export plot_angle_factor_flux!
export plot_angle_flux!
export plot_energyloss!
export plot_detected_energy!
export search_extremum_detected_energy
export plot_stopping_power!
export plot_detected_events!
export plot_detected_events_photon!
export plot_detected_events_crab!
export plot_Crab_photon_flux!
export plot_detected_events_photon_angle!
export plot_detected_events_photon_albedo_crab!
export get_binned_events_data

end # module ParmaAnalysis

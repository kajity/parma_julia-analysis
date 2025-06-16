module ParmaAnalysis
__precompile__()

include("parma_wrapper.jl")
include("variables.jl")
include("utils.jl")
include("stopping_power.jl")
include("heatmap_wrapper.jl")
include("flux_coordinate_heatmap.jl")
include("flux_altitude_heatmap.jl")
include("flux_energy_line.jl")
include("energy_loss.jl")
include("detected_events.jl")

export plot_coordinate!
export plot_longalti!
export plot_latalti!
export plot_energy_flux!
export plot_energyloss!
export plot_detected_energy!
export search_extremum_detected_energy
export plot_stopping_power!
export plot_detected_events!

end # module ParmaAnalysis

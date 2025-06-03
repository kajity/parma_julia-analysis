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
include("flux_detected.jl")

export plot_coordinate!
export plot_longalti!
export plot_latalti!
export plot_energy_flux!
export plot_energyloss_p!
export plot_detected_energy!
export plot_detected_events!

end # module ParmaAnalysis

module ParmaAnalysis
__precompile__()

include("parma_wrapper.jl")
include("variables.jl")
include("utils.jl")
include("heatmap_wrapper.jl")
include("flux_coordinate_heatmap.jl")
include("flux_altitude_heatmap.jl")
include("energy_loss.jl")

export plot_coordinate!
export plot_longalti!
export plot_latalti!
export plot_energyloss_p!

end # module ParmaAnalysis

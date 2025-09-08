using DataFrames

# e p albedo albedo_angle crab 
events = [3240.481009302022, 0.4462023982771433, 425998.4845697032, 196.11115645007376, 57191.93994481129]

events = round.(events, digits=1)
println(events)
println(sum(events))

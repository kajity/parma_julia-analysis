using DataFrames

# e p albedo crab 
events = [3240.481009302022, 0.4462023982771433, 425998.4845697032, 57191.93994481129]
events_angle = [1.941768514032379, 0.0002567263972843305, 196.11115645007376, 57191.93994481129]

events = round.(events, sigdigits=3)
println(events)
println(sum(events))
events_angle = round.(events_angle, sigdigits=3)
println(events_angle)
println(sum(events_angle))

df = DataFrame(vcat([events', events_angle']...), [:e, :p, :albedo, :crab])
df.bg = df.e + df.p + df.albedo
df.total = df.e + df.p + df.albedo + df.crab

Z = df[1, :crab] ./ sqrt.(df[1, :bg])
Z_angle = df[2, :crab] ./ sqrt.(df[2, :bg])
println("Z = $Z")
println("Z_angle = $Z_angle")

t = 1e3 * (5 / Z)^2
t_angle = 1e3 * (5 / Z_angle)^2
println("t = $t")
println("t_angle = $t_angle")

push!(df, df[1, :])
push!(df, df[1, :])
for col in names(df)
  df[3, col] *= t / 1000.
end
for col in names(df)
  df[4, col] *= t_angle / 1000.
end

# Z_angle2 = df[3, :crab] ./ sqrt.(df[3, :bg])
# println("Z_angle2 = $Z_angle2")
df
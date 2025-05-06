a = zeros(Int, 10)
Threads.@threads for i = 1:10
  a[i] = Threads.threadid()
end
println(a)

i = Ref{Int}(0)
ids = zeros(4)
old_is = zeros(4)

Threads.@threads for id in 1:4
  old_is[id] = i[]
  i[] += id
  ids[id] = id
end

println(old_is)
println(ids)

atomicI = Threads.Atomic{Int}(0)
Threads.@threads for id in 1:4
  old_is[id] = Threads.atomic_add!(atomicI, id)
  ids[id] = id
end
println(old_is)
println(ids)
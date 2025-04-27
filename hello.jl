@time println("Hello, World!")
@time println("This is a Julia script.")

function fibonacci(n)
  a::BigInt = b::BigInt = 1
  # a = b = 1
  for i in 3:n
    a, b = b, a + b
  end
  return b
end

@time a = fibonacci(1000)
@time println(a, "\n")

println(pwd())
parma = () -> @ccall "./build/libparma-main.so".main()::Cint
println(parma())
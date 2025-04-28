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

libparma_main = "./build/libparma-main.so"
libparma = "./build/libparma.so"

println(pwd())
parma = () -> @ccall libparma_main.main()::Cint
println(parma())
parma = (s::Cdouble) -> @ccall libparma.getFFPfromWCpp(s::Cdouble)::Cdouble
println(parma(3.555))
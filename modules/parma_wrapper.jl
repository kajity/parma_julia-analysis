module Parma
export getHP, getr, getd, getSpec, getSpecAngFinal

parma = joinpath(@__DIR__, "..", "build", "libparma.so")

getHPcpp(year::Cint, month::Cint, day::Cint) = @ccall parma.getHPcpp(year::Cint, month::Cint, day::Cint)::Cdouble
getrcpp(glat::Cdouble, glong::Cdouble) = @ccall parma.getrcpp(glat::Cdouble, glong::Cdouble)::Cdouble
getdcpp(alti::Cdouble, glat::Cdouble) = @ccall parma.getdcpp(alti::Cdouble, glat::Cdouble)::Cdouble
getSpecCpp(ip::Cint, s::Cdouble, r::Cdouble, d::Cdouble, e::Cdouble, g::Cdouble) = @ccall parma.getSpecCpp(ip::Cint, s::Cdouble, r::Cdouble, d::Cdouble, e::Cdouble, g::Cdouble)::Cdouble
getSpecAngFinalCpp(ip::Cint, s::Cdouble, r::Cdouble, d::Cdouble, e::Cdouble, g::Cdouble, ang::Cdouble) = @ccall parma.getSpecAngFinalCpp(ip::Cint, s::Cdouble, r::Cdouble, d::Cdouble, e::Cdouble, g::Cdouble, ang::Cdouble)::Cdouble

getHP(year::Integer, month::Integer, day::Integer) = getHPcpp(Cint(year), Cint(month), Cint(day))
getr(glat::Float64, glong::Float64) = getrcpp(Cdouble(glat), Cdouble(glong))
getd(alti::Float64, glat::Float64) = getdcpp(Cdouble(alti), Cdouble(glat))
getSpec(ip::Integer, s::Float64, r::Float64, d::Float64, e::Float64, g::Float64) = getSpecCpp(Cint(ip), Cdouble(s), Cdouble(r), Cdouble(d), Cdouble(e), Cdouble(g))
getSpecAngFinal(ip::Integer, s::Float64, r::Float64, d::Float64, e::Float64, g::Float64, ang::Float64) = getSpecAngFinalCpp(Cint(ip), Cdouble(s), Cdouble(r), Cdouble(d), Cdouble(e), Cdouble(g), Cdouble(ang))
end # module Parma
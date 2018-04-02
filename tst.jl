using StaticPolynomials
const SP = StaticPolynomials
import MultivariatePolynomials
const MP = MultivariatePolynomials
using BenchmarkTools
using StaticArrays
import TestSystems
import DynamicPolynomials: @polyvar



F = SP.system(TestSystems.equations(TestSystems.rps10()))





struct TupleSystem2{T, N, Tup}
   polynomials::Tup
end


function TupleSystem(polys::AbstractVector{<:MP.AbstractPolynomial{T}}) where T
    variables = sort!(union(Iterators.flatten(MP.variables.(polys))), rev=true)
    N = length(variables)
    TupleSystem{T, N}(tuple(map(p -> Polynomial(p, variables), polys)...))
end
TupleSystem(TestSystems.rps10())

function make_tuple(polys::AbstractVector{<:MP.AbstractPolynomial{T}}) where T
    variables = sort!(union(Iterators.flatten(MP.variables.(polys))), rev=true)
    N = length(variables)
    tuple(map(p -> Polynomial(p, variables), polys)...)
end
tup = make_tuple(TestSystems.equations(TestSystems.rps10()))

G = TupleSystem2{Float64, 10, typeof(tup)}(tup)

function tuple_evaluate(system::TupleSystem2{T, N}, x::SVector{N, S}) where {T, S, N}
    F = system.polynomials
    @inbounds out = SVector(SP.evaluate(F[1], x),
        SP.evaluate(F[2], x),
        SP.evaluate(F[3], x),
        SP.evaluate(F[4], x),
        SP.evaluate(F[5], x),
        SP.evaluate(F[6], x),
        SP.evaluate(F[7], x),
        SP.evaluate(F[8], x),
        SP.evaluate(F[9], x),
        SP.evaluate(F[10], x))
    out
end

w = @SVector rand(Complex128, 10)

@btime tuple_evaluate($G, $w)
@btime SP.evaluate($F, $w)


@time jacobian(F, z)

@time jacobian()


@edit @evalpoly 2.3im 2 3



@goertzel w c0 c1

# TODO what is if poly has less than degree 4???
c0, c1, c2, c3, c4, c5 = rand( 6)
w = rand(Complex128)
true_val = c0 + c1 * w# + c2 * w^2 #+ c3 * w^3 + c4 * w^4 + c5 * w^5
true_dval = c1 #+ 2 * c2 * w #+ 3 * c3 * w^2 + 4 * c4 * w^3 + 5 * c5 * w^4


val, dval = @goertzel_deriv w c0 c1 c2 c3 c4 c5
@inline t(w, c0, c1, c2, c3) = @goertzel_deriv w c0 c1 c2 c3
@btime
@code_native t(w, c0, c1, c2)
@benchmark t($w, $c0, $c1, $c2, $c3)
dval * 2 * im * imag(w)

im*2 * imag(w) * dval + r1

t2(a, b) = zero(a) + a * b
@benchmark t2($c1, $c2)


e4 = 0.42893345173666364
e3 = 1.359244601085318
e2 = 1.9109472271887789
e1 = 2.63096635953986
r1 = 3.802933785884684

w^3*e4 + w^2*e3 + w*e2 + e1









tt = z
x = real(tt)
y = imag(tt)
r = x + x
s = -(x * x + y * y)
a2 = c3
a1 = r * a2 + c2
a0 = r * a1 + (s * a2 + c1)
a0 * tt + (s * a1 + c0)

@goertzel z c0 c1 c2 c3
let #1482#tt = z # /Users/sascha/coding/julia/StaticPolynomials/tst.jl, line 31: 
    begin 
        #1476#x = (Main.real)(#1482#tt) 
        #1477#y = (Main.imag)(#1482#tt) 
        #1478#r = #1476#x + #1476#x 
        #1479#s = -((Main.muladd)(#1476#x, #1476#x, #1477#y * #1477#y)) 
        #1480#a1 = c2 
        #1481#a0 = (Main.muladd)(#1478#r, #1480#a1, c1) 
        (Main.muladd)(#1481#a0, #1482#tt, (Main.muladd)(#1479#s, #1480#a1, c0)) 
    end
end





goertzel([2, 3, 4, 5])

x1, x2, x3, x4, x5, x6 = rand(6)
@inline function test1(z, x1, x2, x3, x4, x5, x6)
   @goertzel z x1 x2 x3 x4 x5 x6
end

@inline function test2(z, x1, x2, x3, x4, x5, x6)
   @evalpoly z x1 x2 x3 x4 x5 x6
end

function test2(z)
   @evalpoly2 z 2 3 5 6
end
z = rand(Complex128)
@btime test1($z, $x1, $x2, $x3, $x4, $x5, $x6)
@btime test2($z, $x1, $x2, $x3, $x4, $x5, $x6)

z = rand(Complex128)
@code_native test2(z)

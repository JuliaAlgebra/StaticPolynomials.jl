using StaticPolynomials
const SP = StaticPolynomials
using StaticArrays
import DynamicPolynomials: @polyvar
import MultivariatePolynomials
const MP = MultivariatePolynomials
using Compat
using Compat.Test
using Compat.LinearAlgebra

include("codegen_tests.jl")
include("basic_tests.jl")
include("evaluation_tests.jl")
include("gradient_tests.jl")

A = [1 3 3; 0 2 3]

isbits(SP.SExponents(A))

@polyvar x y

f = Polynomial(x^2+y^2+2y*x-3x^3*y)
w = rand(2)
SP.evaluate(f,w)

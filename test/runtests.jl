using StaticPolynomials
const SP = StaticPolynomials
using StaticArrays
import DynamicPolynomials: @polyvar
import MultivariatePolynomials
const MP = MultivariatePolynomials
using Compat.Test
using Compat.LinearAlgebra

include("codegen_tests.jl")
include("basic_tests.jl")
include("evaluation_tests.jl")
include("gradient_tests.jl")

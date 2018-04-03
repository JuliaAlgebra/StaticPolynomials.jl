using StaticPolynomials
const SP = StaticPolynomials
using Base.Test
using StaticArrays
import DynamicPolynomials: @polyvar
import MultivariatePolynomials
const MP = MultivariatePolynomials
import TestSystems


include("codegen_tests.jl")
include("basic_tests.jl")
include("evaluation_tests.jl")
include("gradient_tests.jl")

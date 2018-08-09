import MultivariatePolynomials
const MP = MultivariatePolynomials
import DynamicPolynomials: @polyvar
using StaticPolynomials
const SP = StaticPolynomials
using StaticArrays
using Test
using LinearAlgebra

include("codegen_tests.jl")
include("basic_tests.jl")
include("gradient_tests.jl")
include("evaluation_tests.jl")

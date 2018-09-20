import MultivariatePolynomials
const MP = MultivariatePolynomials
import DynamicPolynomials: @polyvar
using StaticPolynomials
const SP = StaticPolynomials
using StaticArrays
using Test
using LinearAlgebra


@testset "StaticPolynomials" begin
    include("codegen_tests.jl")
    include("basic_tests.jl")
    include("system_evaluation_tests.jl")
end

using StaticPolynomials
const SP = StaticPolynomials
using Base.Test
import DynamicPolynomials: @polyvar
using StaticArrays

@testset "evaluate_codegen low_level" begin
    @test SP.monomial_product([2, 3, 4], 5) == :(c[5] * x[1]^2 * x[2]^3 * x[3]^4)
    @test SP.monomial_product([2, 3, 4], 1) == :(c[1] * x[1]^2 * x[2]^3 * x[3]^4)
    @test SP.monomial_product([2, 3], 12) == :(c[12] * x[1]^2 * x[2]^3)
    @test SP.generate_evaluate([2 3 4]', Float64) == quote c[1] * x[1]^2 * x[2]^3 * x[3]^4 end

    @test SP.generate_evaluate(reshape([1 2 3], 1, 3), Float64) ==
        quote @evalpoly x[1] zero($Float64) c[1] c[2] c[3] end

    @test SP.generate_evaluate(reshape([2 5], 1, 2), Float64) ==
        quote
            @evalpoly x[1] zero($Float64) zero($Float64) c[1] zero($Float64) zero($Float64) c[2]
        end

    E = [ 4  4  1  3  5
          2  4  2  2  5
          0  1  2  2  2 ]
    degrees, subs = SP.degrees_submatrices(E)
    @test length(degrees) == 3
    @test degrees == [0, 1, 2]

    degrees2, subs2 = SP.degrees_submatrices(subs[3])
    @test subs2 == [[1 3], reshape([5], 1, 1)]
    @test degrees2 == [2, 5]
end

@testset "constructors" begin
    A = round.(Int, max.(0.0, 5 * rand(6, 10) - 1))
    f = Polynomial(rand(10), A)
    @test typeof(f) <: Polynomial{Float64, 6, <:SExponents}

    @test_throws AssertionError Polynomial(rand(9), A)

    @polyvar x y
    f2 = Polynomial(2x^2+4y^2+3x*y+1)
    @test exponents(f2) == [0 2 1 0; 0 0 1 2]
    @test nvariables(f2) == 2
    @test coefficients(f2) == [1, 2, 3, 4]
    @test coefficienttype(f2) == Int64
    f2_2 = Polynomial(2x^2+4y^2+3x*y+1)
    @test f2 == f2_2
end

@testset "system constructor" begin
    @polyvar x y
    f1 = x^2+y^2
    f2 = 2x^2+4y^2+3x*y^4+1
    g1 = Polynomial(f1)
    g2 = Polynomial(f2)
    @test SP.system(g1, g2) isa SP.AbstractSystem{Int64, 2, 2}
    @test SP.system(g1, g2, g2) isa SP.AbstractSystem{Int64, 3, 2}
    @test SP.system([f1, f2, y, x]) isa SP.AbstractSystem{Int64, 4, 2}
    @test coefficienttype(SP.system(g1, g2)) == Int64
end

@testset "evaluation" begin
    @polyvar x y
    f2 = 2x^2+4y^2+3x*y^4+1
    g = Polynomial(f2)
    w = rand(2)

    @test abs(SP.evaluate(g, w) - f2(x => w[1], y => w[2])) < 1e-15
end

@testset "system evaluation" begin
    @polyvar x y
    f1 = x^2+y^2
    f2 = 2x^2+4y^2+3x*y^4+1
    g1 = Polynomial(f1)
    g2 = Polynomial(f2)

    G = system(g1, g2)

    w = rand(2)
    @test [evaluate(g1, w), evaluate(g2, w)] == evaluate(G, w)

    w = SVector{2}(w)
    @test evaluate(G, w) isa SVector{2}
    @test [evaluate(g1, w), evaluate(g2, w)] == evaluate(G, w)
end

include("evaluation_tests.jl")
include("gradient_tests.jl")

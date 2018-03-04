using StaticPolynomials
const SP = StaticPolynomials
using Base.Test
import DynamicPolynomials: @polyvar


@testset "evaluate_codegen low_level" begin
    @test SP.monomial_product([2, 3, 4], 5) == :(c[5] * x[1]^2 * x[2]^3 * x[3]^4)
    @test SP.monomial_product([2, 3, 4], 1) == :(c[1] * x[1]^2 * x[2]^3 * x[3]^4)
    @test SP.monomial_product([2, 3], 12) == :(c[12] * x[1]^2 * x[2]^3)
    @test SP.generate_evaluate([2 3 4]', Float64) == :(c[1] * x[1]^2 * x[2]^3 * x[3]^4)

    @test SP.generate_evaluate(reshape([1 2 3], 1, 3), Float64) ==
        :(@evalpoly x[1] zero($Float64) c[1] c[2] c[3])

    @test SP.generate_evaluate(reshape([2 5], 1, 2), Float64) ==
        :(@evalpoly x[1] zero($Float64) zero($Float64) c[1] zero($Float64) zero($Float64) c[2])

    E = [ 4  4  1  3  5
          2  4  2  2  5
          0  1  2  2  2 ]
    submatrices, degrees = SP.create_submatrices_degrees(E)
    @test length(submatrices) == 3
    @test degrees == [0, 1, 2]

    submatrices2, degrees2 = SP.create_submatrices_degrees(submatrices[3])
    @test submatrices2 == [[1 3], reshape([5], 1, 1)]
    @test degrees2 == [2, 5]
end

@testset "constructors" begin
    A = round.(Int, max.(0.0, 5 * rand(6, 10) - 1))
    f = Polynomial(rand(10), A)
    @test typeof(f) <: Polynomial{Float64, <:SExponents{6, 10}}

    @test_throws AssertionError Polynomial(rand(9), A)

    @polyvar x y
    f2 = Polynomial(2x^2+4y^2+3x*y+1)
    @test exponents(f2) == [0 2 1 0; 0 0 1 2]
    @test coefficients(f2) == [1, 2, 3, 4]
end

@testset "evaluation" begin
    @polyvar x y
    f2 = Polynomial(2x^2+4y^2+3x*y+1)
    g = SP.Polynomial(f2)
    w = rand(2)

    @test abs(SP.evaluate(g, w) - f2(x => w[1], y => w[2])) < 1e-15
end

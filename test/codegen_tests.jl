@testset "monomial_product" begin
    @test SP.monomial_product(Float64, [2, 3, 4], :(c[5])) == :(c[5] * x[1]^2 * x[2]^3 * x[3]^4)
    @test SP.monomial_product(Float64, [2, 3, 4], :(c[5]), 2) == :((3 * c[5] * x[1]^2 * x[2]^2) * x[3]^4)

    # optimizations
    # no ^1
    @test SP.monomial_product(Float64, [1, 3, 4], :(c[5])) == :(c[5] * x[1] * x[2]^3 * x[3]^4)
    # omit ^0
    @test SP.monomial_product(Float64, [1, 0, 4], :(c[5])) == :(c[5] * x[1] * x[3]^4)
    @test SP.monomial_product(Float64, [0, 0, 0], :(c[5])) == :(c[5])
    # omit 1 * and ^0
    @test SP.monomial_product(Float64, [1, 3, 4], :(c[5]), 1) == :(c[5] * x[2]^3 * x[3]^4)
    # omit ^1 in derivative
    @test SP.monomial_product(Float64, [2, 2, 4], :(c[5]), 2) == :((2 * c[5] * x[1]^2 * x[2]) * x[3]^4)
end

@testset "evaluate_codegen low_level" begin
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


@testset "evalpoly_deriv" begin
    z = rand(Complex128)
    for T in [Float64, Complex128]
        c0, c1, c2, c3, c4, c5 = rand(T, 6)

        true_val = c0 + c1 * z + c2 * z^2 + c3 * z^3 + c4 * z^4 + c5 * z^5
        true_dval = c1 + 2c2 * z + 3c3 * z^2 + 4c4 * z^3 + 5c5 * z^4
        val, dval = @goertzel_deriv z c0 c1 c2 c3 c4 c5
        @test abs(val - true_val) < 1e-14
        @test abs(dval - true_dval) < 1e-14
        val, dval = @horner_deriv z c0 c1 c2 c3 c4 c5
        @test abs(val - true_val) < 1e-14
        @test abs(dval - true_dval) < 1e-14
        val, dval = @evalpoly_deriv z c0 c1 c2 c3 c4 c5
        @test abs(val - true_val) < 1e-14
        @test abs(dval - true_dval) < 1e-14

        true_val = c0 + c1 * z + c2 * z^2
        true_dval = c1 + 2c2 * z
        val, dval = @goertzel_deriv z c0 c1 c2
        @test abs(val - true_val) < 1e-14
        @test abs(dval - true_dval) < 1e-14
        val, dval = @horner_deriv z c0 c1 c2
        @test abs(val - true_val) < 1e-14
        @test abs(dval - true_dval) < 1e-14

        true_val = c0 + c1 * z
        true_dval = c1
        val, dval = @goertzel_deriv z c0 c1
        @test abs(val - true_val) < 1e-14
        @test abs(dval - true_dval) < 1e-14
        val, dval = @horner_deriv z c0 c1
        @test abs(val - true_val) < 1e-14
        @test abs(dval - true_dval) < 1e-14
    end
end

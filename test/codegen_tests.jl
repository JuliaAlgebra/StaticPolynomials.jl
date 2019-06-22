@testset "Codegen" begin
    @testset "monomial_product" begin
        @test SP.monomial_product(Float64, [2, 3, 1], :(c[5]))[1] == :(c[5] * (x[1] * x[1]) * (x[2] * x[2] * x[2]) * x[3])
        #
        #
        @test SP.monomial_product(Float64, [2, 3, 1], :(c[5]), 2)[1] == :((3 * c[5] * (x[1] * x[1]) * (x[2] * x[2])) * x[3])

        # optimizations
        # no ^1
        @test SP.monomial_product(Float64, [1, 3, 1], :(c[5]))[1] == :(c[5] * x[1] * (x[2] * x[2] * x[2]) * x[3])
        # omit ^0
        @test SP.monomial_product(Float64, [1, 0, 1], :(c[5]))[1] == :(c[5] * x[1] * x[3])
        @test SP.monomial_product(Float64, [0, 0, 0], :(c[5]))[1] == :(c[5])
        # omit 1 * and ^0
        @test SP.monomial_product(Float64, [1, 3, 2], :(c[5]), 1)[1] == :(c[5] * (x[2] * x[2] * x[2]) * (x[3] * x[3]))
        # omit ^1 in derivative
        @test SP.monomial_product(Float64, [2, 2, 2], :(c[5]), 2)[1] == :((2 * c[5] * (x[1] * x[1]) * x[2]) * (x[3] * x[3]))
    end

    @testset "evaluate_codegen low_level" begin
        E = [ 4  4  1  3  5
              2  4  2  2  5
              0  1  2  2  2 ]
        degrees, subs = SP.degrees_submatrices(E)
        @test length(degrees) == 3
        @test degrees == [0, 1, 2]

        degrees2, subs2 = SP.degrees_submatrices(subs[3])
        @test subs2 == [[1 3], reshape([5], 1, 1)]
        @test degrees2 == [2, 5]

        @test SP.pow(:x, 0) == :(one(x))
    end


    @testset "evalpoly_deriv" begin
        z = rand(Complex{Float64})
        tol = 1e-12
        for T in [Float64, Complex{Float64}]
            c0, c1, c2, c3, c4, c5 = rand(T, 6)

            true_val = c0 + c1 * z + c2 * z^2 + c3 * z^3 + c4 * z^4 + c5 * z^5
            true_dval = c1 + 2c2 * z + 3c3 * z^2 + 4c4 * z^3 + 5c5 * z^4
            val, dval = SP.@goertzel_deriv z c0 c1 c2 c3 c4 c5
            @test abs(val - true_val) < tol
            @test abs(dval - true_dval) < tol
            val, dval = SP.@horner_deriv z c0 c1 c2 c3 c4 c5
            @test abs(val - true_val) < tol
            @test abs(dval - true_dval) < tol
            val, dval = SP.@evalpoly_derivative z c0 c1 c2 c3 c4 c5
            @test abs(val - true_val) < tol
            @test abs(dval - true_dval) < tol

            true_val = c0 + c1 * z + c2 * z^2
            true_dval = c1 + 2c2 * z
            val, dval = SP.@goertzel_deriv z c0 c1 c2
            @test abs(val - true_val) < tol
            @test abs(dval - true_dval) < tol
            val, dval = SP.@horner_deriv z c0 c1 c2
            @test abs(val - true_val) < tol
            @test abs(dval - true_dval) < tol

            true_val = c0 + c1 * z
            true_dval = c1
            val, dval = SP.@goertzel_deriv z c0 c1
            @test abs(val - true_val) < tol
            @test abs(dval - true_dval) < tol
            val, dval = SP.@horner_deriv z c0 c1
            @test abs(val - true_val) < tol
            @test abs(dval - true_dval) < tol
        end
    end

    @testset "gradient_codegen" begin
          # bugfix
          @polyvar a b t z
          f = -0.25a^5*t+0.25b^5*t+0.5z^6
          g = Polynomial(f)
          x = rand(4)
          vars = [a, b, t, z]
          @test map(v -> (MP.differentiate(f, v))(vars=>x), vars) ≈ gradient(g, x)
    end

end

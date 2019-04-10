@testset "Basics" begin

    @testset "constructors" begin
        A = round.(Int, max.(0.0, 5 * rand(6, 10) .- 1))
        f = Polynomial(rand(10), A)
        @test typeof(f) <: Polynomial{Float64}

        @test_throws AssertionError Polynomial(rand(9), A)

        @polyvar x y
        f2 = Polynomial(2x^2+4y^2+3x*y+1)
        @test exponents(f2) == [0 2 1 0; 0 0 1 2]
        @test nvariables(f2) == 2
        @test coefficients(f2) == [1, 2, 3, 4]
        @test coefficienttype(f2) == Int64
        f2_2 = Polynomial(2x^2+4y^2+3x*y+1)
        @test f2 == f2_2

        @polyvar x y a b
        f = Polynomial(2x+b*y+a, parameters=[a, b])
        @test f isa Polynomial
        @test nvariables(f) == 2
        @test parameters(f) == [:a, :b]

        @test_throws ErrorException Polynomial(2x+b*y+a, variables=[x], parameters=[a, b])
    end


    @testset "evaluation" begin
        @polyvar x y
        f2 = 2x^2+4y^2+3x*y^4+1
        g = Polynomial(f2)
        w = rand(2)

        @test abs(SP.evaluate(g, w) - f2(x => w[1], y => w[2])) < 1e-13

        f2_x = MP.differentiate(2x^2+4y^2+3x*y^4+1, x)
        f2_y = MP.differentiate(2x^2+4y^2+3x*y^4+1, y)
        @test norm(SP.gradient(g, w) - [f2_x(x => w[1], y => w[2]), f2_y(x => w[1], y => w[2])]) < 1e-13

        u = zeros(2)
        SP.gradient!(u, g, w)
        @test u ≈ SP.gradient(g, w)

        @test all(SP.evaluate_and_gradient(g, w) .≈ (g(w), u))

        @test all(SP.evaluate_and_gradient!(u, g, w) .≈ g(w))
        @test u ≈ SP.gradient(g, w)
    end

    @testset "Evaluation with parameters" begin
        @polyvar x y z a b
        f = 2x^2+4a*y^2+(a^2+b^4+a+b+1)*3x*y^4+1+a*z+b-2x*b^6
        g = Polynomial(f, parameters=[a, b])

        w = [5, 3, -4]
        p = [-2, 7]
        f_wp = f([x, y, z] => w, [a, b] => p)
        ∇_wp = map(fi -> fi([x, y, z] => w, [a, b] => p), MP.differentiate(f, [x, y, z]))
        ∇p_wp = map(fi -> fi([x, y, z] => w, [a, b] => p), MP.differentiate(f, [a, b]))

        @test g(w, p) == f_wp
        @test gradient(g, w,p) == ∇_wp
        @test evaluate_and_gradient(g, w, p) == (f_wp, ∇_wp)
        @test differentiate_parameters(g, w, p) == ∇p_wp

        u = zeros(Int, 3)
        gradient!(u, g, w, p)
        @test u == ∇_wp
        u .= 0
        @test evaluate_and_gradient!(u, g, w, p) == f_wp
        @test u == ∇_wp

        v = zeros(Int, 2)
        differentiate_parameters!(v, g, w, p)
        @test v == ∇p_wp


        f = Polynomial(a + b + x + y, parameters=[a, b])
        @test differentiate_parameters(f, [0, 0], [1, 1]) == [1, 1]

        f = Polynomial(x*y + x + y, parameters=[a, b])
        @test differentiate_parameters(f, [0, 0], [1, 1]) == [0, 0]
    end

    @testset "show" begin
        @polyvar x[0:9]
        @test string(Polynomial(x[1])) == "x₀"
        @test string(Polynomial(sum((-1)^i * x[i]^i for i=1:length(x)))) ==
            "-x₀ + x₁² - x₂³ + x₃⁴ - x₄⁵ + x₅⁶ - x₆⁷ + x₇⁸ - x₈⁹ + x₉¹⁰"
        @test string(Polynomial(2im*x[1] - x[2])) == "(0 + 2im)x₀ - x₁"
        @test sprint(show, Polynomial((2+0im)*x[1] - x[2])) == "2x₀ - x₁"
        @test_nowarn string(typeof(Polynomial(x[1]^2+x[4]^2)))

        @polyvar x a b
        @test sprint(show, Polynomial(x+a^2+b, parameters=[a, b])) == "a² + b + x"
        @test sprint(show, Polynomial(zero(x))) == "0"
    end


    @testset "helpers" begin
        x = rand()
        z = rand(Complex{Float64})
        for k = 4:15
            @test abs(SP.pow(x, k) - x^k) < 1e-13
            @test abs(SP.pow(z, k) - z^k) < 1e-13
        end
    end

    @testset "system constructor" begin
        @polyvar x y
        f1 = x^2+y^2
        f2 = 2x^2+4y^2+3x*y^4+1
        g1 = Polynomial(f1)
        g2 = Polynomial(f2)
        @test_deprecated SP.system(g1, g2)
        @test PolynomialSystem(g1, g2) isa PolynomialSystem{2, 2}
        @test PolynomialSystem(g1, g2, g2) isa PolynomialSystem{3, 2}
        @test PolynomialSystem([f1, f2, y, x]) isa PolynomialSystem{4, 2}
        @test length(SP.PolynomialSystem([f1, f2, y, x])) == 4

        @test_nowarn sprint(show, PolynomialSystem([f1, f2, y, x]))
    end


    @testset "System evaluation and Jacobian" begin
        @polyvar x y
        f1 = x^2+y^2
        f2 = 2x^2+4y^2+3x*y^4+1
        g1 = Polynomial(f1)
        g2 = Polynomial(f2)

        G = PolynomialSystem(g1, g2)

        w = rand(2)
        @test [evaluate(g1, w), evaluate(g2, w)] ≈ evaluate(G, w)
        @test [g1(w), g2(w)] ≈ evaluate(G, w)

        w = SVector{2}(w)
        @test evaluate(G, w) isa SVector{2}
        @test [evaluate(g1, w), evaluate(g2, w)] ≈ evaluate(G, w)

        @test jacobian(G, [2, 3]) == [4 6; 251 672]
        U = zeros(Int, 2, 2)
        @test jacobian!(U, G, [2, 3]) == [4 6; 251 672] == U
        u = zeros(Int, 2)
        U .= 0
        evaluate_and_jacobian!(u, U, G, [2, 3])
        @test U == jacobian(G, [2, 3])
        @test u == G([2, 3])

        @polyvar x y a b

        F = PolynomialSystem(x^2+x*y+a+a*x, x+y+b, parameters=[a, b])

        @test F([0,0], [1, 2]) == [1, 2]
        @test jacobian(F, [0, 0], [3, 2]) == [3 0; 1 1]

        @test parameters(F) == [:a, :b]
        @test nparameters(F) == 2
        @test variables(F) == [:x, :y]
        @test nvariables(F) == 2
        @test F isa PolynomialSystem{2, 2, 2}

        @polyvar x y z a b
        f = 2x^2+4a*y^2+(a^2+b^4+a+b+1)*3x*y^4+1+a*z+b-2x*b^6
        g = (x^2+z)*(x+b*y+a)

        F = PolynomialSystem(f, g, parameters=[a, b])
        differentiate_parameters(F, [2, 3, -3], [4, -2]) == [4407 -14297; 1 3]
        differentiate_parameters(F, [2, 3, -3], @SVector([4, -2])) == [4407 -14297; 1 3]
        @test differentiate_parameters(F, [2, 3, -3], @SVector([4, -2])) isa SMatrix{2, 2, Int, 4}
        U = zeros(Int, 2, 2)
        differentiate_parameters!(U, F, [2, 3, -3], [4, -2])
        @test U == [4407 -14297; 1 3]
    end

    @testset "Hessian" begin
        @polyvar x y z

        w = [2, 3, 5]

        f = x^4*y+x*y*z+y+x+z
        g = Polynomial(f)
        grad_g = Polynomial.(MP.differentiate(f, [x, y, z]))
        hess_w = vcat(map(grad_g) do g_i
            gradient(g_i, w)'
        end...)

        @test hessian(g, w) == hess_w
        @test gradient_and_hessian(g, w) == (gradient(g, w), hess_w)

        U = zeros(Int, 3, 3)
        @test hessian!(U, g, w) == hess_w


        p = [x^4*y+x*y*z+y+x+z, (x^3+y^2)*z]
        P = PolynomialSystem(p)

        u = zeros(2, 3)
        U = zeros(2, 3, 3)

        hessian!(U, P, w)
        @test U[1,:,:] == hess_w
        jacobian_and_hessian!(u, U, P, w)
        @test u[1,:] == gradient(g, w)
        @test U[1,:,:] == hess_w
    end

    @testset "foreach" begin
        @polyvar x y
        g = [Polynomial(x^2+y^2), Polynomial(2x^2+4y^2+3x*y^4+1)]
        G = PolynomialSystem(g...)
        i = 1
        foreach(G) do gi
            @test exponents(gi) == exponents(g[i])
            i += 1
        end
    end

    @testset "scale coefficients" begin
        @polyvar x y
        f = Polynomial(x^2+y^2)
        scale_coefficients!(f, 2)
        @test coefficients(f) == [2, 2]

        g1 = Polynomial(x^2+y^2)
        g2 = Polynomial(2x^2+4y^2+3x*y^4+1)
        G = PolynomialSystem(g1, g2)
        w = rand(2)
        x1 = evaluate(G, w)
        scale_coefficients!(G, [-2, 3])
        x2 = evaluate(G, w)
        @test x2 ≈ (-2, 3) .* x1
    end
end

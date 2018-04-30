@testset "constructors" begin
    A = round.(Int, max.(0.0, 5 * rand(6, 10) .- 1))
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
    @test length(SP.system([f1, f2, y, x])) == 4
    @test coefficienttype(SP.system(g1, g2)) == Int64
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
    @test u == SP.gradient(g, w)

    @test SP.evaluate_and_gradient(g, w) == (g(w), u)

    @test SP.evaluate_and_gradient!(u, g, w) == g(w)
    @test u == SP.gradient(g, w)
end

@testset "show" begin
    @polyvar x[0:9]
    @test string(Polynomial(x[1])) == "x₀"
    @test string(Polynomial(sum((-1)^i * x[i]^i for i=1:length(x)))) ==
        "-x₀ + x₁² - x₂³ + x₃⁴ - x₄⁵ + x₅⁶ - x₆⁷ + x₇⁸ - x₈⁹ + x₉¹⁰"
    @test string(Polynomial(2im*x[1] - x[2])) == "(0 + 2im)x₀ - x₁"
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
    @test [g1(w), g2(w)] == evaluate(G, w)

    w = SVector{2}(w)
    @test evaluate(G, w) isa SVector{2}
    @test [evaluate(g1, w), evaluate(g2, w)] == evaluate(G, w)
end

@testset "helpers" begin
    x = rand()
    z = rand(Complex{Float64})
    for k = 4:15
        @test abs(SP.pow(x, k) - x^k) < 1e-13
        @test abs(SP.pow(z, k) - z^k) < 1e-13
    end
end

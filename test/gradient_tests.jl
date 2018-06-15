@testset "gradient_codegen" begin
      T = Float64
      degrees = [0, 2, 3]
      coefficients = [:(2), :(-2), :(5)]
      var = :x

      x = rand()
      xval = 2.0 - 2 * x^2 + 5 * x^3
      xdval = -4 * x + 15 * x^2
      exprs = []
      sval, sdval = SP.evalpoly_derivative!(exprs, T, degrees, coefficients, var)
      val, dval = eval(Expr(:block, :(x = $x), exprs..., :(($sval, $sdval))))
      @test val ≈ xval
      @test dval ≈ xdval

      # bugfix
      @polyvar a b t z
      f = -0.25a^5*t+0.25b^5*t+0.5z^6
      g = Polynomial(f)
      x = rand(4)
      vars = [a, b, t, z]
      @test map(v -> (MP.differentiate(f, v))(vars=>x), vars) ≈ gradient(g, x)
end

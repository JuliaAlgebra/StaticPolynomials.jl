@testset "gradient_codegen" begin
      T = Float64
      degrees = [0, 2, 3]
      coefficients = [:(2), :(-2), :(5)]
      var = :x

      x = rand()
      xval = 2.0 - 2 * x^2 + 5 * x^3
      xdval = -4 * x + 15 * x^2
      exprs = []
      sval, sdval = SP.eval_derivative_poly!(exprs, T, degrees, coefficients, var)
      val, dval = eval(Expr(:block, exprs..., :(($sval, $sdval))))
      @test val ≈ xval
      @test dval ≈ xdval
end

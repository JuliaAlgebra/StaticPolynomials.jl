using StaticPolynomials
const SP = StaticPolynomials
using Base.Test
import DynamicPolynomials: @polyvar
using StaticArrays

T = Float64
degrees = [0, 2, 3]
coefficients = [:(2), :(-2), :(5)]
var = :x

x = rand()
xval = 2.0 - 2 * x^2 + 5 * x^3
xdval = -4 * x + 15 * x^2
val, dval = eval(SP.eval_derivative_poly(T, degrees, coefficients, var))
val ≈ xval
dval ≈ xdval

SP.monomial_product_val_derivatives(T, [2, 3, 4], :c5)


@polyvar x y z

E = [ 4  4  1  3  5
      2  4  2  2  5
      0  1  2  2  2 ]

c = rand(5)

fixed = FP.Polynomial(E, c)
x = rand(3)

FP.gradient!(zeros(3), fixed, x, FP.GradientConfig(fixed))



eval(SP.generate_gradient(E, Float64))


SP.generate_gradient(E, Float64)

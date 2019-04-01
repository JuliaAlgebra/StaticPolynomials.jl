# Reference

## Polynomial
```@docs
Polynomial
SExponents
coefficients
exponents
nvariables(::Polynomial)
nparameters(::Polynomial)
coefficienttype(::Polynomial)
scale_coefficients!(::Polynomial, λ)
evaluate(::Polynomial, x)
evaluate(::Polynomial, x, p)
gradient
gradient!
evaluate_and_gradient
evaluate_and_gradient!
hessian(f::Polynomial, xp...)
hessian!(U, f::Polynomial, xp...)
gradient_and_hessian
gradient_and_hessian!
differentiate_parameters(::Polynomial, x, p)
differentiate_parameters!(u, ::Polynomial, x, p)
```


## Systems of Polynomials

```@docs
PolynomialSystem
npolynomials(::PolynomialSystem)
nvariables(::PolynomialSystem)
nparameters(::PolynomialSystem)
foreach(f::Function, ::PolynomialSystem)
scale_coefficients!(::PolynomialSystem, ::AbstractVector)
evaluate(::PolynomialSystem, x)
evaluate(::PolynomialSystem, ::AbstractVector, ::Any)
evaluate!(u, ::PolynomialSystem, x)
evaluate!(u, ::PolynomialSystem, x, p)
jacobian
jacobian!
evaluate_and_jacobian
evaluate_and_jacobian!
hessian!(U, F::PolynomialSystem, x::AbstractVector)
jacobian_and_hessian!
differentiate_parameters(::PolynomialSystem, x, p)
differentiate_parameters!(U, ::PolynomialSystem, x, p)
```

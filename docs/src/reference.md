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
evaluate(::Polynomial, ::AbstractVector)
gradient(::Polynomial, ::AbstractVector)
gradient(::Polynomial, ::AbstractVector, ::Any)
gradient!(::AbstractVector, ::Polynomial, ::AbstractVector)
gradient!(::AbstractVector, ::Polynomial, ::AbstractVector, ::Any)
evaluate_and_gradient
evaluate_and_gradient!
differentiate_parameters(::Polynomial, ::Any, ::Any)
differentiate_parameters!(::Any, ::Polynomial, ::Any, ::Any)
```

## Systems of Polynomials

```@docs
PolynomialSystem
npolynomials(::PolynomialSystem)
nvariables(::PolynomialSystem)
nparameters(::PolynomialSystem)
foreach(f::Function, ::PolynomialSystem)
scale_coefficients!(::PolynomialSystem, ::AbstractVector)
evaluate(::PolynomialSystem, ::AbstractVector)
evaluate!(::AbstractVector, ::PolynomialSystem, ::AbstractVector)
evaluate(::PolynomialSystem, ::AbstractVector, ::Any)
evaluate!(::AbstractVector, ::PolynomialSystem, ::AbstractVector, ::Any)
jacobian
jacobian!
evaluate_and_jacobian
evaluate_and_jacobian!
differentiate_parameters(::Any, ::PolynomialSystem, ::Any, ::Any)
differentiate_parameters!(::Any, ::PolynomialSystem, ::Any, ::Any)
```

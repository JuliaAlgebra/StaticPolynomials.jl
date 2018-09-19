# Reference

## Polynomial
```@docs
Polynomial
SExponents
coefficients
exponents
nvariables(::Polynomial)
coefficienttype(::Polynomial)
scale_coefficients!(::Polynomial, λ)
evaluate(::Polynomial, ::AbstractVector)
gradient(::Polynomial, ::AbstractVector)
gradient(::Polynomial, ::AbstractVector, ::Any)
gradient!(::AbstractVector, ::Polynomial, ::AbstractVector)
gradient!(::AbstractVector, ::Polynomial, ::AbstractVector, ::Any)
evaluate_and_gradient
evaluate_and_gradient!
gradient_parameters
gradient_parameters!
```

## Systems of Polynomials

```@docs
PolynomialSystem
nvariables(::AbstractSystem)
npolynomials(::AbstractSystem)
coefficienttype(::AbstractSystem)
scale_coefficients!(::AbstractSystem, ::AbstractVector)
evaluate(::AbstractSystem, ::AbstractVector)
evaluate!(::AbstractVector, ::AbstractSystem, ::AbstractVector)
jacobian
jacobian!
evaluate_and_jacobian
evaluate_and_jacobian!
foreach(f::Function, ::AbstractSystem)
```

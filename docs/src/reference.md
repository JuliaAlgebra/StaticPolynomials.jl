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
gradient!(::AbstractVector, ::Polynomial, ::AbstractVector)
evaluate_and_gradient
evaluate_and_gradient!
```

## Systems of Polynomials

```@docs
AbstractSystem
system
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

# Reference

## Polynomial
```@docs
Polynomial
coefficients
exponents
nvariables(::Polynomial)
coefficienttype(::Polynomial)
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
nvariables
npolynomials
coefficienttype
evaluate(::AbstractSystem, ::AbstractVector)
evaluate!(::AbstractVector, ::AbstractSystem, ::AbstractVector)
jacobian
jacobian!
evaluate_and_jacobian
evaluate_and_jacobian!
```

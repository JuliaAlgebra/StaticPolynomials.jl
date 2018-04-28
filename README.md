# StaticPolynomials

| **Documentation** | **Build Status** |
|:-----------------:|:----------------:|
| [![][docs-stable-img]][docs-stable-url] | [![Build Status][build-img]][build-url] |
| [![][docs-latest-img]][docs-latest-url] | [![Codecov branch][codecov-img]][codecov-url] |


A package for the fast evaluation of multivariate polynomials. This package uses Julia metaprogramming features to generate a specialized function for the evaluation of the polynomial and its gradient.

## Usage
```julia
import DynamicPolynomials: @polyvar
using StaticPolynomials: gradient

@polyvar x y

julia> f = Polynomial(x^2+3y^2*x+1) # the support of f is encoded in the `Polynomial` type. 
StaticPolynomials.Polynomial{Int64,2,SExponents{4103c6525e885f8b}}()

julia> evaluate(f, [2.0, 3.0])
59.0
julia> gradient(f, [2.0, 3.0])
2-element Array{Float64,1}:
 31.0
 36.0
```
We also support systems of polynomials.
```julia
julia> F = system([x^2+y^2+1, x + y - 5])
StaticPolynomials.Systems.System2{Int64,2,SExponents{932bae602683cacb},SExponents{44c61f91039334d1}}()
julia> evaluate(F, [2.0, 3.0])
2-element Array{Float64,1}:
 14.0
  0.0
julia> jacobian(f, [2.0, 3.0])
2×2 Array{Float64,2}:
 4.0  6.0
 1.0  1.0
```

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-stable-url]: https://juliaalgebra.github.io/StaticPolynomials.jl/stable
[docs-latest-url]: https://juliaalgebra.github.io/StaticPolynomials.jl/latest

[build-img]: https://travis-ci.org/JuliaAlgebra/StaticPolynomials.jl.svg?branch=master
[build-url]: https://travis-ci.org/JuliaAlgebra/StaticPolynomials.jl
[codecov-img]: https://codecov.io/gh/juliaalgebra/StaticPolynomials.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/juliaalgebra/StaticPolynomials.jl

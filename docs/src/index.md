# Introduction

[StaticPolynomials.jl](https://github.com/saschatimme/FixedPolynomials.jl) is a library for
*fast* evaluation of multivariate polynomials.

Let ``f`` be a multivariate polynomial with support ``A\subset \mathbb{N}^n``.
This package then uses Julia metaprogramming capabilities (`@generated` in particular)
to generate specialized functions for the evaluation of ``f`` and its gradient.
In order to achieve this the support is encoded in the type of ``f`` and a new function will be compiled for
each newly encountered support. Therefore this is not suitable if you only evaluate
``f`` a couple of times.

Since the polynomials in this package are optimised for fast evaluation they are not suited
for construction of polynomials.
It is recommended to construct a polynomial with an implementation of
[MultivariatePolynomials.jl](https://github.com/blegat/MultivariatePolynomials.jl), e.g.
[DynamicPolynomials.jl](https://github.com/blegat/DynamicPolynomials.jl), and to
convert it then into a `StaticPolynomials.Polynomial` for further computations.

## Tutorial

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

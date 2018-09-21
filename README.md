# StaticPolynomials

| **Documentation** | **Build Status** | **References to cite** |
|:-----------------:|:----------------:|:----------------------:|
| [![][docs-stable-img]][docs-stable-url] | [![Build Status][build-img]][build-url] | [![DOI](https://zenodo.org/badge/123788793.svg)](https://zenodo.org/badge/latestdoi/123788793) |
| [![][docs-latest-img]][docs-latest-url] | [![Codecov branch][codecov-img]][codecov-url] |  |


[StaticPolynomials.jl](https://github.com/saschatimme/FixedPolynomials.jl) is a library for
*fast* evaluation of multivariate polynomials.

Let `f` be a multivariate polynomial with support `A`.
This package then uses Julia metaprogramming capabilities (`@generated` in particular)
to generate specialized functions for the evaluation of `f` and its gradient.
In order to achieve this the support is encoded in the type of `f` and a new function will be compiled for
each newly encountered support. Therefore this is not suitable if you only evaluate
`f` a couple of times.

Since the polynomials in this package are optimised for fast evaluation they are not suited
for construction of polynomials.
It is recommended to construct a polynomial with an implementation of
[MultivariatePolynomials.jl](https://github.com/blegat/MultivariatePolynomials.jl), e.g.
[DynamicPolynomials.jl](https://github.com/blegat/DynamicPolynomials.jl), and to
convert it then into a `StaticPolynomials.Polynomial` for further computations.

## Usage

## Tutorial

```julia
julia> import DynamicPolynomials: @polyvar;
julia> using StaticPolynomials: gradient;

julia> @polyvar x y a;

julia> f = Polynomial(x^2+3y^2*x+1)
1 + x² + 3xy²

julia> evaluate(f, [2, 3])
59

julia> gradient(f, [2, 3])
2-element Array{Int64,1}:
 31
 36

# You can also declare certain variables as parameters
julia> g = Polynomial(x^2+3y^2*x+a^2; parameters=[a])
a² + x² + 3xy²

julia> evaluate(g, [2, 3], [4])
74
julia> gradient(g, [2, 3], [4])
2-element Array{Int64,1}:
 31
 36

# You can also differentiate with respect to the parameters
julia> differentiate_parameters(g, [2, 3], [4])
1-element Array{Int64,1}:
 8
```

We also support systems of polynomials.

```julia
julia> @polyvar x y a b;

julia> F = PolynomialSystem([x^2+y^2+1, x + y - 5])
PolynomialSystem{2, 2, 0}:
 1 + x² + y²

 -5 + x + y

julia> evaluate(F, [2, 3])
2-element Array{Int64,1}:
 14
  0

julia> jacobian(F, [2, 3])
2×2 Array{Int64,2}:
 4  6
 1  1

# You can also declare parameters
julia> G = PolynomialSystem([x^2+y^2+a^3, b*x + y - 5]; parameters=[a, b])
PolynomialSystem{2, 2, 2}:
 a³ + x² + y²

 -5 + xb + y

julia> evaluate(G, [2, 3], [-2, 4])
2-element Array{Int64,1}:
  5
  6

julia> jacobian(G, [2, 3], [-2, 4])
2×2 Array{Int64,2}:
  4  6
  4  1

# You can also differentiate with respect to the parameters
julia> differentiate_parameters(G, [2, 3], [-2, 4])
2×2 Array{Int64,2}:
  12  0
   0  2
```

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-latest-img]: https://img.shields.io/badge/docs-latest-blue.svg
[docs-stable-url]: https://juliaalgebra.github.io/StaticPolynomials.jl/stable
[docs-latest-url]: https://juliaalgebra.github.io/StaticPolynomials.jl/latest

[build-img]: https://travis-ci.org/JuliaAlgebra/StaticPolynomials.jl.svg?branch=master
[build-url]: https://travis-ci.org/JuliaAlgebra/StaticPolynomials.jl
[codecov-img]: https://codecov.io/gh/juliaalgebra/StaticPolynomials.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/juliaalgebra/StaticPolynomials.jl

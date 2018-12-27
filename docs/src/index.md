# Introduction

[StaticPolynomials.jl](https://github.com/saschatimme/FixedPolynomials.jl) is a library for
*fast* evaluation of multivariate polynomials. It achieves it speed by automatically
generating and compiling high performance code for the evaluation of the polynomial and it's
derivatives. This is made possible by encoding in the type
signature which terms exists and Julia's metaprogramming capabilities (in particular
[generated functions](https://docs.julialang.org/en/v1/manual/metaprogramming/#Generated-functions-1)).

A tradeoff of this is approach is that for each polynomial (unless only coefficients changes)
new functions have to be compiled. Therefore this is usually only a good idea if you have
to evaluate the same polynomial (system) very often.

Since the polynomials in this package are optimised for fast evaluation they are not suited
for the usual polynomial arithmetic.
It is recommended to construct a polynomial with an implementation of
[MultivariatePolynomials.jl](https://github.com/blegat/MultivariatePolynomials.jl), e.g.
[DynamicPolynomials.jl](https://github.com/blegat/DynamicPolynomials.jl), and to
convert them into a [`Polynomial`](@ref) for the evaluations.

## Performance

StaticPolynomials is substantially faster than automatic differentiation packages like [ForwardDiff](https://github.com/JuliaDiff/ForwardDiff.jl),
also works for complex polynomials and often outperforms hand tuned gradients.

```julia
using StaticPolynomials, BenchmarkTools, StaticArrays
import ForwardDiff
import DynamicPolynomials: @polyvar

# Our real-world test polynomial
function f10(x)
    f  = 48*x[1]^3 + 72*x[1]^2*x[2] + 72*x[1]^2*x[3] + 72*x[1]^2*x[4] + 72*x[1]^2*x[5] + 72*x[1]^2*x[7]
    f += 72*x[1]^2*x[8] + 72*x[1]*x[2]^2 + 144*x[1]*x[2]*x[4] + 144*x[1]*x[2]*x[7] + 72*x[1]*x[3]^2
    f += 144*x[1]*x[3]*x[5] + 144*x[1]*x[3]*x[8] + 72*x[1]*x[4]^2 + 144*x[1]*x[4]*x[7] + 72*x[1]*x[5]^2
    f += 144*x[1]*x[5]*x[8] + 72*x[1]*x[7]^2 + 72*x[1]*x[8]^2 + 48*x[2]^3 + 72*x[2]^2*x[3]
    f += 72*x[2]^2*x[4] + 72*x[2]^2*x[6] + 72*x[2]^2*x[7] + 72*x[2]^2*x[9] + 72*x[2]*x[3]^2
    f += 144*x[2]*x[3]*x[6] + 144*x[2]*x[3]*x[9] + 72*x[2]*x[4]^2 + 144*x[2]*x[4]*x[7] + 72*x[2]*x[6]^2
    f += 144*x[2]*x[6]*x[9] + 72*x[2]*x[7]^2 + 72*x[2]*x[9]^2 + 48*x[3]^3 + 72*x[3]^2*x[5]
    f += 72*x[3]^2*x[6] + 72*x[3]^2*x[8] + 72*x[3]^2*x[9] + 72*x[3]*x[5]^2 + 144*x[3]*x[5]*x[8]
    f += 72*x[3]*x[6]^2 + 144*x[3]*x[6]*x[9] + 72*x[3]*x[8]^2 + 72*x[3]*x[9]^2 + 48*x[4]^3
    f += 72*x[4]^2*x[5] + 72*x[4]^2*x[6] + 72*x[4]^2*x[7] + 72*x[4]^2*x[10] + 72*x[4]*x[5]^2
    f += 144*x[4]*x[5]*x[6] + 144*x[4]*x[5]*x[10] + 72*x[4]*x[6]^2 + 144*x[4]*x[6]*x[10] + 72*x[4]*x[7]^2
    f += 72*x[4]*x[10]^2 + 48*x[5]^3 + 72*x[5]^2*x[6] + 72*x[5]^2*x[8] + 72*x[5]^2*x[10]
    f += 72*x[5]*x[6]^2 + 144*x[5]*x[6]*x[10] + 72*x[5]*x[8]^2 + 72*x[5]*x[10]^2 + 48*x[6]^3
    f += 72*x[6]^2*x[9] + 72*x[6]^2*x[10] + 72*x[6]*x[9]^2 + 72*x[6]*x[10]^2 + 48*x[7]^3
    f += 72*x[7]^2*x[8] + 72*x[7]^2*x[9] + 72*x[7]^2*x[10] + 72*x[7]*x[8]^2 + 144*x[7]*x[8]*x[9]
    f += 144*x[7]*x[8]*x[10] + 72*x[7]*x[9]^2 + 144*x[7]*x[9]*x[10] + 72*x[7]*x[10]^2 + 48*x[8]^3
    f += 72*x[8]^2*x[9] + 72*x[8]^2*x[10] + 72*x[8]*x[9]^2 + 144*x[8]*x[9]*x[10] + 72*x[8]*x[10]^2
    f += 48*x[9]^3 + 72*x[9]^2*x[10] + 72*x[9]*x[10]^2 + 48*x[10]^3
    return f
end

# setup polynomial
@polyvar x[1:10]
p10 = Polynomial(f10(x))

x = @SVector rand(10)

@btime f10($x) # 31.778 ns (0 allocations: 0 bytes)
@btime $p10($x) # 28.836 ns (0 allocations: 0 bytes)

@btime gradient($p10, $x) # 72.334 ns (0 allocations: 0 bytes)
cfg = ForwardDiff.GradientConfig(f10, x)
@btime ForwardDiff.gradient($f10, $x, $cfg) # 550.187 ns (2 allocations: 192 bytes)
```

## Short introduction

```julia-repl
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

```julia-repl
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

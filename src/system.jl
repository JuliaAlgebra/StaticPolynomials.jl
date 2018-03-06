export AbstractSystem, system, evaluate, evaluate!, nvariables, npolynomials, coefficienttype

abstract type AbstractSystem{T, Size, NVars} end

"""
    system(polys::AbstractVector{<:MP.AbstractPolynomial}...)
    system(polys...)

Create a system of polynomials from the given `polys`.
The result is an object which is a subtype of [`AbstractSystem`](@ref).
This function is by design not typestable.

## Example
```julia
julia> import DynamicPolynomials: @polyvar
julia> @polyvar x y
julia> F = system(x^2+y^2+3, x-y+2, x^2+2y)
julia> F isa AbstractSystem{Int64, 3, 2}
true
```
"""
function system(polys::AbstractVector{<:MP.AbstractPolynomial})
    variables = sort!(union(Iterators.flatten(MP.variables.(polys))), rev=true)
    system(map(p -> Polynomial(p, variables), polys)...)
end
@inline system(polys...) = Systems.system(polys...)

"""
    evaluate!(u, F::AbstractSystem, x)

Evaluate the system `F` at `x` and store the result in `u`.
"""
@inline evaluate!(u, S::AbstractSystem, x) = Systems.evaluate!(u, S, x)

"""
    evaluate(F::AbstractSystem, x)
    evaluate(F::AbstractSystem, x::SVector)

Evaluate the system `F` at `x`.
"""
@inline function evaluate(S::AbstractSystem{T1, M, N}, x::SVector{N, T2}) where {T1, T2, M, N}
    Systems.evaluate(S, x)
end
@inline function evaluate(S::AbstractSystem{T1, M}, x::AbstractVector{T2}) where {T1, M, T2}
    Systems.evaluate!(Vector{promote_type(T1, T2)}(M), S, x)
end

"""
    nvariables(F::AbstractSystem)

The number of variables of the system `F`.
"""
nvariables(F::AbstractSystem{T, M, NVars}) where {T, M, NVars} = NVars

"""
    npolynomials(F::AbstractSystem)

The number of polynomials of the system `F`.
"""
npolynomials(F::AbstractSystem{T, M, NVars}) where {T, M, NVars} = M
Base.length(F::AbstractSystem) = npolynomials(F)

"""
    coefficienttype(F::AbstractSystem)

Return the type of the coefficients of the polynomials of `F`.
"""
coefficienttype(::AbstractSystem{T}) where {T} = T

# We create a nested module to not clutter the namespace
module Systems

    using ..StaticPolynomials
    import ..StaticPolynomials: evaluate, evaluate!, system
    import StaticArrays: SVector

    function create_system_impl(n)
        fs = [Symbol("f", i) for i=1:n]
        Es = [Symbol("E", i) for i=1:n]
        fields = [:($(fs[i])::Polynomial{T, N, $(Symbol("E", i))}) for i=1:n]
        types = [:($(Es[i])<:SExponents) for i=1:n]
        name = Symbol("System", n)
        quote
            struct $(name){T, N, $(types...)} <: AbstractSystem{T, $n, N}
                $(fields...)
            end

            function system($(fields...)) where {T, N, $(types...)}
                $(name){T, N, $(Es...)}($(fs...))
            end

            function evaluate!(u::AbstractVector, S::$(name), x::AbstractVector)
                $(Expr(:block, [:(u[$i] = evaluate(S.$(fs[i]), x)) for i in 1:n]...))
                u
            end

            function evaluate(system::$(name){T, N}, x::SVector{N, S}) where {T, S, N}
                $(Expr(:block,
                    (:($(Symbol("u_", i)) = evaluate(system.$(fs[i]), x)) for i in 1:n)...,
                    :(SVector(
                        $((Symbol("u_", i) for i=1:n)...)
                    ))
                ))
            end
        end
    end

    function create_system(n)
        eval(create_system_impl(n))
    end

    for n=2:32
        create_system(n)
    end
end



# export System, genevaluate!, genjacobian!
#
# """
#     System([T, ], F::Vector{<:MP.AbstractPolynomialLike})
# Construct a system of SuperPolynomials.
#     System([T, ], F::Vector{<:FP.Polynomial})
# """
# struct System{T}
#     polynomials::Vector{Polynomial{T, N, NTerms, Exponents} where Exponents where NTerms where N}
# end
#
# function System(ps::Vector{P}) where {T, N, P<:Polynomial{T, N}}
#     @assert !isempty(ps) "The system cannot be empty"
#     @assert length(ps) < 129 "Currently only systems of up to 128 polynomials are supported."
#     System{T}(ps)
# end
#
# function System(ps::Vector{<:MP.AbstractPolynomialLike})
#     variables = sort!(union(Iterators.flatten(MP.variables.(ps))), rev=true)
#     System([Polynomial(p, variables) for p in ps])
# end
#
# function System(ps::Vector{<:FP.Polynomial})
#     System([Polynomial(p) for p in ps])
# end
#
# function System(::Type{T}, ps::Vector{<:MP.AbstractPolynomialLike}) where T
#     variables = sort!(union(Iterators.flatten(MP.variables.(ps))), rev=true)
#     System([Polynomial(T, p, variables) for p in ps])
# end
#
# for N = 1:128
#     @eval begin
#         function genevaluate!($([Symbol("p", i) for i=1:N]...))
#             (u, x) -> begin
#                 $(Expr(:block, [:(u[$i] = evaluate($(Symbol("p", i)), x)) for i=1:N]...))
#                 u
#             end
#         end
#     end
#
#     @eval begin
#         function genjacobian!($([Symbol("p", i) for i=1:N]...))
#             (U, x) -> begin
#                 $(Expr(:block, [:(gradient!(U, $(Symbol("p", i)), x, $i)) for i=1:N]...))
#                 U
#             end
#         end
#     end
# end
#
# """
#     genevaluate!(F::System)
# Generate an evaluation function `(u, x) ->  u .= F(x)` for the polynomial system `F`.
# """
# function genevaluate!(ps::System)
#     genevaluate!(ps.polynomials...)
# end
#
# """
#     genevaluate!(F::System)
# Generate an evaluation function `(u, x) ->  u .= J_F(x)` for the Jacobian of the
# polynomial system `F`.
# """
# function genjacobian!(ps::System)
#     genjacobian!(ps.polynomials...)
# end

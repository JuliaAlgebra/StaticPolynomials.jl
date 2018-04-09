export AbstractSystem, system, evaluate, evaluate!, jacobian, jacobian!, variables, npolynomials, coefficienttype

abstract type AbstractSystem{T, Size, NVars} end

"""
    system(polys::AbstractVector{<:MP.AbstractPolynomial}..., variables=sorted_variables(polys))
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
function system(polys::AbstractVector{<:MP.AbstractPolynomial}, vars=sorted_variables(polys))
    system(map(p -> Polynomial(p, vars), polys)...)
end
function sorted_variables(polys::AbstractVector{<:MP.AbstractPolynomial})
    sort!(union(Iterators.flatten(MP.variables.(polys))), rev=true)
end

function system(polys...)
    n = length(polys)
    if !isdefined(Systems, Symbol("System", n))
        Systems.create_system(n)
    end

    return Base.invokelatest(Systems._system, polys...)
end

"""
    evaluate!(u, F::AbstractSystem, x)

Evaluate the system `F` at `x` and store the result in `u`.
"""
@inline evaluate!(u, S::AbstractSystem, x) = Systems._evaluate!(u, S, x)

"""
    evaluate(F::AbstractSystem, x::AbstractVector)

Evaluate the system `F` at `x`.
"""
function evaluate(S::AbstractSystem{T1, M}, x::AbstractVector{T2}) where {T1, M, T2}
    Systems._evaluate!(Vector{promote_type(T1, T2)}(undef, M), S, x)
end
evaluate(S::AbstractSystem, x::SVector) = Systems._evaluate(S, x)


"""
    jacobian!(u, F::AbstractSystem, x)

Evaluate the Jacobian of the system `F` at `x` and store the result in `u`.
"""
@inline jacobian!(u, S::AbstractSystem, x) = Systems._jacobian!(u, S, x)

"""
    jacobian(F::AbstractSystem, x)
    jacobian(F::AbstractSystem, x::SVector)

Evaluate the Jacobian of the system `F` at `x`.
"""
@inline function jacobian(S::AbstractSystem{T1, M, N}, x::AbstractVector{T2}) where {T1, M, N, T2}
    Systems._jacobian!(Matrix{promote_type(T1, T2)}(undef, M, N), S, x)
end
@inline function jacobian(S::AbstractSystem{T1, M, N}, x::SVector{N, T2}) where {T1, T2, M, N}
    Systems._jacobian(S, x)
end

"""
    evaluate_and_jacobian!(u, U, F::AbstractSystem, x)

Evaluate the system `F` and its Jacobian at `x` and store the results in `u` (evalution)
and `U` (Jacobian).
"""
@inline evaluate_and_jacobian!(u, U, S::AbstractSystem, x) = Systems._evaluate_and_jacobian!(u, U, S, x)

"""
    evaluate_and_jacobian(F::AbstractSystem, x)
    evaluate_and_jacobian(F::AbstractSystem, x::SVector)

Evaluate the system `F` and its Jacobian at `x`.
"""
@inline function evaluate_and_jacobian(S::AbstractSystem{T1, M, N}, x::AbstractVector{T2}) where {T1, M, N, T2}
    T = typeof(one(T1) * one(T2))
    u = Vector{T}(undef, M)
    U = Matrix{T}(undef, M, N)
    evaluate_and_jacobian!(u, U, S, x)
    u, U
end
@inline function evaluate_and_jacobian(S::AbstractSystem{T1, M, N}, x::SVector{N, T2}) where {T1, T2, M, N}
    Systems._evaluate_and_jacobian(S, x)
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
    # import ..StaticPolynomials: system, evaluate, evaluate!, jacobian, jacobian!, evaluate_and_jacobian, evaluate_and_jacobian!
    import StaticArrays: SVector, SMatrix

    function _assemble_matrix_impl(::Type{SVector{M, SVector{N, T}}}) where {T, N, M}
        quote
            SMatrix{$M, $N, $T, $(M*N)}(
                tuple($([:(vectors[$i][$j]) for j=1:N for i=1:M]...))
            )
        end
    end
    @generated _assemble_matrix(vectors::SVector{N, <:SVector}) where N = _assemble_matrix_impl(vectors)

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

            function _system($(fields...)) where {T, N, $(types...)}
                $(name){T, N, $(Es...)}($(fs...))
            end

            function _evaluate!(u::AbstractVector, S::$(name){T, N}, x::AbstractVector) where {T, N}
                @boundscheck length(x) ≥ N
                $(Expr(:block, [:(@inbounds u[$i] = StaticPolynomials.evaluate(S.$(fs[i]), x)) for i in 1:n]...))
                u
            end

            function _evaluate(system::$(name){T, N}, x::SVector{N, S}) where {T, S, N}
                $(Expr(:block,
                    (:(@inbounds $(Symbol("u_", i)) = StaticPolynomials.evaluate(system.$(fs[i]), x)) for i in 1:n)...,
                    :(SVector(
                        $((Symbol("u_", i) for i=1:n)...)
                    ))
                ))
            end

            (F::$(name))(x::AbstractVector) = evaluate(F, x)

            function _jacobian!(u::AbstractMatrix, F::$(name){T, N}, x::AbstractVector) where {T, N}
                @boundscheck length(x) ≥ N
                $(Expr(:block,
                    (:(@inbounds $(Symbol("∇", i)) = StaticPolynomials._gradient(F.$(fs[i]), x)) for i in 1:n)...,
                    quote
                        for j=1:N
                            $([:(u[$i, j] = $(Symbol("∇", i))[j]) for i in 1:n]...)
                        end
                    end
                ))

                u
            end

            function _jacobian(system::$(name){T, N}, x::SVector{N, S}) where {T, S, N}
                $(Expr(:block,
                    (:(@inbounds $(Symbol("∇", i)) = StaticPolynomials._gradient(system.$(fs[i]), x)) for i in 1:n)...,
                    :(_assemble_matrix(SVector(
                        $(Expr(:tuple, (Symbol("∇", i) for i=1:n)...))
                    )))
                ))
            end

            function _evaluate_and_jacobian!(u::AbstractVector, U::AbstractMatrix, S::$(name){T, N}, x::AbstractVector) where {T, N}
                @boundscheck length(x) ≥ N
                $(begin
                    u = [Symbol("u", i) for i = 1:n]
                    ∇ = [Symbol("∇", i) for i = 1:n]
                    exprs = Expr[]
                    for i=1:n
                        lhs = Expr(:tuple, u[i], ∇[i])
                        push!(exprs, :($lhs = StaticPolynomials._val_gradient(S.$(fs[i]), x)))
                        push!(exprs, :(u[$i] = $(u[i])))
                    end
                    Expr(:block,
                        exprs...,
                        quote
                            for j=1:N
                                $([:(U[$i, j] = $(∇[i])[j]) for i in 1:n]...)
                            end
                        end,
                        :(nothing))
                end)
            end

            function _evaluate_and_jacobian(S::$(name){T, N}, x::SVector{N, T2}) where {T, T2, N}
                $(begin
                    u = [Symbol("u", i) for i = 1:n]
                    ∇ = [Symbol("∇", i) for i = 1:n]
                    exprs = Expr[]
                    for i=1:n
                        lhs = Expr(:tuple, u[i], ∇[i])
                        push!(exprs, :($lhs = StaticPolynomials._val_gradient(S.$(fs[i]), x)))
                    end
                    val = :(SVector($(Expr(:tuple, u...))))
                    jac = :(_assemble_matrix(SVector($(Expr(:tuple, ∇...)))))
                    push!(exprs, :(val = $val))
                    push!(exprs, :(jac = $jac))
                    Expr(:block, exprs..., :((val, jac)))
                end)
            end
        end
    end

    function create_system(n)
        eval(create_system_impl(n))
    end

    for n=1:64
        create_system(n)
    end
end

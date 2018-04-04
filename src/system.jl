export AbstractSystem, system, evaluate, evaluate!, jacobian, jacobian!, variables, npolynomials, coefficienttype

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
function system(polys...)
    n = length(polys)
    if !isdefined(Systems, Symbol("System", n))
        Systems.create_system(n)
    end

    return Base.invokelatest(Systems.system, polys...)
end

"""
    evaluate!(u, F::AbstractSystem, x)

Evaluate the system `F` at `x` and store the result in `u`.
"""
@inline evaluate!(u, S::AbstractSystem, x) = Systems.evaluate!(u, S, x)

"""
    evaluate(F::AbstractSystem, x::AbstractVector)

Evaluate the system `F` at `x`.
"""
evaluate(S::AbstractSystem, x::AbstractVector) = Systems.evaluate(S, x)


"""
    jacobian!(u, F::AbstractSystem, x)

Evaluate the Jacobian of the system `F` at `x` and store the result in `u`.
"""
@inline jacobian!(u, S::AbstractSystem, x) = Systems.jacobian!(u, S, x)

"""
    jacobian(F::AbstractSystem, x)
    jacobian(F::AbstractSystem, x::SVector)

Evaluate the Jacobian of the system `F` at `x`.
"""
@inline function jacobian(S::AbstractSystem{T1, M, N}, x::SVector{N, T2}) where {T1, T2, M, N}
    Systems.jacobian(S, x)
end
@inline function jacobian(S::AbstractSystem{T1, M, N}, x::AbstractVector{T2}) where {T1, M, N, T2}
    Systems.jacobian!(Matrix{promote_type(T1, T2)}(M, N), S, x)
end

"""
    evaluate_and_jacobian!(u, U, F::AbstractSystem, x)

Evaluate the system `F` and its Jacobian at `x` and store the results in `u` (evalution)
and `U` (Jacobian).
"""
@inline evaluate_and_jacobian!(u, U, S::AbstractSystem, x) = Systems.evaluate_and_jacobian!(u, U, S, x)

"""
    evaluate_and_jacobian(F::AbstractSystem, x)
    evaluate_and_jacobian(F::AbstractSystem, x::SVector)

Evaluate the system `F` and its Jacobian at `x`.
"""
@inline function evaluate_and_jacobian(S::AbstractSystem{T1, M, N}, x::SVector{N, T2}) where {T1, T2, M, N}
    Systems.evaluate_and_jacobian(S, x)
end
@inline function evaluate_and_jacobian(S::AbstractSystem{T1, M, N}, x::AbstractVector{T2}) where {T1, M, N, T2}
    T = typeof(one(T1) * one(T2))
    u = Vector{T}(M)
    U = Matrix{T}(M, N)
    Systems.evaluate_and_jacobian!(u, U, S, x)
    u, U
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
    import ..StaticPolynomials: evaluate, evaluate!, jacobian, jacobian!, system, evaluate_and_jacobian, evaluate_and_jacobian!
    import StaticArrays: SVector, SMatrix

    function assemble_matrix_impl(::Type{SVector{M, SVector{N, T}}}) where {T, N, M}
        quote
            SMatrix{$M, $N, $T, $(M*N)}(
                tuple($([:(vectors[$i][$j]) for j=1:N for i=1:M]...))
            )
        end
    end
    @inline @generated assemble_matrix(vectors::SVector{N, <:SVector}) where N = assemble_matrix_impl(vectors)

    function unrolled_assemble_matrix(vecs, T, N)
        ops = []
        for i=1:N, j=1:n
            push!(ops, :($(vecs[j])[$i]))
        end
        :(SMatrix{$n, $N, $T, $(n*N)}($(Expr(:tuple, ops...))))
    end

    function evaluate(S::AbstractSystem{T1, M}, x::AbstractVector{T2}) where {T1, M, T2}
        evaluate!(Vector{promote_type(T1, T2)}(M), S, x)
    end

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

            function evaluate!(u::AbstractVector, S::$(name){T, N}, x::AbstractVector) where {T, N}
                @boundscheck length(x) ≥ N
                $(Expr(:block, [:(@inbounds u[$i] = evaluate(S.$(fs[i]), x)) for i in 1:n]...))
                u
            end

            function evaluate(system::$(name){T, N}, x::SVector{N, S}) where {T, S, N}
                $(Expr(:block,
                    (:(@inbounds $(Symbol("u_", i)) = evaluate(system.$(fs[i]), x)) for i in 1:n)...,
                    :(SVector(
                        $((Symbol("u_", i) for i=1:n)...)
                    ))
                ))
            end

            (F::$(name))(x::AbstractVector) = evaluate(F, x)

            function jacobian!(u::AbstractMatrix, S::$(name){T, N}, x::AbstractVector) where {T, N}
                @boundscheck length(x) ≥ N
                $(Expr(:block, [:(@inbounds u[$i, :] .= StaticPolynomials._gradient(S.$(fs[i]), x)) for i in 1:n]...))
                u
            end

            function jacobian(system::$(name){T, N}, x::SVector{N, S}) where {T, S, N}
                $(Expr(:block,
                    (:(@inbounds $(Symbol("∇", i)) = StaticPolynomials._gradient(system.$(fs[i]), x)) for i in 1:n)...,
                    :(assemble_matrix(SVector(
                        $(Expr(:tuple, (Symbol("∇", i) for i=1:n)...))
                    )))
                ))
            end

            function evaluate_and_jacobian!(u::AbstractVector, U::AbstractMatrix, S::$(name){T, N}, x::AbstractVector) where {T, N}
                @boundscheck length(x) ≥ N
                $(begin
                    u = [Symbol("u", i) for i = 1:n]
                    ∇ = [Symbol("∇", i) for i = 1:n]
                    exprs = Expr[]
                    for i=1:n
                        lhs = Expr(:tuple, u[i], ∇[i])
                        push!(exprs, :($lhs = StaticPolynomials._val_gradient(S.$(fs[i]), x)))
                        push!(exprs, :(u[$i] = $(u[i])))
                        push!(exprs, :(U[$i, :] .= $(∇[i])))
                    end
                    Expr(:block, exprs..., :(nothing))
                end)
            end

            function evaluate_and_jacobian(S::$(name){T, N}, x::SVector{N, T2}) where {T, T2, N}
                $(begin
                    u = [Symbol("u", i) for i = 1:n]
                    ∇ = [Symbol("∇", i) for i = 1:n]
                    exprs = Expr[]
                    for i=1:n
                        lhs = Expr(:tuple, u[i], ∇[i])
                        push!(exprs, :($lhs = StaticPolynomials._val_gradient(S.$(fs[i]), x)))
                    end
                    val = :(SVector($(Expr(:tuple, u...))))
                    jac = :(assemble_matrix(SVector($(Expr(:tuple, ∇...)))))
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
end

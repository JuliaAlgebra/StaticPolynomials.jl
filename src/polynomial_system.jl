export PolynomialSystem, evaluate!, jacobian!, jacobian, evaluate_and_jacobian!, evaluate_and_jacobian

import Base: @propagate_inbounds

"""
    PolynomialSystem{N, NVars, <:Tuple}

A polynomial system of `N` polynomials in `NVars` variables.

Constructors:

    PolynomialSystem(polys::AbstractVector{<:MP.AbstractPolynomial}; variables=MP.variables(polys), parameters=nothing)
    PolynomialSystem(polys::MP.AbstractPolynomial...; kwargs...)

Create a system of polynomials from the given polynomials `polys`.
This function is by design not typestable.

## Example
```julia
julia> import DynamicPolynomials: @polyvar
julia> @polyvar x y a
julia> PolynomialSystem(x^2+y^2+3, x-y+2, x^2+2y+a; parameters=[a])
PolynomialSystem{3, 2}:
 3 + x² + y²

 2 + x - y

 x² + 2y

```
"""
struct PolynomialSystem{N, NVars, PolyTuple<:Tuple}
    polys::PolyTuple
end

function PolynomialSystem(polys::AbstractVector{<:MP.AbstractPolynomial}; parameters=nothing, variables=diffvars(MP.variables(polys), parameters))
    PolynomialSystem(map(p -> Polynomial(p; variables=variables, parameters=parameters), polys)...)
end
function PolynomialSystem(polys::MP.AbstractPolynomial...; kwargs...)
    PolynomialSystem(collect(polys); kwargs...)
end

function PolynomialSystem(polys::Polynomial...)
    N = length(polys)
    NVars = nvariables(polys[1])
    PolynomialSystem{N, NVars, typeof(polys)}(polys)
end

@deprecate system(polys::AbstractVector{<:MP.AbstractPolynomial}) PolynomialSystem(polys)
@deprecate system(polys::AbstractVector{<:MP.AbstractPolynomial}, vars) PolynomialSystem(polys, variables=vars)
@deprecate system(polys...) PolynomialSystem(polys...)


"""
    npolynomials(F::AbstractSystem)

The number of polynomials of the system `F`.
"""
npolynomials(F::PolynomialSystem) = length(F)
Base.length(F::PolynomialSystem{N}) where N = N

"""
    variables(f::PolynomialSystem)

Returns the variables of `f`.
"""
variables(F::PolynomialSystem) = variables(F.polys[1])

"""
    parameters(f::PolynomialSystem)

Returns the parameters of `f`.
"""
parameters(F::PolynomialSystem) = parameters(F.polys[1])

"""
    nvariables(F::AbstractSystem)

The number of variables of the system `F`.
"""
nvariables(F::PolynomialSystem{N, NVars}) where {N, NVars} = NVars

"""
    foreach(f, F::AbstractSystem)

Iterate over the polynomials of `F` and apply `f` to each polynomial.
"""
@generated function Base.foreach(f::F, G::PolynomialSystem{N}) where {N, F<:Function}
    quote
        $((:(f(G.polys[$i])) for i=1:N)...)
        nothing
    end
end

"""
    scale_coefficients!(F::AbstractSystem{T, M}, λ::AbstractVector)

Scale the coefficients of the polynomials `fᵢ` of `F` by the factor `λᵢ`. `λ` needs to have
have length `M`.
"""
@generated function scale_coefficients!(F::PolynomialSystem{N}, λ::AbstractVector) where {N}
    quote
        $((:(scale_coefficients!(F.polys[$i], λ[$i])) for i=1:N)...)
        F
    end
end


function Base.show(io::IO, p::PolynomialSystem{N, NVars}) where {N, NVars}
    print(io, "PolynomialSystem{$N, $NVars}:")
    foreach(pi -> println(io, "\n", " ", pi), p)
end

function Base.print(io::IO, p::PolynomialSystem{N, NVars}) where {N, NVars}
    print(io, "PolynomialSystem{$N, $NVars}(")
    foreach(pi -> print(io, pi, ", "), p)
    print(")")
end

############
# Evaluate
############

@propagate_inbounds evaluate(F::PolynomialSystem, x::SVector) = SVector(_evaluate(F, x))
@propagate_inbounds evaluate(F::PolynomialSystem, x::SVector, p) = SVector(_evaluate(F, x, p))
@propagate_inbounds evaluate(F::PolynomialSystem, x::AbstractVector) = collect(_evaluate(F, x))
@propagate_inbounds evaluate(F::PolynomialSystem, x::AbstractVector, p) = collect(_evaluate(F, x, p))

@generated function _evaluate(F::PolynomialSystem{N, NVars, T}, x...) where {N, NVars, T}
    quote
        $(Expr(:tuple, (:(evaluate(F.polys[$i], x...)) for i=1:N)...))
    end
end

(F::PolynomialSystem)(x) = evaluate(F, x)
(F::PolynomialSystem)(x, p) = evaluate(F, x, p)

"""
     evaluate!(u, F::PolynomialSystem, x::AbstractVector, [p])
"""
@propagate_inbounds evaluate!(u, F::PolynomialSystem, x::AbstractVector) = _evaluate!(u, F, x)
@propagate_inbounds evaluate!(u, F::PolynomialSystem, x::AbstractVector, p) = _evaluate!(u, F, x, p)

@generated function _evaluate!(u, F::PolynomialSystem{N, NVars, T}, x...) where {N, NVars, T}
    quote
        Base.@_propagate_inbounds_meta
        $((:(u[$i] = evaluate(F.polys[$i], x...)) for i=1:N)...)
        u
    end
end



############
# JACOBIAN
###########
@propagate_inbounds jacobian!(U, F::PolynomialSystem, x::AbstractVector) = _jacobian!(U, F, x)
@propagate_inbounds jacobian!(U, F::PolynomialSystem, x::AbstractVector, p) = _jacobian!(U, F, x, p)

@generated function _jacobian!(U, F::PolynomialSystem{N, NVars, T}, x...) where {N, NVars, T}
    quote
        Base.@_propagate_inbounds_meta
        $(map(1:N) do i
            quote
                $∇ = _gradient(F.polys[$i], x...)
                for j=1:$NVars
                    U[$i, j] = ∇[j]
                end
            end
        end...)
        U
    end
end

@propagate_inbounds jacobian(F::PolynomialSystem, x) = Matrix(_jacobian(F, x))
@propagate_inbounds jacobian(F::PolynomialSystem, x, p) = Matrix(_jacobian(F, x, p))
@propagate_inbounds jacobian(F::PolynomialSystem, x::SVector) = _jacobian(F, x)
@propagate_inbounds jacobian(F::PolynomialSystem, x::SVector, p) = _jacobian(F, x, p)

@generated function _jacobian(F::PolynomialSystem{N}, x...) where {N}
    ∇ = [Symbol("∇", i) for i=1:N]
    quote
        $((:($(∇[i]) = _gradient(F.polys[$i], x...)) for i=1:N)...)
        assemble_matrix(SVector(
            $(Expr(:tuple, (∇[i] for i=1:N)...))
        ))
    end
end

@generated function assemble_matrix(vs::SVector{M, SVector{N, T}}) where {T, N, M}
    quote
        SMatrix{$M, $N, $T, $(M*N)}(
            tuple($([:(vs[$i][$j]) for j=1:N for i=1:M]...))
        )
    end
end


########################
# Evaluate and Jacobian
########################

@propagate_inbounds evaluate_and_jacobian!(u, U, F::PolynomialSystem, x::AbstractVector) = _evaluate_and_jacobian!(u, U, F, x)
@propagate_inbounds evaluate_and_jacobian!(u, U, F::PolynomialSystem, x::AbstractVector, p) = _evaluate_and_jacobian!(u, U, F, x, p)

@generated function _evaluate_and_jacobian!(u, U, F::PolynomialSystem{N, NVars, T}, x...) where {N, NVars, T}
    quote
        Base.@_propagate_inbounds_meta
        $(map(1:N) do i
            quote
                val, ∇ = _val_gradient(F.polys[$i], x...)
                u[$i] = val
                for j=1:$NVars
                    U[$i, j] = ∇[j]
                end
            end
        end...)
        nothing
    end
end

@propagate_inbounds function evaluate_and_jacobian(F::PolynomialSystem, x)
    val, jac = _evaluate_and_jacobian(F, x)
    Vector(val), Matrix(jac)
end
@propagate_inbounds function evaluate_and_jacobian(F::PolynomialSystem, x, p)
    val, jac = _evaluate_and_jacobian(F, x, p)
    Vector(val), Matrix(jac)
end
@propagate_inbounds evaluate_and_jacobian(F::PolynomialSystem, x::SVector) = _evaluate_and_jacobian(F, x)
@propagate_inbounds evaluate_and_jacobian(F::PolynomialSystem, x::SVector, p) = _evaluate_and_jacobian(F, x, p)

@generated function _evaluate_and_jacobian(F::PolynomialSystem{N}, x...) where {N}
    val = [Symbol("val", i) for i=1:N]
    ∇ = [Symbol("∇", i) for i=1:N]
    quote
        $((:(($(val[i]), $(∇[i])) = _val_gradient(F.polys[$i], x...)) for i=1:N)...)
        val = SVector($(Expr(:tuple, val...)))
        jac = assemble_matrix(SVector(
            $(Expr(:tuple, (∇[i] for i=1:N)...))
        ))
        val, jac
    end
end


#####################
# Parameter Jacobian
#####################

@propagate_inbounds differentiate_parameters!(U, F::PolynomialSystem, x::AbstractVector, p) = _differentiate_parameters!(U, F, x, p)

@generated function _differentiate_parameters!(U, F::PolynomialSystem{N, NVars, T}, x...) where {N, NVars, T}
    quote
        Base.@_propagate_inbounds_meta
        $(map(1:N) do i
            quote
                $∇ = _gradient(F.polys[$i], x...)
                for j=1:$NVars
                    U[$i, j] = ∇[j]
                end
            end
        end...)
        U
    end
end

@propagate_inbounds differentiate_parameters(F::PolynomialSystem, x, p) = Matrix(_differentiate_parameters(F, x, p))
@propagate_inbounds differentiate_parameters(F::PolynomialSystem, x::SVector, p) = _differentiate_parameters(F, x, p)

@generated function _differentiate_parameters(F::PolynomialSystem{N}, x, p) where {N}
    ∇ = [Symbol("∇", i) for i=1:N]
    quote
        $((:($(∇[i]) = _differentiate_parameters(F.polys[$i], x, p)) for i=1:N)...)
        assemble_matrix(SVector(
            $(Expr(:tuple, (∇[i] for i=1:N)...))
        ))
    end
end

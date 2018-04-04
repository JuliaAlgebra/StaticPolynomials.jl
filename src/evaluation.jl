export evaluate, gradient, gradient!, evaluate_and_gradient, evaluate_and_gradient!

"""
    evaluate(f::Polynomial, x)

Evaluate the polynomial `f` at `x`.
"""
@generated function evaluate(f::Polynomial{T, NVars, E}, x::AbstractVector) where {T, NVars, E}
    evaluate_impl(f)
end
(f::Polynomial)(x::AbstractVector) = evaluate(f, x)

function evaluate_impl(f::Type{Polynomial{T, NVars, E}}) where {T, NVars, E<:SExponents}
    quote
        @boundscheck length(x) ≥ NVars
        c = coefficients(f)
        @inbounds out = begin
            $(generate_evaluate(exponents(E, NVars), T))
        end
        out
    end
end

"""
    gradient(f::Polynomial, x)

Evaluate the gradient of the polynomial `f` at `x`.
"""
function gradient(f::Polynomial{T, NVars}, x::SVector{NVars, S}) where {T, S, NVars}
    _gradient(f, x)
end
gradient(f::Polynomial, x::AbstractVector) = Vector(_gradient(f, x))

"""
    gradient!(u, f::Polynomial, x)

Evaluate the gradient of the polynomial `f` at `x` and store the result in `u`.
"""
function gradient!(u::AbstractVector, f::Polynomial, x::AbstractVector)
    u .= _gradient(f, x)
    u
end

"""
    evaluate_and_gradient(f::Polynomial, x)

Evaluate the polynomial `f` and its gradient at `x`. Returns a tuple.
"""
function evaluate_and_gradient(f::Polynomial{T, NVars}, x::SVector{NVars, S}) where {T, S, NVars}
    _val_gradient(f, x)
end

function evaluate_and_gradient(f::Polynomial, x::AbstractVector)
    @inbounds val, grad = _val_gradient(f, x)
    val, Vector(grad)
end

"""
    evaluate_and_gradient!(u, f::Polynomial, x)

Evaluate the polynomial `f` and its gradient at `x`. Stores the gradient in `u` and
returns the `f(x)`.
"""
function evaluate_and_gradient!(u::AbstractVector, f::Polynomial, x::AbstractVector)
    @inbounds val, grad = _val_gradient(f, x)
    u .= grad
    val
end


@inline function _gradient(f, x)
    @inbounds _, grad = _val_gradient(f, x)
    grad
end
@generated function _val_gradient(f::Polynomial{T, NVars, E}, x::AbstractVector) where {T, NVars, E}
    _val_gradient_impl(f)
end

function _val_gradient_impl(f::Type{Polynomial{T, NVars, E}}) where {T, NVars, E<:SExponents}
    quote
        @boundscheck length(x) ≥ NVars
        c = coefficients(f)
        @inbounds val, grad = begin
            $(generate_gradient(exponents(E, NVars), T))
        end
        val, grad
    end
end

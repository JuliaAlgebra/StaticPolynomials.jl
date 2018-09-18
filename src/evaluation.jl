export evaluate, gradient, gradient!, evaluate_and_gradient, evaluate_and_gradient!

"""
    evaluate(f::Polynomial, x)

Evaluate the polynomial `f` at `x`.
"""
@generated function evaluate(f::Polynomial{T, E, P}, x::AbstractVector) where {T, E, P}
    evaluate_impl(f)
end
(f::Polynomial)(x::AbstractVector) = evaluate(f, x)

function evaluate_impl(f::Type{Polynomial{T, E, P}}) where {T, E, P}
    n = P == Nothing ? 0 : size(P,1)
    access = i -> begin
        :(x[$i])
        # if i ≤ n
        #     :(p[$i])
        # else
        #     :(x[$(i-n)])
        # end
    end

    quote
        @boundscheck length(x) ≥ size(E,1)
        c = coefficients(f)
        @inbounds out = begin
            $(generate_evaluate(exponents(P, E), T, access))
        end
        out
    end
end

"""
    gradient(f::Polynomial, x)

Evaluate the gradient of the polynomial `f` at `x`.
"""
gradient(f::Polynomial, x::AbstractVector) = Vector(_gradient(f, x))
function gradient(f::Polynomial{T, NVars}, x::SVector{NVars, S}) where {T, S, NVars}
    _gradient(f, x)
end

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
function evaluate_and_gradient(f::Polynomial, x::SVector)
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
@generated function _val_gradient(f::Polynomial{T, E, P}, x::AbstractVector) where {T, E, P}
    _val_gradient_impl(f)
end

function _val_gradient_impl(f::Type{Polynomial{T, E, P}}) where {T, E, P}
    n = P == Nothing ? 0 : size(P,1)
    access = i -> begin
        :(x[$i])
        # if i ≤ n
        #     :(p[$i])
        # else
        #     :(x[$(i-n)])
        # end
    end
    quote
        # Base.@_propagate_inbounds_meta
        @boundscheck length(x) ≥ size(E, 1)
        c = coefficients(f)
        @inbounds val, grad = begin
            $(generate_gradient(exponents(E), exponents(P), T, access))
        end
        val, grad
    end
end

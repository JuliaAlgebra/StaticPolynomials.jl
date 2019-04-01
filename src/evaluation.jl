export evaluate, gradient, gradient!,
    evaluate_and_gradient, evaluate_and_gradient!,
    differentiate_parameters, differentiate_parameters!,
    hessian!, hessian, gradient_and_hessian, gradient_and_hessian!

import Base: @propagate_inbounds


@doc """
    evaluate(f::Polynomial, x)

Evaluate the polynomial `f` at `x`.
""" evaluate(f::Polynomial, x)

@doc """
    evaluate(f::Polynomial, x, p)

Evaluate `f` at `x` with parameters `p`.
"""  evaluate(f::Polynomial, x, p)

(f::Polynomial)(x::AbstractVector) = evaluate(f, x)
(f::Polynomial)(x::AbstractVector, p) = evaluate(f, x, p)

function evaluate_impl(f::Type{Polynomial{T, E, P}}) where {T, E, P}
    if P == Nothing
        access_input = x_
    else
        n = size(P, 1)
        access_input(i) = i ≤ n ? :(p[$i]) : :(x[$(i-n)])
    end

    boundschecks = [(:@boundscheck length(x) ≥ $(size(E)[1]))]
    if P != Nothing
        push!(boundschecks, (:@boundscheck length(p) ≥ $(size(P)[1])))
    end

    quote
        $(boundschecks...)
        c = coefficients(f)
        out = @inbounds begin
            $(generate_evaluate(exponents(P, E), T, access_input))
        end
        out
    end
end

@generated function evaluate(f::Polynomial{T, E, Nothing}, x::AbstractVector) where {T, E}
    evaluate_impl(f)
end
@generated function evaluate(f::Polynomial{T, E, P}, x::AbstractVector, p) where {T, E, P}
    evaluate_impl(f)
end

function _val_gradient_impl(f::Type{Polynomial{T, E, P}}) where {T, E, P}
    if P == Nothing
        access_input = x_
    else
        n = size(P, 1)
        access_input(i) = i ≤ n ? :(p[$i]) : :(x[$(i-n)])
    end
    boundschecks = [(:@boundscheck length(x) ≥ $(size(E)[1]))]
    if P != Nothing
        push!(boundschecks, :(@boundscheck length(p) ≥ $(size(P)[1])))
    end

    quote
        $(boundschecks...)
        c = coefficients(f)
        val, grad = @inbounds begin
            $(generate_gradient(exponents(E), exponents(P), T, access_input))
        end
        val, grad
    end
end


@generated function _val_gradient(f::Polynomial{T, E, Nothing}, x::AbstractVector) where {T, E}
    _val_gradient_impl(f)
end

@generated function _val_gradient(f::Polynomial, x::AbstractVector, p)
    _val_gradient_impl(f)
end


@propagate_inbounds @inline function _gradient(f, x)
    _, grad = _val_gradient(f, x)
    grad
end

@propagate_inbounds @inline function _gradient(f, x, p)
    _, grad = _val_gradient(f, x, p)
    grad
end


@doc """
    gradient(f::Polynomial, x)

Evaluate the gradient of the polynomial `f` at `x`.
"""
function gradient(f::Polynomial{T, E, Nothing}, x::AbstractVector) where {T, E}
    Vector(_gradient(f, x))
end
function gradient(f::Polynomial{T, E, Nothing}, x::SVector) where {T, E}
    _gradient(f, x)
end

"""
    gradient(f::Polynomial, x, p)

Evaluate the gradient of the polynomial `f` at `x` with parameters `p`.
"""
gradient(f::Polynomial, x::AbstractVector, p) = Vector(_gradient(f, x, p))
gradient(f::Polynomial, x::SVector, p) = _gradient(f, x, p)


"""
    gradient!(u, f::Polynomial, x)

Evaluate the gradient of the polynomial `f` at `x` and store the result in `u`.

    gradient!(u, f::Polynomial, x, p)

Evaluate the gradient of the polynomial `f` at `x` with parameters `p` and store the result in `u`.
"""
@propagate_inbounds function gradient!(u::AbstractVector, f::Polynomial, x::AbstractVector)
    u .= _gradient(f, x)
    u
end
@propagate_inbounds function gradient!(u::AbstractVector, f::Polynomial, x::AbstractVector, p)
    u .= _gradient(f, x, p)
    u
end


"""
    evaluate_and_gradient(f::Polynomial, x)

Evaluate the polynomial `f` and its gradient at `x`. Returns a tuple.

    evaluate_and_gradient(f::Polynomial, x, p)

Evaluate the polynomial `f` and its gradient at `x` with parameters `p`. Returns a tuple.
"""
function evaluate_and_gradient(f::Polynomial{T, E, Nothing}, x::SVector) where {T, E}
    _val_gradient(f, x)
end
evaluate_and_gradient(f::Polynomial, x::SVector, p) = _val_gradient(f, x, p)

function evaluate_and_gradient(f::Polynomial{T, E, Nothing}, x::AbstractVector) where {T, E}
    val, grad = _val_gradient(f, x)
    val, Vector(grad)
end
function evaluate_and_gradient(f::Polynomial, x::AbstractVector, p)
    val, grad = _val_gradient(f, x, p)
    val, Vector(grad)
end

"""
    evaluate_and_gradient!(u, f::Polynomial, x)

Evaluate the polynomial `f` and its gradient at `x`. Stores the gradient in `u` and
returns the `f(x)`.

    evaluate_and_gradient!(u, f::Polynomial, x, p)

Evaluate the polynomial `f` and its gradient at `x` with parameters `p`. Stores the gradient in `u` and
returns the `f(x)`.
"""
@propagate_inbounds function evaluate_and_gradient!(u::AbstractVector, f::Polynomial{T, E, Nothing}, x::AbstractVector) where {T, E}
    val, grad = _val_gradient(f, x)
    u .= grad
    val
end
@propagate_inbounds function evaluate_and_gradient!(u::AbstractVector, f::Polynomial, x::AbstractVector, p)
    val, grad = _val_gradient(f, x, p)
    u .= grad
    val
end



#############
## Hessian ##
#############

function _gradient_hessian_impl(f::Type{Polynomial{T, E, P}}; return_grad=true) where {T, E, P}
    if P == Nothing
        access_input = x_
    else
        n = size(P, 1)
        access_input(i) = i ≤ n ? :(p[$i]) : :(x[$(i-n)])
    end

    exps = exponents(E)
    params = exponents(P)

    n, m = size(E)

    code = []
    ∇ = [Symbol("∇", i) for i=1:n]
    vals = [Symbol("val", i) for i=1:n]


    # for each variable we simulate the derivative
    for i in 1:n
        coeffsᵢ = Union{Symbol, Expr}[]
        expsᵢ = Vector{eltype(exps)}()
        paramsᵢ = P === nothing ? nothing : Vector{eltype(exps)}()
        mᵢ = 0

        # For each term make the symbolic derivative
        for j in 1:m
            if exps[i,j] == 0
                continue
            end
            for k in 1:n
                if i == k
                    push!(expsᵢ, exps[k, j] - 1)
                    if exps[i,j] > 1
                        push!(coeffsᵢ, :($(exps[i,j]) * c[$j]))
                    else
                        push!(coeffsᵢ, :(c[$j]))
                    end
                else
                    push!(expsᵢ, exps[k, j])
                end
            end
            if params !== nothing
                for k in 1:size(params, 1)
                    push!(paramsᵢ, params[k, j])
                end
            end

            mᵢ += 1
        end
        if mᵢ == 0
            zero_tuple = Expr(:tuple, (:(zero($T)) for _=1:n)...)
            val_grad_codeᵢ = :((zero($T), SVector($zero_tuple)))
        else
            Eᵢ = reshape(expsᵢ, (n, mᵢ))
            Pᵢ = P === nothing ? nothing : reshape(paramsᵢ, (size(paramsᵢ, 1), mᵢ))
            val_grad_codeᵢ = generate_gradient(Eᵢ, Pᵢ, T, access_input, coeffsᵢ)
        end

        push!(code, :($(Expr(:tuple, vals[i], ∇[i])) = begin $(val_grad_codeᵢ) end))
    end


    push!(code, :(grad = SVector($(Expr(:tuple, vals...)))))
    push!(code, :(hess = assemble_matrix(SVector($(Expr(:tuple, (∇[i] for i=1:n)...))))))
    quote
        @boundscheck length(x) ≥ $(size(E)[1])
        c = coefficients(f)
        $(code...)
        grad, hess
    end
end

@generated function gradient_and_hessian(f::Polynomial{T,E,Nothing}, x::AbstractVector) where {T, E}
    _gradient_hessian_impl(f)
end
@generated function gradient_and_hessian(f::Polynomial, x::AbstractVector, p)
    _gradient_hessian_impl(f)
end

@doc """
     gradient_and_hessian(F::PolynomialSystem, x, [p])

Compute the gradient and Hessian of `f` at `x`.
""" gradient_and_hessian(F::Polynomial, x)

"""
    gradient_and_hessian!(u, U, f::Polynomial, x, [p])

Compute the gradient and Hessian of `f` at `x` and store them in `u` and `U`.
"""
function gradient_and_hessian!(u, U, f::Polynomial, xp...)
    grad, hess = gradient_and_hessian(f, xp...)
    u .= grad
    U .= hess
    nothing
end

"""
    hessian(f::Polynomial, x, [p])

Compute the hessian of `f` at `x`.
"""
function hessian(f::Polynomial, xp...)
    last(gradient_and_hessian(f, xp...))
end

"""
    hessian!(U, f::Polynomial, x, [p])

Compute the hessian of `f` at `x` and store it in `U`.
"""
function hessian!(U, f::Polynomial, xp...)
    U .= hessian(f, xp...)
    U
end


################
## Parameters ##
################
function _differentiate_parameters_impl(f::Type{Polynomial{T, E, P}}) where {T, E, P}
    @assert P != Nothing

    # The role of E and P is interchanged
    n = size(E, 1)
    access_input(i) = i ≤ n ? :(x[$i]) : :(p[$(i-n)])

    quote
        @boundscheck length(x) ≥ $(size(E, 1))
        @boundscheck length(p) ≥ $(size(P, 1))
        c = coefficients(f)
        @inbounds begin
            $(generate_differentiate_parameters(exponents(E), exponents(P), T, access_input))
        end
    end
end

@generated function _differentiate_parameters(f::Polynomial, x::AbstractVector, p)
    _differentiate_parameters_impl(f)
end


@doc """
    differentiate_parameters(f::Polynomial, x, p)

Evaluate the gradient of the polynomial `f` w.r.t. the parameters at `x` with parameters `p`.
"""
differentiate_parameters(f::Polynomial, x, p) = Vector(_differentiate_parameters(f, x, p))
differentiate_parameters(f::Polynomial, x::SVector, p) = _differentiate_parameters(f, x, p)


@doc """
    differentiate_parameters!(u, f::Polynomial, x, p)

Evaluate the gradient of the polynomial `f` w.r.t. the parameters at `x` with parameters `p` and store the result in `u`.
"""
function differentiate_parameters!(u, f::Polynomial, x, p)
    u .= _differentiate_parameters(f, x, p)
    u
end

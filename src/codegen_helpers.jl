x_(i::Int) = :(x[$i])
x_(ik::NTuple{2, Int}) = ik[2] == 1 ? x_(ik[1]) : Symbol("x", ik[1], "_", ik[2])
u_(i::Int) = Symbol("u", i)
u_(i1::Int, i2::Int) = Symbol("u", i1, "_", i2)
u_(ik::NTuple{2, Int}) = ik[2] == 1 ? u_(ik[1]) : Symbol("u", ik[1], "_", ik[2])
c_(i::Int) = Symbol("c", i)
c_(i::Int, d::Int) = Symbol("c_", i, "_", d)

"""
    batch_arithmetic_ops(op, operands)

Adds additional parenthes due to the following julia bug:
https://github.com/JuliaLang/julia/issues/14821
"""
function batch_arithmetic_ops(op::Symbol, ops)
    batch_size = 3
    l = 1
    if length(ops) == 1
        return :($(ops[1]))
    elseif length(ops) < batch_size + 2
        return Expr(:call, op, ops...)
    end
    batches = []
    while l ≤ length(ops)
        batch_end = min(length(ops), l + batch_size)
        if l == batch_end
            push!(batches, :($(ops[l])))
        else
            push!(batches, Expr(:call, op, ops[l:batch_end]...))
        end
        l = batch_end + 1
    end
    if length(batches) > 1
        return batch_arithmetic_ops(op, batches)
    else
        return batches[1]
    end
end

"""
    evalpoly(::Type{T}, degrees, coefficients, var::Union{Symbol, Expr})

Evaluate the polynomial defined by the degrees and coefficients.
"""
function evalpoly(::Type{T}, degrees::AbstractVector, coefficients::AbstractVector, var) where T
    normalized_coeffs = normalized_coefficients(T, degrees, coefficients)

    if length(normalized_coeffs) == 1
        return normalized_coeffs[1]
    end
    # TODO: Be smarter since we know the zeros...
    :(@evalpoly($var, $(normalized_coeffs...)))
end


"""
    eval_derivative_poly(::Type{T}, degrees, coefficients, var::Union{Symbol, Expr})

Evaluate the polynomial and its derivative defined by the degrees and coefficients.
"""
function eval_derivative_poly!(exprs, ::Type{T}, degrees::AbstractVector, coefficients::AbstractVector, var) where T
    normalized_coeffs = normalized_coefficients(T, degrees, coefficients)

    @gensym dval val

    push!(exprs, :($dval = zero($T)), :($val=zero($T)))

    # TODO: Make this way smater
    deg = length(normalized_coeffs)
    for k = deg:-1:1
        if k < deg
            push!(exprs, :($dval = muladd($dval, $var, $val)))
        end
        push!(exprs, :($val = muladd($val, $var, $(normalized_coeffs[k]))))
    end

    return val, dval
end


"""
    normalized_poly_coefficents(::Type{T}, degrees, coefficients)

Return the cofficients of an univariate polynomial in standard form.
Assume the degrees are in ascending form.

## Example
```julia
julia> normalized_poly_coefficents(Float64, [1, 3], [:c_3, :c_5])
[:(zero(Float64)), :c_3, :(zero(Float64)), :c_5]
```
"""
function normalized_coefficients(::Type{T}, degrees::AbstractVector, coefficients::AbstractVector) where T
    ops = []
    d = degrees[end]
    k = 0
    i = 1
    while k ≤ d
        if i ≤ length(degrees) && degrees[i] == k
            push!(ops, coefficients[i])
            i += 1
        else
            push!(ops, :(zero($T)))
        end
        k += 1
    end
    ops
end



"""
    monomial_product(::Type{T}, exponent, coefficient, i::Union{Void, Int}=nothing)

Generate the monomial product defined by `exponent` with `ooefficient.`
If `i` is an `Int` the partial derivative will be generated.
"""
function monomial_product(::Type{T}, exponent::AbstractVector, coefficient, i::Union{Void, Int}=nothing) where T
    if i !== nothing && exponent[i] == 0
        return :(zero($T))
    end
    ops = []
    push!(ops, coefficient)
    for (k, e) in enumerate(exponent)
        if k == i && e == 1
            continue
        elseif k == i && e > 1
            unshift!(ops, :($e))
            if e > 2
                push!(ops, :($(x_(k))^$(e - 1)))
            else
                # e = 1
                push!(ops, :($(x_(k))))
            end
        elseif e == 1
            push!(ops, :($(x_(k))))
        elseif e > 1
            push!(ops, :($(x_(k))^$e))
        end
    end
    batch_arithmetic_ops(:*, ops)
end


function monomial_product_with_derivatives(::Type{T}, exponent::AbstractVector, coefficient) where T
    val = monomial_product(T, exponent, coefficient)
    dvals = map(1:length(exponent)) do i
        monomial_product(T, exponent, coefficient, i)
    end

    val, dvals
end

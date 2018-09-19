x_(i::Int) = :(x[$i])

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
    return length(batches) == 1 ? batches[1] : batch_arithmetic_ops(op, batches)
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
    monomial_product(::Type{T}, exponent, coefficient, i::Union{Nothing, Int}=nothing)

Generate the monomial product defined by `exponent` with `coefficient.`
If `i` is an `Int` the partial derivative will be generated.
"""
function monomial_product(::Type{T}, exponent, coefficient, i::Union{Nothing, Int}=nothing; access_input=x_) where T
    if i !== nothing && exponent[i] == 0
        return (:(zero($T)), true)
    end
    ops = []
    push!(ops, coefficient)
    for (k, e) in enumerate(exponent)
        if k == i && e == 1
            continue
        elseif k == i && e > 1
            pushfirst!(ops, :($e))
            push!(ops, pow(access_input(k), e - 1))
        elseif e > 0
            push!(ops, pow(access_input(k), e))
        end
    end
    (batch_arithmetic_ops(:*, ops), false)
end


function monomial_product_with_derivatives(::Type{T}, exponent, coefficient; access_input=x_) where T
    val, _ = monomial_product(T, exponent, coefficient, access_input=access_input)
    dvals = map(1:length(exponent)) do i
        monomial_product(T, exponent, coefficient, i, access_input=access_input)
    end

    val, dvals
end


function pow(expr::Union{Expr,Symbol}, k::Integer)
    if k == 2
        :($expr * $expr)
    elseif k == 3
        :(($expr * $expr * $expr))
    elseif k == 4
        @gensym p
        quote
            $p = $expr * $expr
            $p * $p
        end
    elseif k == 1
        :($expr)
    elseif k == 0
        :(one($expr))
    else
        :(pow($expr, $k))
    end
end

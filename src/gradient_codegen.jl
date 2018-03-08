"""
    generate_gradient(E, ::Type{T})

Generate the statements for the evaluation of the polynomial with exponents `E`.
This assumes that E is in reverse lexicographic order.
"""
function generate_gradient(E, ::Type{T}) where T
    exprs = []
    generate_gradient!(exprs, E, T, size(E, 1), 1)
    Expr(:block, exprs...)
end

function generate_gradient!(exprs, E, ::Type{T}, nvar, nterm) where T
    m, n = size(E)

    if n == 1
        return monomial_product_val_derivatives(T, E[:,1], nterm)
    end

    if m == 1
        coeffs = [:(c[$j]) for j=nterm:nterm+n]
        return evalpoly(T, E[1,:], coeffs, x_(nvar))
    end

    # Recursive
    coeffs = []
    sub_nterm = nterm
    degrees = Int[]
    for (d, E_d) in degree_submatrices(E)
        push!(degrees, d)
        coeff_subexpr = generate_gradient!(exprs, E_d, T, nvar - 1, sub_nterm)
        c = gensym("c")
        # c = c_(nvar - 1, d)
        push!(exprs, :($c = $coeff_subexpr))
        push!(coeffs, c)
        sub_nterm += size(E_d, 2)
    end

    return evalpoly(T, degrees, coeffs, x_(nvar))
end

function monomial_product_val_derivatives(::Type{T}, exps::AbstractVector, coefficient) where T
    val = monomial_product_derivative(T, exps, coefficient, nothing)
    dvals = map(1:length(exps)) do i
        monomial_product_derivative(T, exps, coefficient, i)
    end

    val, dvals
end

function monomial_product_derivative(::Type{T}, exps::AbstractVector, coefficient, i::Union{Void, Int}) where T
    if i !== nothing && exps[i] == 0
        return :(zero($T))
    end
    ops = []
    push!(ops, coefficient)
    for (k, e) in enumerate(exps)
        if k != i
            push!(ops, :($(x_(k))^$e))
        elseif e > 1
            unshift!(ops, :($e))
            push!(ops, :($(x_(k))^$(e - 1)))
        end
    end
    batch_arithmetic_ops(:*, ops)
end

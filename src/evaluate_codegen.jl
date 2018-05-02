"""
    generate_evaluate(E, ::Type{T})

Generate the statements for the evaluation of the polynomial with exponents `E`.
This assumes that E is in reverse lexicographic order.
"""
function generate_evaluate(E, ::Type{T}) where T
    exprs = []
    last_expr = generate_evaluate!(exprs, E, T, size(E, 1), 1)
    Expr(:block, exprs..., last_expr)
end

function generate_evaluate!(exprs, E, ::Type{T}, nvar, nterm) where T
    m, n = size(E)

    if n == 1
        return first(monomial_product(T, E[:,1], :(c[$nterm])))
    end

    if m == 1
        coeffs = [:(c[$j]) for j=nterm:nterm+n]
        return evalpoly(T, E[1,:], coeffs, x_(nvar))
    end

    # Recursive
    coeffs = []
    sub_nterm = nterm
    degrees, submatrices = degrees_submatrices(E)
    for E_d in submatrices
        coeff_subexpr = generate_evaluate!(exprs, E_d, T, nvar - 1, sub_nterm)
        @gensym c
        push!(exprs, :($c = $coeff_subexpr))
        push!(coeffs, c)
        sub_nterm += size(E_d, 2)
    end

    return evalpoly(T, degrees, coeffs, x_(nvar))
end

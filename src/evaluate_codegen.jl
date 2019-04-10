"""
    generate_evaluate(E, ::Type{T})

Generate the statements for the evaluation of the polynomial with exponents `E`.
This assumes that E is in reverse lexicographic order.
"""
function generate_evaluate(E, ::Type{T}, access_input) where T
    exprs = []
    coeffs = map(i -> :(c[$i]), 1:size(E, 2))
    last_expr = generate_evaluate!(exprs, E, T, size(E, 1), 1, coeffs, access_input)
    Expr(:block, exprs..., last_expr)
end

function generate_evaluate!(exprs, E, ::Type{T}, nvar, nterm, coeffs, access_input) where T
    m, n = size(E)

    if n == 1
        return first(monomial_product(T, E[:,1], coeffs[nterm], access_input=access_input))
    end

    if m == 1
        return evalpoly(T, E[1,:], coeffs[nterm:nterm+n-1], access_input(nvar))
    end

    # Recursive
    rec_coeffs = []
    sub_nterm = nterm
    degrees, submatrices = degrees_submatrices(E)
    for E_d in submatrices
        coeff_subexpr = generate_evaluate!(exprs, E_d, T, nvar - 1, sub_nterm, coeffs, access_input)
        # If the returned value is just a symbol propagate it
        if isa(coeff_subexpr, Symbol)
            push!(rec_coeffs, coeff_subexpr)
        else
            @gensym c
            push!(exprs, :($c = $coeff_subexpr))
            push!(rec_coeffs, c)
        end
        sub_nterm += size(E_d, 2)
    end

    return evalpoly(T, degrees, rec_coeffs, access_input(nvar))
end

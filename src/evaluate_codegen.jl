"""
    generate_evaluate(E, ::Type{T})

Generate the statements for the evaluation of the polynomial with exponents `E`.
This assumes that E is in reverse lexicographic order.
"""
function generate_evaluate(E, ::Type{T}) where T
    exprs = []
    generate_evaluate!(exprs, E, T, size(E, 1), 1)
    Expr(:block, exprs...)
end

function generate_evaluate!(exprs, E, ::Type{T}, nvar, nterm) where T
    m, n = size(E)

    if n == 1
        return monomial_product(E[:,1], nterm)
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
        coeff_subexpr = generate_evaluate!(exprs, E_d, T, nvar - 1, sub_nterm)
        c = gensym("c")
        # c = c_(nvar - 1, d)
        push!(exprs, :($c = $coeff_subexpr))
        push!(coeffs, c)
        sub_nterm += size(E_d, 2)
    end

    return evalpoly(T, degrees, coeffs, x_(nvar))
end


function monomial_product(exps::AbstractVector, nterm)
    ops = Expr[]
    push!(ops, :(c[$nterm]))
    for (i, e) in enumerate(exps)
        push!(ops, :($(x_(i))^$e))
    end
    batch_arithmetic_ops(:*, ops)
end

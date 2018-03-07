"""
    generate_evaluate(E, ::Type{T})

Generate the statements for the evaluation of the polynomial with exponents `E`.
This assumes that E is in reverse lexicographic order.
"""
generate_evaluate(E, ::Type{T}) where T = generate_evaluate(E, T, size(E, 1), 1)
function generate_evaluate(E, ::Type{T}, nvar, nterm) where T
    m, n = size(E)

    if n == 1
        return monomial_product(E[:,1], nterm)
    end

    if m == 1
        coeffs = [:(c[$j]) for j=nterm:nterm+n]
        return evalpoly(T, E[1,:], coeffs, x_(nvar))
    end

    # Recursive
    # we create submatrices
    submatrices, degrees = create_submatrices_degrees(E)

    coeffs_subexpr = []
    coeffs = []
    sub_nterm = nterm
    for (k, submatrix) in enumerate(submatrices)
        coeff_subexpr = generate_evaluate(submatrix, T, nvar - 1, sub_nterm)
        c = c_(nvar - 1, degrees[k])
        push!(coeffs_subexpr, :($c = $coeff_subexpr))
        push!(coeffs, c)
        sub_nterm += size(submatrix, 2)
    end

    return Expr(:block, coeffs_subexpr..., evalpoly(T, degrees, coeffs, x_(nvar)))
end

function create_submatrices_degrees(E)
    submatrices = Vector{typeof(@view E[1:end-1, 1:1])}()# Vector{Matrix{Int}}()
    degrees = Int[]
    j = 1
    last_d_change = 1
    d = E[end, 1]
    n = size(E, 2)
    while j < n
        if E[end,j + 1] != d
            push!(submatrices, @view E[1:end-1, last_d_change:j])
            push!(degrees, d)
            d = E[end,j + 1]
            last_d_change = j+1
        end
        j += 1
    end
    push!(submatrices, @view E[1:end-1, last_d_change:end])
    push!(degrees, E[end, end])
    submatrices, degrees
end


function monomial_product(exps::AbstractVector, nterm)
    ops = Expr[]
    push!(ops, :(c[$nterm]))
    for (i, e) in enumerate(exps)
        push!(ops, :($(x_(i))^$e))
    end
    batch_arithmetic_ops(:*, ops)
end

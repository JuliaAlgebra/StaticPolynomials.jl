"""
    generate_gradient(E, ::Type{T})

Generate the statements for the evaluation of the polynomial with exponents `E`.
This assumes that E is in reverse lexicographic order.
"""
function generate_gradient(E, ::Type{T}) where T
    exprs = []
    val, dvals = partial_derivatives!(exprs, E, T, size(E, 1), 1)
    out = :($(val), SVector($(Expr(:tuple, map(first, dvals)...))))

    Expr(:block, exprs..., out)
end

function term(E::AbstractMatrix, ::Type{T}, nterm) where T
    @assert size(E, 2) == 1

    monomial_product_with_derivatives(T, E, :(c[$nterm]))
end

function univariate!(exprs, E::AbstractMatrix, ::Type{T}, nvar, nterm) where T
    @assert size(E, 1) == 1
    n = size(E, 2)
    coeffs = [:(c[$j]) for j=nterm:nterm+n]
    val, dval = evalpoly_derivative!(exprs, T, @view(E[1,:]), coeffs, x_(nvar))

    val, [(dval, n == 1)]
end


function partial_derivatives!(exprs, E, ::Type{T}, nvar, nterm) where T
    m, n = size(E)

    # We only have one Term remaining. So we just evaluate the term and compute all
    # partial derivatives
    if n == 1
        return term(E, T, nterm)
    elseif m == 1
        return univariate!(exprs, E, T, nvar, nterm)
    end

    degrees, submatrices = degrees_submatrices(E)
    values = []
    dvalues = []
    for (k, E_d) in enumerate(submatrices)
        val, dvals = partial_derivatives!(exprs, E_d, T, nvar - 1, nterm)
        push!(values, val)
        push!(dvalues, dvals)

        nterm += size(E_d, 2)
    end
    # Now we have to evaluate polynomials
    # for our current variable we need our new partial derivative
    val, derivative_val = evalpoly_derivative!(exprs, T, degrees, values, x_(nvar))
    dvals = []
    reverse!(dvalues)
    for k=1:(m-1)
        coeffs_k = []
        for dv in dvalues
            dval, iszero = dv[k]
            if !isempty(coeffs_k) || !iszero
                pushfirst!(coeffs_k, dval)
            end
        end
        degrees_k = degrees[1:length(coeffs_k)]
        # we do not need assign a new variable and call evalpoly
        # if we just have a degree 0 polynomial with already computed coefficient
        if length(degrees_k) == 1 && degrees_k[1] == 0 && coeffs_k[1] isa Symbol
            push!(dvals, (coeffs_k[1], false))
        elseif length(degrees_k) > 0
            @gensym c
            push!(exprs, :($c = $(evalpoly(T, degrees_k, coeffs_k, x_(nvar)))))
            push!(dvals, (c, false))
        else
            push!(dvals, (:(zero($T)), true))
        end
    end
    push!(dvals, (derivative_val, length(degrees) == 1))

    val, dvals
end

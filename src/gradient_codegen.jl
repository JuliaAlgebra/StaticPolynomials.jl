"""
    generate_gradient(E, P, ::Type{T}, access)

Generate the statements for the evaluation of the polynomial with exponents `E`
and paramter exponents `P`.
This assumes that `E` and `P` are in reverse lexicographic order.
"""
function generate_gradient(E, P, ::Type{T}, access) where T
    exprs = []
    # dvals is a list of tuples (s, iszero) where s is a symbol or expression
    # representing the partial derivative and iszero a boolean flag
    # indicating whether s is zero.
    nvars = size(E,1)
    if P !== nothing
        nvars += size(P, 1)
    end

    val, dvals = partial_derivatives!(exprs, E, P, T, nvars, 1, access)
    out = :($(val), SVector($(Expr(:tuple, map(first, dvals)...))))

    Expr(:block, exprs..., out)
end

function partial_derivatives!(exprs, E, P, ::Type{T}, nvar, nterm, access) where T
    m, n = size(E)

    # We only have one Term remaining. So we just evaluate the term and compute all
    # partial derivatives
    if n == 1
        return term(E, P, T, nterm, access)
    elseif m == 1
        return univariate!(exprs, E, P, T, nvar, nterm, access)
    end

    degrees, submatrices = degrees_submatrices(E)
    values = []
    dvalues = []

    for (k, E_d) in enumerate(submatrices)
        val, dvals = partial_derivatives!(exprs, E_d, P, T, nvar - 1, nterm, access)
        push!(values, val)
        push!(dvalues, dvals)

        nterm += size(E_d, 2)
    end
    # Now we have to evaluate polynomials
    # for our current variable we need our new partial derivative
    val, derivative_val = evalpoly_derivative!(exprs, T, degrees, values, access(nvar))
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
            push!(exprs, :($c = $(evalpoly(T, degrees_k, coeffs_k, access(nvar)))))
            push!(dvals, (c, false))
        else
            push!(dvals, (:(zero($T)), true))
        end
    end
    derivative_val_iszero = isempty(degrees) || (length(degrees) == 1 && degrees[1] == 0)
    push!(dvals, (derivative_val, derivative_val_iszero))

    val, dvals
end

function term(E::AbstractMatrix, P, ::Type{T}, nterm, access) where T
    @assert size(E, 2) == 1
    c = term_coefficient_with_parameters(T, P, nterm, access)
    offset = P === nothing ? 0 : size(P, 1)
    monomial_product_with_derivatives(T, E, c, access=i -> access(i+offset))
end

"""
    term_coefficient_with_parameters(T, P, nterm, access)

Compute the coefficient of the `nterm`-th term with possible parameters.
"""
function term_coefficient_with_parameters(T, P, nterm, access)
    monomial_product(T, P[:,nterm], :(c[$nterm]), access=access)[1]
end
term_coefficient_with_parameters(T, ::Nothing, nterm, access) = :(c[$nterm])

"""
    univariate!(exprs, E::AbstractMatrix, P, ::Type{T}, nvar, nterm, access)

`E` represents an univariate polynomial.
"""
function univariate!(exprs, E::AbstractMatrix, P, ::Type{T}, nvar, nterm, access) where T
    @assert size(E, 1) == 1
    n = size(E, 2)
    # If we have parameters it can happen that there are duplicates E
    # For each group of duplicates we have to evaluate the coefficient polynomial
    coeffs, E_filtered = coefficients_with_parameters!(exprs, E, P, T, nterm, access)

    val, dval = evalpoly_derivative!(exprs, T, E_filtered, coeffs, access(nvar))
    val, [(dval, n == 1)]
end

"""
    coefficients_with_parameters!(exprs, E, P, ::Type{T}, nterm, access)

If we have parameters it can happen that there are duplicates in E.
For each group of duplicates we have to evaluate the coefficient polynomial.
If there are no parameters this is simply the coefficients vector.
"""
function coefficients_with_parameters!(exprs, E, ::Nothing, ::Type{T}, nterm, access) where T
    n = size(E, 2)
    [:(c[$j]) for j=nterm:nterm+n-1], vec(E)
end
function coefficients_with_parameters!(exprs, E, P, ::Type{T}, nterm, access) where T
    n = size(E, 2)
    coeffs = []
    last = 1
    j = 1
    E_filtered = [E[1,1]]
    while j ≤ n
        if E[1,j] !== E_filtered[end]
            push!(E_filtered, E[1,j])
        end
        if j < n && E[1, j + 1] == E[1, j]
            j += 1
            continue
        end
        j += 1

        nterm_sub = nterm+last-1

        nduplicates = j - last - 1
        if nduplicates == 0 # nothing happened
            c, _ = monomial_product(T, P[:,nterm_sub], :(c[$nterm_sub]), access=access)
            push!(coeffs, c)
        else
            # we have duplicates, so we consider the rest (the parameters) as an polynomial
            # and pass it to evaluate
            P_sub = @view P[:,nterm_sub:nterm+j-2]
            c = generate_evaluate!(exprs, P_sub, T, size(P, 1), nterm_sub, access)
            push!(coeffs, c)
        end
        last = j
    end
    coeffs, E_filtered
end

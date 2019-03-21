"""
    generate_gradient(E, P, ::Type{T}, access_input)

Generate the statements for the evaluation of the polynomial with exponents `E`
and paramter exponents `P`.
This assumes that `E` and `P` are in reverse lexicographic order.
"""
function generate_gradient(E, P, ::Type{T}, access_input,coeffs=map(i -> :(c[$i]), 1:size(E, 2))) where T
    nvars = size(E,1)
    if P !== nothing
        nvars += size(P, 1)
    end

    exprs = []
    # dvals is a list of tuples (s, iszero) where s is a symbol or expression
    # representing the partial derivative and iszero a boolean flag
    # indicating whether s is zero.
    val, dvals = partial_derivatives!(exprs, E, P, T, nvars, 1, coeffs, access_input)
    out = :($(val), SVector($(Expr(:tuple, map(first, dvals)...))))

    Expr(:block, exprs..., out)
end

function partial_derivatives!(exprs, E, P, ::Type{T}, nvar, nterm, coeffs, access_input) where T
    m, n = size(E)

    # We only have one Term remaining. So we just evaluate the term and compute all
    # partial derivatives
    if n == 1
        return term(E, P, T, nterm, coeffs, access_input)
    elseif m == 1
        return univariate!(exprs, E, P, T, nvar, nterm, coeffs, access_input)
    end

    degrees, submatrices = degrees_submatrices(E)
    values = []
    dvalues = []

    for (k, E_d) in enumerate(submatrices)
        val, dvals = partial_derivatives!(exprs, E_d, P, T, nvar - 1, nterm, coeffs, access_input)
        push!(values, val)
        push!(dvalues, dvals)

        nterm += size(E_d, 2)
    end
    # Now we have to evaluate polynomials
    # for our current variable we need our new partial derivative
    val, derivative_val = evalpoly_derivative!(exprs, T, degrees, values, access_input(nvar))
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
            push!(exprs, :($c = $(evalpoly(T, degrees_k, coeffs_k, access_input(nvar)))))
            push!(dvals, (c, false))
        else
            push!(dvals, (:(zero($T)), true))
        end
    end
    derivative_val_iszero = isempty(degrees) || (length(degrees) == 1 && degrees[1] == 0)
    push!(dvals, (derivative_val, derivative_val_iszero))

    val, dvals
end

function term(E::AbstractMatrix, P, ::Type{T}, nterm, coeffs, access_input) where T
    @assert size(E, 2) == 1
    c = term_coefficient_with_parameters(T, P, nterm, coeffs, access_input)
    offset = P === nothing ? 0 : size(P, 1)
    monomial_product_with_derivatives(T, E, c, access_input=i -> access_input(i+offset))
end

"""
    term_coefficient_with_parameters(T, P, nterm, access_input)

Compute the coefficient of the `nterm`-th term with possible parameters.
"""
function term_coefficient_with_parameters(T, P, nterm, coeffs, access_input)
    monomial_product(T, P[:,nterm], coeffs[nterm], access_input=access_input)[1]
end
term_coefficient_with_parameters(T, ::Nothing, nterm, coeffs, access_input) = coeffs[nterm]

"""
    univariate!(exprs, E::AbstractMatrix, P, ::Type{T}, nvar, nterm, access_input)

`E` represents an univariate polynomial.
"""
function univariate!(exprs, E::AbstractMatrix, P, ::Type{T}, nvar, nterm, coeffs, access_input) where T
    @assert size(E, 1) == 1
    n = size(E, 2)
    # If we have parameters it can happen that there are duplicates E
    # For each group of duplicates we have to evaluate the coefficient polynomial
    rec_coeffs, E_filtered = coefficients_with_parameters!(exprs, E, P, T, nterm, coeffs, access_input)

    val, dval = evalpoly_derivative!(exprs, T, E_filtered, rec_coeffs, access_input(nvar))
    val, [(dval, n == 1)]
end

"""
    coefficients_with_parameters!(exprs, E, P, ::Type{T}, nterm, coeffperm, access_input)

If we have parameters it can happen that there are duplicates in E.
For each group of duplicates we have to evaluate the coefficient polynomial.
If there are no parameters this is simply the coefficients vector.
"""
function coefficients_with_parameters!(exprs, E, ::Nothing, ::Type{T}, nterm, coeffs, access_input) where T
    n = size(E, 2)
    coeffs[nterm:nterm+n-1], vec(E)
end
function coefficients_with_parameters!(exprs, E, P, ::Type{T}, nterm, coeffs, access_input) where T
    n = size(E, 2)
    pcoeffs = []
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
            c, _ = monomial_product(T, P[:,nterm_sub], coeffs[nterm_sub], access_input=access_input)
            push!(pcoeffs, c)
        else
            # we have duplicates, so we consider the rest (the parameters) as an polynomial
            # and pass it to evaluate
            P_sub = @view P[:,nterm_sub:nterm+j-2]
            c = generate_evaluate!(exprs, P_sub, T, size(P, 1), nterm_sub, coeffs, access_input)
            push!(pcoeffs, c)
        end
        last = j
    end
    pcoeffs, E_filtered
end

function generate_differentiate_parameters(E, P, ::Type{T}, access_input) where T
    @assert P !== nothing
    nvars = size(E,1) + size(P, 1)

    # E and P are sorted with respect to [P; E] but since we want to derivate wrt
    # the parameters we habe to reorder them
    p = revlexicographic_cols_perm([E; P])
    E = E[:, p]
    P = P[:, p]
    coeffs = map(i -> :(c[$i]), p)
    # Since we are only interested in the derivative we can by hand eliminate all
    # terms where no parameter occurs (these are constant terms in our new setting)
    # Since we have a revlexicographic order of the columns, the all 0 column
    # is the leading columns

    # We first handle the case that P is all 0. Then the derivative is simply
    # the zero vector
    if all(iszero, P)
        zero_tuple = Expr(:tuple, (:(zero($T)) for _=1:size(P,1))...)
        return quote
            SVector($zero_tuple)
        end
    end

    if all(iszero, @view P[:, 1]) # we have at least one constant term
        nconstants = 1
        while nconstants < size(P,2)
            if all(iszero, @view P[:, nconstants + 1])
                nconstants += 1
            else
                break
            end
        end
        E = E[:,nconstants+1:end]
        P = P[:,nconstants+1:end]
        coeffs = coeffs[nconstants+1:end]
    end
    # we can derivate wrt the parameters by changing the roles
    E, P = P, E

    exprs = []
    # dvals is a list of tuples (s, iszero) where s is a symbol or expression
    # representing the partial derivative and iszero a boolean flag
    # indicating whether s is zero.
    _, dvals = partial_derivatives!(exprs, E, P, T, nvars, 1, coeffs, access_input)
    quote
        $(exprs...)
        SVector($(Expr(:tuple, map(first, dvals)...)))
    end
end

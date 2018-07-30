export Polynomial, coefficients, exponents, nvariables, coefficienttype, scale_coefficients!


"""
    Polynomial{T, NVars, SE<:SExponents}

A Polynomial with coefficents in `T` in `NVars` variables and exponents of type `SE`.

    Polynomial(f::MP.AbstractPolynomial, [variables])

Construct a Polynomial from `f`.
"""
struct Polynomial{T, NVars, SE}
    coefficients::Vector{T}
    variables::MVector{NVars, Symbol}

    function Polynomial{T, NVars, SE}(coefficients::Vector{T}, variables::SVector{NVars, Symbol}) where {T, NVars, SE}
        @assert length(coefficients) == div(length(SE), NVars) "Coefficients size does not match exponents size"
        new(coefficients, variables)
    end
end

function Polynomial(coefficients::Vector{T}, nvars, exponents::SExponents, variables) where {T}
    return Polynomial{T, nvars, exponents}(coefficients, variables)
end

function Polynomial(coefficients::Vector{T}, exponents::Matrix{<:Integer}, variables=SVector((Symbol("x", i) for i=1:size(exponents, 1))...)) where {T}
    nvars = size(exponents, 1)
    @assert length(coefficients) == size(exponents, 2) "Coefficients size does not match exponents size"
    E, p = revlexicographic_cols(exponents)
    return Polynomial(coefficients[p], nvars, SExponents(E), variables)
end

# Implementation from Base.sort adapted to also reorder an associated vector
"""
    revlexicographic_cols(A, v)

Sorts the columns of `A` in reverse lexicographic order and returns the permutation vector
to obtain this ordering.
"""
function revlexicographic_cols(A::AbstractMatrix; kws...)
    inds = Compat.axes(A,2)
    cols = map(i -> (@view A[end:-1:1, i]), inds)
    if VERSION <= v"0.6.9"
        p = sortperm(cols; kws..., order=Base.Sort.Lexicographic)
    else
        p = sortperm(cols; kws...)
    end
    A[:,p], p
end

function Polynomial(p::MP.AbstractPolynomialLike{T}, vars = MP.variables(p)) where T
    terms = MP.terms(p)
    nterms = length(terms)
    nvars = length(vars)

    exponents = Matrix{Int}(undef, nvars, nterms)
    coefficients = Vector{T}(undef, nterms)
    for (j, term) in enumerate(terms)
        coefficients[j] = MP.coefficient(term)
        for (i, var) in enumerate(vars)
            exponents[i, j] = MP.degree(term, var)
        end
    end
    Polynomial(coefficients, exponents, SVector((Symbol(var) for var in vars)...))
end

"""
    coefficients(f)

Return the coefficients of `f`.
"""
coefficients(f::Polynomial) = f.coefficients

"""
    exponents(f)

Return the exponents of `f` as an matrix where each column represents
the exponents of a monomial.
"""
function exponents(::Polynomial{T, NVars, E}) where {T, NVars, E}
    exponents(E)
end

sexponents(::Polynomial{T, NVars, E}) where {T, NVars, E} = E

"""
    nvariables(f::Polynomial)

Return the number of variables `f`.
"""
nvariables(::Polynomial{T, NVars}) where {T, NVars} = NVars

"""
    coefficienttype(f::Polynomial)

Return the type of the coefficients of `f`.
"""
coefficienttype(::Polynomial{T, NVars}) where {T, NVars} = T


function Base.:(==)(f::Polynomial{T, NVars, E1}, g::Polynomial{T, NVars, E2}) where {T, NVars, E1, E2}
    E1 == E2 && coefficients(f) == coefficients(g)
end


"""
    scale_coefficients!(f, λ)

Scale the coefficients of `f` by the factor `λ`.
"""
scale_coefficients!(f::Polynomial, λ) = Compat.rmul!(f.coefficients, λ)

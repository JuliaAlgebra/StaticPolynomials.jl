export Polynomial, coefficients, exponents, nvars


"""
    Polynomial(f::MP.AbstractPolynomial, [variables])

Construct a Polynomial from f.
"""
struct Polynomial{T, NVars, E<:SExponents}
    coefficients::Vector{T}

    function Polynomial{T, NVars, SExponents{E}}(coefficients::Vector{T}) where {T, NVars, E}
        @assert length(coefficients) == div(length(E), NVars) "Coefficients size does not match exponents size"
        new(coefficients)
    end
end

function Polynomial(coefficients::Vector{T}, nvars, exponents::E) where {T, E<:SExponents}
    return Polynomial{T, nvars, E}(coefficients)
end

function Polynomial(coefficients::Vector{T}, exponents::Matrix{<:Integer}) where {T}
    nvars = size(exponents, 1)
    @assert length(coefficients) == size(exponents, 2) "Coefficients size does not match exponents size"
    E, p = revlexicographic(exponents)
    return Polynomial(coefficients[p], nvars, SExponents(E))
end

function Polynomial(p::MP.AbstractPolynomialLike{T}, vars = MP.variables(p)) where T
    terms = MP.terms(p)
    nterms = length(terms)
    nvars = length(vars)

    exponents = Matrix{Int}(nvars, nterms)
    coefficients = Vector{T}(nterms)
    for (j, term) in enumerate(terms)
        coefficients[j] = MP.coefficient(term)
        for (i, var) in enumerate(vars)
            exponents[i, j] = MP.degree(term, var)
        end
    end
    Polynomial(coefficients, exponents)
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
function exponents(::Polynomial{T, NVars, E}) where {T, NVars, E<:SExponents}
    exponents(E, NVars)
end

"""
    nvars(f::Polynomial)

Return the number of variables `f`.
"""
nvars(::Polynomial{T, NVars}) where {T, NVars} = NVars


function Base.:(==)(f::Polynomial{T, NVars, E}, g::Polynomial{T, NVars, E}) where {T, NVars, E<:SExponents}
    coefficients(f) == coefficients(g)
end

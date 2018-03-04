export Polynomial, coefficients, exponents



"""
    Polynomial([T, ] f::MP.AbstractPolynomial, [variables])

Construct a Polynomial from f.

    Polynomial(f::FixedPolynomials.Polynomial)
"""
struct Polynomial{T, E<:SExponents}
    coefficients::Vector{T}

    function Polynomial{T, E}(coefficients::Vector{T}) where {T, E<:SExponents}
        @assert length(coefficients) == nterms(E) "Coefficients size does not match exponents size"
        new(coefficients)
    end
end

function Polynomial(coefficients::Vector{T}, exponents::E) where {T, E<:SExponents}
    return Polynomial{T, E}(coefficients)
end

function Polynomial(coefficients::Vector{T}, exponents::Matrix{<:Integer}) where {T}
    @assert length(coefficients) == size(exponents, 2) "Coefficients size does not match exponents size"
    E, p = revlexicographic(exponents)
    return Polynomial(coefficients[p], SExponents(E))
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
function exponents(::Polynomial{T, E}) where {T, E<:SExponents}
    exponents(E)
end

function Base.:(==)(f::Polynomial{T, E}, g::Polynomial{T, E}) where {T, E<:SExponents}
    coefficients(f) == coefficients(g)
end

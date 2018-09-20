export Polynomial, coefficients, exponents, nvariables, variables, parameters, nparameters, coefficienttype, scale_coefficients!


"""
    Polynomial{T, SE<:SExponents}

A Polynomial with coefficents in `T` in `NVars` variables and exponents of type `SE`.

    Polynomial(f::MP.AbstractPolynomial, [variables])

Construct a Polynomial from `f`.
"""
struct Polynomial{T, SE, Params}
    coefficients::Vector{T}
    variables::Vector{Symbol}
    parameters::Union{Nothing, Vector{Symbol}}

    function Polynomial{T, SE, P}(coefficients::Vector{T}, variables, parameters) where {T, SE, P}
        # @assert length(coefficients) == size(SE, 2) "Coefficients size does not match exponents size"
        new(coefficients, variables, parameters)
    end
end

function Polynomial(coeffs::Vector{T}, SE::SExponents, variables, PE::Union{Nothing,SExponents}, parameters) where {T}
    Params = PE isa Nothing ? Nothing : PE
    Polynomial{T, SE, Params}(coeffs, variables, parameters)
end

function Polynomial(p::MP.AbstractPolynomialLike; parameters=nothing, variables=diffvars(MP.variables(p), parameters))
    Polynomial(p, variables, parameters)
end

Polynomial(p::MP.AbstractPolynomialLike, vars) = Polynomial(p, vars, nothing)
@deprecate Polynomial(p, vars) Polynomial(p, variables=vars)

function Polynomial(p::MP.AbstractPolynomialLike, vars, params)
    terms = MP.terms(p)
    nterms = length(terms)
    nvars = length(vars)
    nparams = params === nothing ? 0 : length(params)

    if MP.nvariables(p) > (nvars + nparams)
        error("Number of variables is less than the number of declared variables and parameters.")
    end

    coefficients = MP.coefficient.(MP.terms(p))
    exponents = [MP.degree(term, var) for var in vars, term in terms]
    if params === nothing
        parameters = nothing
        pexponents = nothing
    else
        parameters = Symbol.(params)
        pexponents = [MP.degree(term, param) for param in params, term in terms]
    end

    Polynomial(coefficients, exponents, Symbol.(vars), pexponents, parameters)
end
lengthparams(::Nothing) = 0
lengthparams(params) = length(params)

function Polynomial(coeffs::Vector, E::Matrix{<:Integer}, variables,
                    PE::Union{Nothing, Matrix{<:Integer}}, parameters)
    if PE === nothing
        p = revlexicographic_cols_perm(E)
        SPE = nothing
    else
        p = revlexicographic_cols_perm([PE; E])
        SPE = SExponents(PE[:, p])
    end
    return Polynomial(coeffs[p], SExponents(E[:,p]), variables, SPE, parameters)
end

function Polynomial(coeffs::Vector, exponents::Matrix{<:Integer}, variables=defaultvariables(size(exponents, 1)))
    @assert length(coeffs) == size(exponents, 2) "Number of coefficients doesn't match number of terms."
    Polynomial(coeffs, exponents, variables, nothing, nothing)
end

defaultvariables(n) = SVector((Symbol("x", i) for i=1:n)...)

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
exponents(::Polynomial{T, E}) where {T, E} = exponents(E)

"""
    parameter_exponents(f)::Union{Nothing, Matrix{Int}}

Return the exponents of the parameters of `f` as an matrix where each column represents
the exponents of a monomial. If `f` has no parameters `nothing` is returned.
"""
parameter_exponents(::Polynomial{T, E, P}) where {T, E, P} = exponents(P)
parameter_exponents(::Polynomial{T, E, Nothing}) where {T, E} = nothing

sexponents(::Polynomial{T, E}) where {T, E} = E

"""
    variables(f::Polynomial)::Vector{Symbol}

Returns the variables of `f`.
"""
variables(f::Polynomial) = f.variables

"""
    parameters(f::Polynomial)::Union{Nothing, Vector{Symbol}}

Returns the parameters of `f`.
"""
parameters(f::Polynomial) = f.parameters

"""
    nvariables(f::Polynomial)

Return the number of variables of `f`.
"""
nvariables(::Polynomial{T, E}) where {T, E} = size(E)[1]

"""
    nparameters(f::Polynomial)

Return the number of parameters of `f`.
"""
nparameters(f::Polynomial) = f.parameters === nothing ? 0 : length(f.parameters)

"""
    coefficienttype(f::Polynomial)

Return the type of the coefficients of `f`.
"""
coefficienttype(::Polynomial{T}) where {T} = T


function Base.:(==)(f::Polynomial{T, E1, P1}, g::Polynomial{T, E2, P2}) where {T, E1, E2, P1, P2}
    P1 == P2 && E1 == E2 && coefficients(f) == coefficients(g)
end


"""
    scale_coefficients!(f, λ)

Scale the coefficients of `f` by the factor `λ`.
"""
scale_coefficients!(f::Polynomial, λ) = LinearAlgebra.rmul!(f.coefficients, λ)

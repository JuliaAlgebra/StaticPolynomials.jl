export SExponentsSystem

"""
    SExponentsSystem{N, NTerms}

Store the exponents of the terms of a polynomial system (the support) with `N` polynomials on `NTerms`
terms as an type. This results in an **unique** type for each possible support.
"""
struct SExponentsSystem{N, NTerms}
    exponents::NTuple{NTerms, UInt8}
    nterms::NTuple{N, Int} # terms per polynomial in the system
    nvars::Int
end

function SExponentsSystem(E::Vector{<:Matrix{<:Integer}})
    exponents = Tuple(UInt8(E[i][j]) for i=1:length(E) for j=1:length(E[i]))
    nterms = map(e -> size(e, 2), E)
    nvars = size(E[1], 1)
    for i=2:length(E)
        if size(E[i], 1) != nvars
            error("Exponent matrices do not have the same number of rows")
        end
    end

    return SExponentsSystem(exponents, nterms, nvars)
end

Base.isbits(::Type{<:SExponents}) = true
Base.length(::SExponents{N}) where N = N
function Base.:(==)(f::SExponents{N}, g::SExponents{N}) where {N}
    f.exponents == g.exponents && f.size == g.size
end
Base.hash(f::SExponents, h) = hash(f.exponents, hash(f.size, h))
Base.size(SE::SExponents) = SE.size
Base.size(SE::SExponents, i) = size(SE)[1]

"""
    exponents(::SExponents)

Converts exponents stored in a `SExponents` to a matrix.
"""
function exponents(SE::SExponents)
    nvars, nterms = SE.size
    exps = fill(0, nvars, nterms)
    for k=1:nvars*nterms
        exps[k] = SE.exponents[k]
    end
    exps
end
exponents(::Type{Nothing}) = nothing

exponents(::Type{Nothing}, SE::SExponents) = exponents(SE)
exponents(A::SExponents, B::SExponents) = [exponents(A); exponents(B)]


@static if VERSION ≥ v"0.7-"
    function Base.show(io::IO, SE::SExponents{N}) where {N}
        n = hash(SE.exponents)
        exps_hash = string(n, base=16, pad=sizeof(n) * 2)
        print(io, "SExponents{$N}($(exps_hash))")
    end
else
    function Base.show(io::IO, SE::SExponents{N}) where {N}
        print(io, "SExponents{$N}($(num2hex(hash(SE.exponents))))")
    end
end

export SExponents

"""
    SExponents{N}

Store the exponents of the terms of a polynomial (the support) with `N` terms as an type. This results
in an **unique** type for each possible support.
"""
struct SExponents{N}
    exponents::NTuple{N, UInt8}
    size::Tuple{Int,Int} # nvars, nterms
end

function SExponents(exponents::Matrix{<:Integer})
    E = ntuple(i -> convert(UInt8, exponents[i]), length(exponents))

    return SExponents(E, size(exponents))
end

function SExponents{N}(;exponents::NTuple{N, UInt8}=nothing, size::Tuple{Int, Int}=nothing) where {N}
    SExponents{N}(exponents, size)
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

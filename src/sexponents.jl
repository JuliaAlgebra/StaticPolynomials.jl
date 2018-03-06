export SExponents

struct SExponents{E}
    function SExponents{E}() where { E}
        @assert typeof(E) <: NTuple{N, Int} where N "Exponents type invalid"
        new()
    end
end

function SExponents(exponents::Matrix{<:Integer})
    # NVars = size(exponents, 1)
    E = ntuple(i -> convert(Int, exponents[i]), length(exponents))

    return SExponents{E}()
end

"""
    exponents(::SExponents)

Converts exponents stored in a `SExponents` to a matrix.
"""
function exponents(::Type{SExponents{E}}, nvars) where {E}
    nterms = div(length(E), nvars)
    exps = fill(0, nvars, nterms)
    for k=1:nvars*nterms
        exps[k] = E[k]
    end
    exps
end
exponents(::S, nvars) where {S<:SExponents} = exponents(S, nvars)

function Base.show(io::IO, ::Type{SExponents{E}}) where {E}
    exps_hash = num2hex(hash(E))
    print(io, "SExponents{$(exps_hash)}")
end
Base.show(io::IO, S::SExponents) = print(io, typeof(S), "()")

export SExponents

struct SExponents{NVars, NTerms, E}
    function SExponents{NVars, NTerms, E}() where {NVars, NTerms, E}
        @assert NVars isa Int
        @assert NTerms isa Int
        @assert NVars * NTerms == length(E) "($NVars, $NTerms) does not match size of Exponents"
        @assert typeof(E) <: NTuple{NVars * NTerms, Int} "Exponents type invalid"
        new()
    end
end

function SExponents(exponents::Matrix{<:Integer})
    NVars, NTerms = size(exponents)
    E = ntuple(i -> convert(Int, exponents[i]), length(exponents))

    return SExponents{NVars, NTerms, E}()
end

nvars(::Type{SExponents{NVars, NTerms, E}}) where {NVars, NTerms, E} = NVars
nvars(::S) where {S<:SExponents} = nvars(S)
nterms(::Type{SExponents{NVars, NTerms, E}}) where {NVars, NTerms, E} = NTerms
nterms(::S) where {S<:SExponents} = nterms(S)
"""
    exponents(::SExponents)

Converts exponents stored in a `SExponents` to a matrix.
"""
function exponents(::Type{SExponents{NVars, NTerms, E}}) where {NVars, NTerms, E}
    exps = fill(0, NVars, NTerms)
    for k=1:NVars*NTerms
        exps[k] = E[k]
    end
    exps
end
exponents(::S) where {S<:SExponents} = exponents(S)

function Base.show(io::IO, ::Type{SExponents{NVars, NTerms, E}}) where {NVars, NTerms, E}
    exps_hash = num2hex(hash(E))
    print(io, "SExponents{$NVars, $NTerms, $(exps_hash)}")
end
Base.show(io::IO, S::SExponents) = print(io, typeof(S), "()")

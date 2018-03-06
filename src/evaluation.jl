export evaluate

function evaluate_impl(f::Type{Polynomial{T, NVars, E}}) where {T, NVars, E<:SExponents}
    generate_evaluate(exponents(E, NVars), T)
end

@generated function evaluate(f::Polynomial, x::AbstractVector)
    quote
        c = coefficients(f)
        $(evaluate_impl(f))
    end
end

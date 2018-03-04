function evaluate_impl(f::Type{Polynomial{T, E}}) where {T, E<:SExponents}
    generate_evaluate(exponents(E), T)
end

@generated function evaluate(f::Polynomial, x::AbstractVector)
    quote
        c = coefficients(f)
        $(evaluate_impl(f))
    end
end

export @evalpoly_derivative, @goertzel_deriv, @horner_deriv


"""
    evalpoly(::Type{T}, degrees, coefficients, var::Union{Symbol, Expr})

Evaluate the polynomial defined by the degrees and coefficients.
"""
function evalpoly(::Type{T}, degrees::AbstractVector, coefficients::AbstractVector, var) where T
    normalized_coeffs = normalized_coefficients(T, degrees, coefficients)

    if length(normalized_coeffs) == 1
        return normalized_coeffs[1]
    elseif length(normalized_coeffs) == 2
        a, b = normalized_coeffs
        :(muladd($b, $var, $a))
    else
        :(@evalpoly($var, $(normalized_coeffs...)))
    end

end


"""
    evalpoly_derivative!(exprs, ::Type{T}, degrees, coefficients, var::Union{Symbol, Expr})

Evaluate the polynomial and its derivative defined by the degrees and coefficients.
"""
function evalpoly_derivative!(exprs, ::Type{T}, degrees::AbstractVector, coefficients::AbstractVector, var) where T
    normalized_coeffs = normalized_coefficients(T, degrees, coefficients)

    if length(normalized_coeffs) == 1
        if isa(normalized_coeffs[1], Symbol)
            val = normalized_coeffs[1]
        else
            @gensym val
            push!(exprs, :($val = $(normalized_coeffs[1])))
        end
        # return zero directly
        dval = :(zero($T))
    elseif length(normalized_coeffs) == 2
        @gensym val
        a, b = normalized_coeffs
        push!(exprs, :($val = muladd($b, $var, $a)))
        if isa(b, Symbol)
            dval = b
        else
            @gensym dval
            push!(exprs, :($dval = $b))
        end
    else
        @gensym dval val
        push!(exprs, :(($val, $dval) = @evalpoly_derivative($var, $(normalized_coeffs...))))
    end

    return val, dval
end


"""
    @evalpoly_derivative(z, c...)

Evaluate the polynomial ``\\sum_k c[k] z^{k-1}`` for the coefficients `c[1]`, `c[2]`, ... and its derivative;
that is, the coefficients are given in ascending order by power of `z`.  This macro expands
to efficient inline code that uses either Horner's method or, for complex `z`, a more
efficient Goertzel-like algorithm.

```jldoctest
julia> @evalpoly(3, 1, 0, 1)
(10, 6)

julia> @evalpoly(2, 1, 0, 1)
(5, 4)

julia> @evalpoly(2, 1, 1, 1)
(7, 5)
```
"""
macro evalpoly_derivative(z, p...)
    R = Expr(:macrocall, Symbol("@horner_deriv"), (), :tt, map(esc, p)...)
    C = Expr(:macrocall, Symbol("@goertzel_deriv"), (), :tt, map(esc, p)...)
    :(let tt = $(esc(z))
          isa(tt, Complex) ? $C : $R
      end)
end

macro horner_deriv(x, p...)
    escaped_x = :($(esc(x)))
    escaped_p = map(esc, p)
    horner_deriv_impl(escaped_x, escaped_p)
end

function horner_deriv_impl(x, p)
    if length(p) == 1
        return :($(p[1]), zero($(p[1])))
    end

    exprs = Expr[]
    push!(exprs, :(val = $(p[end])))
    push!(exprs, :(dval = val))
    for k = length(p)-1:-1:1
        if k < length(p) - 1
            push!(exprs, :(dval = muladd(dval, $x, val)))
        end
        push!(exprs, :(val = muladd(val, $x, $(p[k]))))
    end

    Expr(:block,
        exprs...,
        :(val, dval))
end

macro goertzel_deriv(z, p...)
    escaped_z = :($(esc(z)))
    escaped_p = map(esc, p)
    goertzel_deriv_impl(escaped_z, escaped_p)
end

function goertzel_deriv_impl(z, p)
    if length(p) == 1
        return :($(p[end]), zero($(p[end])))
    end

    if length(p) == 2
        return :(
            muladd($(p[end]), $z, $(p[end-1])),
            $(p[end])
        )
    end

    exprs = Expr[]
    goertzel_setup!(exprs, z)
    goertzel_deriv_main!(exprs, z, p)

    Expr(:block, exprs...)
end


function goertzel_setup!(exprs, z)
    push!(exprs,
        :(x = real($z)),
        :(y = imag($z)),
        :(r = x + x),
        :(s = -muladd(x, x, y*y)))
end

function goertzel_deriv_main!(exprs, z, p)
    @assert length(p) > 2

    a = :($(p[end]))
    b = :($(p[end-1]))
    local c, d
    # d = b
    for i = length(p)-2:-1:1
        ei = Symbol("e", i)
        push!(exprs, :($ei = $a)) #e_i
        a = :(muladd(r, $ei, $b))
        b = :(muladd(s, $ei, $(p[i])))

        if i == length(p) - 2
            c = ei
        elseif i == length(p) - 3
            d = ei
        else
            fi = Symbol("f", i)
            push!(exprs, :($fi = $c)) #e_i
            c = :(muladd(r, $fi, $d))
            d = :(muladd(s, $fi, $ei))
        end
    end
    r1 = :r1 # r1
    push!(exprs, :($r1 = $a))
    r2 = b
    push!(exprs, :(val = muladd($r1, $z, $r2)))

    # we handle the cases that length(p) < 3 before this routines is called
    if length(p) == 3
        lm = :($(p[end]))
        push!(exprs, :(t = y + y))
        dval = quote
            if isa(r1, Complex)
                complex(real(r1) - t * imag($lm), imag(r1) + t * real($lm))
            else
                complex(r1 - t * imag($lm), t * real($lm))
            end
        end
        push!(exprs, :((val, $dval)))
    else
        dr1 = :dr1
        push!(exprs, :($dr1 = $c))
        dr0 = d
        push!(exprs, :(dr0 = muladd($dr1, $z, $dr0)))

        push!(exprs, :(t = y + y))
        dval = quote
            if isa(r1, Complex)
                complex(real(r1) - t * imag(dr0), imag(r1) + t * real(dr0))
            else
                complex(r1 - t * imag(dr0), t * real(dr0))
            end
        end
        push!(exprs, :((val, $dval)))
    end
end

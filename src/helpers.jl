function static_pow(expr, k::Integer)
    if k == 2
        :($expr * $expr)
    elseif k == 3
        :(($expr * $expr * $expr))
    elseif k == 4
        symb = gensym(:p)
        quote
            $symb = $expr * $expr
            $symb * $symb
        end
    elseif k == 1
        :($expr)
    elseif k == 0
        :(one($expr))
    else
        :(pow($expr, $k))
    end
end

pow(x::AbstractFloat, k::Integer) = Base.FastMath.pow_fast(x, k)
# simplified from Base.power_by_squaring
function pow(x::Number, p::Integer)
    # if p == 1
    #     return copy(x)
    # elseif p == 0
    #     return one(x)
    # elseif p == 2
    #     return x*x
    # end
    t = trailing_zeros(p) + 1
    p >>= t
    while (t -= 1) > 0
        x *= x
    end
    y = x
    while p > 0
        t = trailing_zeros(p) + 1
        p >>= t
        while (t -= 1) >= 0
            x *= x
        end
        y *= x
    end
    return y
end

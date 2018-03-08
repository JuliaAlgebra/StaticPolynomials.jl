"""
    degrees_submatrices(exponents_matrix)

Returns the submatrices with the corresponding degree. This takes the degrees
from the bottom and assume a reverse lexicographic order of the columns.

## Example
```julia
julia> degrees_submatrices([1 2 2; 1 3 2; 1 1 2])
([1, 2], [[1 2; 1 3], [1 ; 1]])
"""
function degrees_submatrices(E)
    submatrices = Vector{typeof(@view E[1:end-1, 1:1])}()# Vector{Matrix{Int}}()
    degrees = Int[]
    j = 1
    last_d_change = 1
    d = E[end, 1]
    n = size(E, 2)
    while j < n
        if E[end,j + 1] != d
            push!(submatrices, @view E[1:end-1, last_d_change:j])
            push!(degrees, d)
            d = E[end,j + 1]
            last_d_change = j+1
        end
        j += 1
    end
    push!(submatrices, @view E[1:end-1, last_d_change:end])
    push!(degrees, E[end, end])
    degrees, submatrices
end


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

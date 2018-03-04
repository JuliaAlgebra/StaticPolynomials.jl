# Implementation from Base.sort adapted to also reorder an associated vector
"""
    revlexicographic_cols(A, v)

Sorts the columns of `A` in reverse lexicographic order and returns the permutation vector
to obtain this ordering.
"""
function revlexicographic(A::AbstractMatrix; kws...)
    inds = indices(A,2)
    T = Base.Sort.slicetypeof(A, :, inds)
    cols = map(i -> (@view A[end:-1:1, i]), inds)
    p = sortperm(cols; kws..., order=Base.Sort.Lexicographic)
    A[:,p], p
end

"""
    batch_arithmetic_ops(op, operands)

Adds additional parenthes due to the following julia bug:
https://github.com/JuliaLang/julia/issues/14821
"""
function batch_arithmetic_ops(op::Symbol, ops)
    batch_size = 3
    l = 1
    if length(ops) == 1
        return :($(ops[1]))
    elseif length(ops) < batch_size + 2
        return Expr(:call, op, ops...)
    end
    batches = []
    while l ≤ length(ops)
        batch_end = min(length(ops), l + batch_size)
        if l == batch_end
            push!(batches, :($(ops[l])))
        else
            push!(batches, Expr(:call, op, ops[l:batch_end]...))
        end
        l = batch_end + 1
    end
    if length(batches) > 1
        return batch_arithmetic_ops(op, batches)
    else
        return batches[1]
    end
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



x_(i::Int) = :(x[$i])
x_(ik::NTuple{2, Int}) = ik[2] == 1 ? x_(ik[1]) : Symbol("x", ik[1], "_", ik[2])
u_(i::Int) = Symbol("u", i)
u_(i1::Int, i2::Int) = Symbol("u", i1, "_", i2)
u_(ik::NTuple{2, Int}) = ik[2] == 1 ? u_(ik[1]) : Symbol("u", ik[1], "_", ik[2])
c_(i::Int) = Symbol("c", i)
c_(i::Int, d::Int) = Symbol("c_", i, "_", d)

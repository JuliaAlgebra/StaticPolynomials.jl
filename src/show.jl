function Base.show(io::IO, p::Polynomial{T}) where {T}
    first = true
    cfs = coefficients(p)

    exps = exponents(p)
    params = parameter_exponents(p)
    nvars, nterms = size(exps)
    nparams = params === nothing ? 0 : size(params, 1)

    for j=1:nterms
        c = cfs[j]
        if (!first && show_plus(c))
            print(io, " + ")
        end

        if (c != one(T) && c != -one(T)) ||
            all(i -> exps[i,j] == 0, 1:nvars) && all(i -> params[i,j] == 0, 1:nparams)
            show_coeff(io, c)
        elseif c == -one(T)
            first ? print(io, "-") : print(io, " - ")
        end

        first = false

        for i=1:nvars
            power = exps[i, j]
            var = p.variables[i]
            if power == 1
                print(io, "$(pretty_var(var))")
            elseif power > 1
                print(io, "$(pretty_var(var))$(pretty_power(power))")
            end
        end
        for i=1:nparams
            power = params[i, j]
            var = p.parameters[i]
            if power == 1
                print(io, "$(pretty_var(var))")
            elseif power > 1
                print(io, "$(pretty_var(var))$(pretty_power(power))")
            end
        end
    end

    if first
        print(io, zero(T))
    end
end

function is_zero_exponent(E, nvars, nterms, j)
    all(i -> ind2sub((nvars, nterms), i, j), i=1:nvars)
end

function unicode_subscript(i)
    if i == 0
        "\u2080"
    elseif i == 1
        "\u2081"
    elseif i == 2
        "\u2082"
    elseif i == 3
        "\u2083"
    elseif i == 4
        "\u2084"
    elseif i == 5
        "\u2085"
    elseif i == 6
        "\u2086"
    elseif i == 7
        "\u2087"
    elseif i == 8
        "\u2088"
    elseif i == 9
        "\u2089"
    end
end


function unicode_superscript(i)
    if i == 0
        "\u2070"
    elseif i == 1
        "\u00B9"
    elseif i == 2
        "\u00B2"
    elseif i == 3
        "\u00B3"
    elseif i == 4
        "\u2074"
    elseif i == 5
        "\u2075"
    elseif i == 6
        "\u2076"
    elseif i == 7
        "\u2077"
    elseif i == 8
        "\u2078"
    elseif i == 9
        "\u2079"
    end
end

pretty_power(pow::Int) = join(map(unicode_superscript, reverse(digits(pow))))

function pretty_var(var::String)
    m = match(r"([a-zA-Z]+)(?:_*)(?:\[*)(\d+)(?:\]*)", var)
    if m === nothing
        var
    else
        base = string(m.captures[1])
        index = parse(Int, m.captures[2])
        base * join(map(unicode_subscript, reverse(digits(index))))
    end
end
pretty_var(var) = pretty_var(string(var))

# helpers
show_plus(x::Real) = x >= 0
show_plus(x::Complex) = x != -1

show_coeff(io::IO, x::Real) = print(io, x)
function show_coeff(io::IO, x::Complex)
    if imag(x) == 0.0
        print(io, real(x))
    else
        print(io, "($(x))")
    end
end

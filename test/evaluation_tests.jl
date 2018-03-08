using TestSystems
using StaticPolynomials
using Base.Test
const SP = StaticPolynomials
using StaticArrays
import MultivariatePolynomials
const MP = MultivariatePolynomials
import DynamicPolynomials: @polyvar

function mp_evaluate(equations, x)
    variables = sort!(union(Iterators.flatten(MP.variables.(equations))), rev=true)
    map(equations) do f
        f(variables => x)
    end
end

function mp_jacobian(equations, x)
    variables = sort!(union(Iterators.flatten(MP.variables.(equations))), rev=true)
    map(Iterators.product(equations, variables)) do arg
        (f, var) = arg
        MP.differentiate(f, var)(variables => x)
    end
end

function sp_evaluate(equations, x)
    F = SP.system(equations)
    SP.evaluate(F, x)
end
function sp_jacobian(equations, x)
    F = SP.system(equations)
    SP.jacobian(F, x)
end

const all_systems = [
    :katsura5, :katsura6, :katsura7, :katsura8, :katsura9, :katsura10,
    :chandra4, :chandra5,
    :cyclic5, :cyclic6, :cyclic7, :cyclic8,
    :fourbar, :rps10]


@testset "testsystems" begin
    for T = [Float64, Complex128]
        for name in all_systems
            system = eval(Expr(:call, name))
            nvars = TestSystems.nvariables(system)
            x = SVector{nvars}(rand(T, nvars))
            eqs = TestSystems.equations(system)

            @test norm(sp_evaluate(eqs, x) - mp_evaluate(eqs, x)) < 1e-14

            @test norm(sp_jacobian(eqs, x) - mp_jacobian(eqs, x)) < 1e-14
        end
    end
end


sys = TestSystems.equations(katsura5())
F = SP.system(sys)
x = @SVector rand(6)

SP.Systems.jacobian_impl(typeof(F))

f1 = sys[1]
g1 = SP.Polynomial(f1)

U = rand(6, 6)
@allocated SP.jacobian!(U, F, x)
@allocated SP.jacobian(F, x)

v1 = @SVector rand(6)
v2 = @SVector rand(6)
v = SVector(v1, v2)
@allocated SP.Systems.assemble_matrix(v)
@code_warntype SP.Systems.assemble_matrix_impl(typeof(v))

function assemble_test(vectors)
    v1, v2 = vectors
    @inbounds out = SMatrix{2, 6, Float64, 12}(v1[1], v2[1], v1[2], v2[2], v1[3], v2[3], v1[4], v2[4], v1[5], v2[5], v1[6], v2[6])
    out
end
@allocated assemble_test(v)


@code_warntype SP.Systems.jacobian(F, x)

@code_warntype SP.Systems.assemble_matrix(SVector(x, x))

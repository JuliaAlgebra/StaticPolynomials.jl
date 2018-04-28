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

using TestSystems

@testset "testsystems" begin
    for T = [Float64, Complex{Float64}]
        for name in all_systems
            system = eval(Expr(:call, name))
            nvars = TestSystems.nvariables(system)
            x = SVector{nvars}(rand(T, nvars))
            eqs = TestSystems.equations(system)

            @test norm(sp_evaluate(eqs, x) - mp_evaluate(eqs, x)) < 1e-14
            @test norm(sp_evaluate(eqs, Vector(x)) - mp_evaluate(eqs, x)) < 1e-14

            @test norm(sp_jacobian(eqs, x) - mp_jacobian(eqs, x)) < 1e-14
            @test norm(sp_jacobian(eqs, Vector(x)) - mp_jacobian(eqs, x)) < 1e-14

            F = SP.system(eqs)
            val, jac = SP.evaluate_and_jacobian(F, x)
            @test norm(val - mp_evaluate(eqs, x)) < 1e-14
            @test norm(F(x) - mp_evaluate(eqs, x)) < 1e-14
            @test norm(jac - mp_jacobian(eqs, x)) < 1e-14

            @test !isempty(string(F.f1))

            val, jac = SP.evaluate_and_jacobian(F, Vector(x))
            @test norm(val - mp_evaluate(eqs, x)) < 1e-14
            @test norm(F(x) - mp_evaluate(eqs, x)) < 1e-14
            @test norm(jac - mp_jacobian(eqs, x)) < 1e-14
        end
    end
end

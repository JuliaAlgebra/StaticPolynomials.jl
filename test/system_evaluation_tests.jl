function mp_evaluate(equations, x)
    variables = MP.variables(equations)
    map(equations) do f
        f(variables => x)
    end
end

function mp_jacobian(equations, x)
    variables = MP.variables(equations)
    map(Iterators.product(equations, variables)) do arg
        (f, var) = arg
        MP.differentiate(f, var)(variables => x)
    end
end

function sp_evaluate(equations, x)
    F = SP.PolynomialSystem(equations)
    SP.evaluate(F, x)
end
function sp_jacobian(equations, x)
    F = SP.PolynomialSystem(equations)
    SP.jacobian(F, x)
end

function katsura(n)
  @polyvar x[0:n] # This creates variables x0, x1, ...

  return [
    (sum(x[abs(l)+1]*x[abs(m-l)+1] for l=-n:n if abs(m-l)<=n) -
    x[m+1] for m=0:n-1)...,
    x[1] + 2sum(x[i+1] for i=1:n) - 1
  ]
end

@testset "Katsura Evaluation tests" begin
    for T = [Float64, Complex{Float64}]
        for n=4:12
            nvars = n+1
            eqs = katsura(n)
            x = SVector{nvars}(rand(T, nvars))

            @test norm(sp_evaluate(eqs, x) - mp_evaluate(eqs, x)) < 1e-14
            @test norm(sp_evaluate(eqs, Vector(x)) - mp_evaluate(eqs, x)) < 1e-14

            @test norm(sp_jacobian(eqs, x) - mp_jacobian(eqs, x)) < 1e-14
            @test norm(sp_jacobian(eqs, Vector(x)) - mp_jacobian(eqs, x)) < 1e-14

            F = SP.PolynomialSystem(eqs)
            val, jac = SP.evaluate_and_jacobian(F, x)
            @test norm(val - mp_evaluate(eqs, x)) < 1e-14
            @test norm(F(x) - mp_evaluate(eqs, x)) < 1e-14
            @test norm(jac - mp_jacobian(eqs, x)) < 1e-14

            val, jac = SP.evaluate_and_jacobian(F, Vector(x))
            @test norm(val - mp_evaluate(eqs, x)) < 1e-14
            @test norm(F(x) - mp_evaluate(eqs, x)) < 1e-14
            @test norm(jac - mp_jacobian(eqs, x)) < 1e-14
        end
    end
end

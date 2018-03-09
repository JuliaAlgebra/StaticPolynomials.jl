using BenchmarkTools
import StaticPolynomials
const SP = StaticPolynomials
using StaticArrays
using TestSystems

function bevaluate(T, testsystem)
    F = SP.system(TestSystems.equations(testsystem))
    n = SP.nvariables(F)
    x = SVector{n, T}(rand(T, n))
    @benchmarkable SP.evaluate($F, $x) evals=10
end

function bjacobian(T, testsystem)
    F = SP.system(TestSystems.equations(testsystem))
    n = SP.nvariables(F)
    x = SVector{n, T}(rand(T, n))
    @benchmarkable SP.jacobian($F, $x) evals=10
end


const SUITE = BenchmarkGroup()
SUITE["evaluate"] = BenchmarkGroup(["evaluate"])
SUITE["jacobian"] = BenchmarkGroup(["jacobian"])

const all_systems = [
    :katsura5, :katsura6, :katsura7, :katsura8, :katsura9, :katsura10,
    :chandra4, :chandra5,
    :cyclic5, :cyclic6, :cyclic7, :cyclic8,
    :fourbar, :rps10]

for T in [Float64, Complex128]
    T_str = string(T)
    SUITE["evaluate"][T_str] = BenchmarkGroup()
    SUITE["jacobian"][T_str] = BenchmarkGroup()
    for system in all_systems
        @eval begin
            sys = $(Expr(:call, system))
            SUITE["evaluate"][$(T_str)][$(string(system))] = bevaluate($T, sys)
            SUITE["jacobian"][$(T_str)][$(string(system))] = bjacobian($T, sys)
        end
    end
end

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

const SUITE = BenchmarkGroup()
SUITE["evaluation"] = BenchmarkGroup(["evaluation"])

const all_systems = [
    :katsura5, :katsura6, :katsura7, :katsura8, :katsura9, :katsura10,
    :chandra4, :chandra5,
    :cyclic5, :cyclic6, :cyclic7, :cyclic8,
    :fourbar, :rps10]

for T in [Float64, Complex128]
    T_str = string(T)
    SUITE["evaluation"][T_str] = BenchmarkGroup()
    for system in all_systems
        @eval begin
            SUITE["evaluation"][$(T_str)][$(string(system))] = bevaluate($T, $(Expr(:call, system)))
        end
    end
end

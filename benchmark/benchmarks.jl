using BenchmarkTools
import StaticPolynomials
const SP = StaticPolynomials
using StaticArrays
using TestSystems

function bevaluate(T, testsystem)
    F = SP.system(TestSystems.equations(katsura5()))
    n = SP.nvariables(F)
    x = SVector{n, T}(rand(T, n))
    @benchmarkable SP.evaluate($F, $x)
end

const SUITE = BenchmarkGroup()

SUITE["evaluation"] = BenchmarkGroup(["evaluation"])
SUITE["evaluation"]["Float64"] = BenchmarkGroup()
SUITE["evaluation"]["Float64"]["katsura5"] = bevaluate(Float64, katsura5())
SUITE["evaluation"]["Float64"]["katsura6"] = bevaluate(Float64, katsura6())
SUITE["evaluation"]["Float64"]["katsura10"] = bevaluate(Float64, katsura10())

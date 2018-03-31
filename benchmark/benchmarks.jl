## Comparison script
##
# using GitHub, JSON, PkgBenchmark
#
# baseline_cfg = BenchmarkConfig(id="master", juliacmd = `julia -O3`);
# cfg = BenchmarkConfig(juliacmd = `julia -O3`);
# results = judge("StaticPolynomials", cfg, baseline_cfg);
#
# gist_json = JSON.parse(
#     """
#     {
#     "description": "A benchmark for StaticPolynomials",
#     "public": false,
#     "files": {
#         "benchmark.md": {
#         "content": "$(escape_string(sprint(export_markdown, results)))"
#         }
#     }
#     }
#     """
# );
#
# posted_gist = create_gist(params = gist_json);
#
# url = get(posted_gist.html_url)
#
# println("Result available at:")
# println(url)
#
# if is_unix()
#     run(`open $url`)
# end

## Benchmark script
##
# using GitHub, JSON, PkgBenchmark
#
# cfg = BenchmarkConfig(juliacmd = `julia -O3`);
# results = benchmarkpkg("StaticPolynomials", cfg);
#
# gist_json = JSON.parse(
#     """
#     {
#     "description": "A benchmark for StaticPolynomials",
#     "public": false,
#     "files": {
#         "benchmark.md": {
#         "content": "$(escape_string(sprint(export_markdown, results)))"
#         }
#     }
#     }
#     """
# );
#
# posted_gist = create_gist(params = gist_json);
#
# url = get(posted_gist.html_url)
#
# println("Result available at:")
# println(url)
#
# if is_unix()
#     run(`open $url`)
# end


using BenchmarkTools
import StaticPolynomials
const SP = StaticPolynomials
using StaticArrays
using TestSystems

function bevaluate(T, testsystem)
    F = SP.system(TestSystems.equations(testsystem))
    n = SP.nvariables(F)
    x = SVector{n, T}(rand(T, n))
    @benchmarkable SP.evaluate($F, $x)
end

function bjacobian(T, testsystem)
    F = SP.system(TestSystems.equations(testsystem))
    n = SP.nvariables(F)
    x = SVector{n, T}(rand(T, n))
    @benchmarkable SP.jacobian($F, $x)
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

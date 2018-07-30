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

# # Benchmark script
# #
# using GitHub, JSON
# using PkgBenchmark
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
using PolynomialTestSystems

function bevaluate(T, testsystem)
    F = SP.system(PolynomialTestSystems.equations(testsystem))
    n = SP.nvariables(F)
    x = SVector{n, T}(rand(T, n))
    @benchmarkable SP.evaluate($F, $x)
end

function static_bjacobian(T, testsystem)
    F = SP.system(PolynomialTestSystems.equations(testsystem))
    n = SP.nvariables(F)
    x = SVector{n, T}(rand(T, n))
    @benchmarkable SP.jacobian($F, $x)
end

function bjacobian(T, testsystem)
    F = SP.system(PolynomialTestSystems.equations(testsystem))
    n = SP.nvariables(F)
    x = rand(T, n)
    U = zeros(T, SP.npolynomials(F), n)
    @benchmarkable SP.jacobian!($U, $F, $x)
end

const SUITE = BenchmarkGroup()
SUITE["evaluate"] = BenchmarkGroup(["evaluate"])
SUITE["jacobian"] = BenchmarkGroup(["jacobian"])
SUITE["static jacobian"] = BenchmarkGroup(["static jacobian"])

systems = [
    (katsura(5), "katsura5"), (katsura(6), "katsura(6)"),
    (katsura(7), "katsura7"), (katsura(8), "katsura8"),
    (katsura(9), "katsura9"), (katsura(10), "kastura10"),
    (chandra(4), "chandra4"), (chandra(8), "chandra8"),
    (cyclic(6), "cyclic6"), (cyclic(7), "cyclic7"), (cyclic(9), "cyclic9"),
    (fourbar(), "fourbar"), (rps10(), "rps10")]

for T in [Float64, Complex{Float64}]
    SUITE["evaluate"][string(T)] = BenchmarkGroup()
    SUITE["jacobian"][string(T)] = BenchmarkGroup()
    SUITE["static jacobian"][string(T)] = BenchmarkGroup()
    for (system, name) in systems
        SUITE["evaluate"][string(T)][name] = bevaluate(T, system)
        SUITE["jacobian"][string(T)][name] = bjacobian(T, system)
        SUITE["static jacobian"][string(T)][name] = static_bjacobian(T, system)
    end
end

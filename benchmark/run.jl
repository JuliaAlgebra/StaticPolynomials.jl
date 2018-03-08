using GitHub, JSON, PkgBenchmark

cfg = BenchmarkConfig(juliacmd = `julia -O3`);
results = benchmarkpkg("StaticPolynomials", cfg);

gist_json = JSON.parse(
    """
    {
    "description": "A benchmark for StaticPolynomials",
    "public": false,
    "files": {
        "benchmark.md": {
        "content": "$(escape_string(sprint(export_markdown, results)))"
        }
    }
    }
    """
);

posted_gist = create_gist(params = gist_json);

url = get(posted_gist.html_url)

println("Result available at:")
println(url)

if is_unix()
    run(`open $url`)
end

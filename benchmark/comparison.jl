using GitHub, JSON, PkgBenchmark

baseline_cfg = BenchmarkConfig(id="master", juliacmd = `julia -O3`);
cfg = BenchmarkConfig(juliacmd = `julia -O3`);
results = judge("StaticPolynomials", cfg, baseline_cfg);

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

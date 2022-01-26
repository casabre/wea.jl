using wea
using Documenter

DocMeta.setdocmeta!(wea, :DocTestSetup, :(using wea); recursive=true)

makedocs(;
    modules=[wea],
    authors="Carsten Sauerbrey",
    repo="https://github.com/casabre/wea.jl/blob/{commit}{path}#{line}",
    sitename="wea.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://casabre.github.io/wea.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/casabre/wea.jl",
)

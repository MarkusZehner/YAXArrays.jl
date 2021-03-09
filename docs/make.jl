using YAXArrays, Documenter

exampledir = joinpath(@__DIR__,"src","examples")
allex = map(readdir(exampledir)) do fname
  n = splitext(fname)[1]
  n => joinpath("examples",fname)
end

makedocs(
    modules = [YAXArrays],
    clean   = true,
    format   = Documenter.HTML(),
    sitename = "YAXArrays.jl",
    authors = "Fabian Gans",
    pages    = [ # Compat: `Any` for 0.4 compat
        "Home" => "index.md",
        "Tutorial" => "man/tutorial.md",
        "Examples" => allex,
        "Manual" => Any[
            "man/datasets.md",
            "man/yaxarrays.md",
            "man/applying functions.md",
            "man/iterators.md",
        ],
        ]
)

deploydocs(
    #deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo   = "github.com/esa-esdl/ESDL.jl.git",
)

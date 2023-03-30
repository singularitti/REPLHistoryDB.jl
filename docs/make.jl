using REPLHistoryDB
using Documenter

DocMeta.setdocmeta!(REPLHistoryDB, :DocTestSetup, :(using REPLHistoryDB); recursive=true)

makedocs(;
    modules=[REPLHistoryDB],
    authors="singularitti <singularitti@outlook.com> and contributors",
    repo="https://github.com/singularitti/REPLHistoryDB.jl/blob/{commit}{path}#{line}",
    sitename="REPLHistoryDB.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://singularitti.github.io/REPLHistoryDB.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/singularitti/REPLHistoryDB.jl",
    devbranch="main",
)

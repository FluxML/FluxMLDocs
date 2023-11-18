using MultiDocumenter

clonedir = ("--temp" in ARGS) ? mktempdir() : joinpath(@__DIR__, "clones")

docs = [
    MultiDocumenter.MultiDocRef(
        upstream = joinpath(clonedir, "Flux"),
        path = "flux",
        name = "Flux",
        giturl = "https://github.com/FluxML/Flux.jl.git",
    ),
    MultiDocumenter.MegaDropdownNav(
        "Building Blocks",
        [
            MultiDocumenter.Column(
                "Neural Network primitives",
                [
                    MultiDocumenter.MultiDocRef(
                        upstream = joinpath(clonedir, "NNlib"),
                        path = "nnlib",
                        name = "NNlib",
                        giturl = "https://github.com/FluxML/NNlib.jl.git",
                    ),
                    MultiDocumenter.MultiDocRef(
                        upstream = joinpath(clonedir, "Functors"),
                        path = "functors",
                        name = "Functors",
                        giturl = "https://github.com/FluxML/Functors.jl.git",
                    ),
                ],
            ),
            MultiDocumenter.Column(
                "Automatic differentiation libraries",
                [
                    MultiDocumenter.MultiDocRef(
                        upstream = joinpath(clonedir, "Zygote"),
                        path = "zygote",
                        name = "Zygote",
                        giturl = "https://github.com/FluxML/Zygote.jl.git",
                    ),
                ],
            ),
            MultiDocumenter.Column(
                "Neural Network primitives",
                [
                    MultiDocumenter.MultiDocRef(
                        upstream = joinpath(clonedir, "NNlib"),
                        path = "nnlib",
                        name = "NNlib",
                        giturl = "https://github.com/FluxML/NNlib.jl.git",
                    ),
                ],
            ),
        ]
    ),
    MultiDocumenter.MegaDropdownNav(
        "Training",
        [
            MultiDocumenter.Column(
                "Data Wrangling",
                [
                    MultiDocumenter.MultiDocRef(
                        upstream = joinpath(clonedir, "MLUtils"),
                        path = "mlutils",
                        name = "MLUtils",
                        giturl = "https://github.com/JuliaML/MLUtils.jl.git",
                    ),
                    MultiDocumenter.MultiDocRef(
                        upstream = joinpath(clonedir, "OneHotArrays"),
                        path = "onehotarrays",
                        name = "OneHotArrays",
                        giturl = "https://github.com/FluxML/OneHotArrays.jl.git",
                    ),
                ]
            ),
            MultiDocumenter.Column(
                "Data Augmentation",
                [
                    MultiDocumenter.MultiDocRef(
                        upstream = joinpath(clonedir, "DataAugmentation"),
                        path = "dataaugmentation",
                        name = "DataAugmentation",
                        giturl = "https://github.com/FluxML/DataAugmentation.jl.git",
                    ),
                ],
            ),
            MultiDocumenter.Column(
                "Datasets",
                [
                    MultiDocumenter.MultiDocRef(
                        upstream = joinpath(clonedir, "MLDatasets"),
                        path = "mldatasets",
                        name = "MLDatasets",
                        giturl = "https://github.com/JuliaML/MLDatasets.jl.git",
                    ),
                ],
            ),
            MultiDocumenter.Column(
                "Schedulers",
                [
                    MultiDocumenter.MultiDocRef(
                        upstream = joinpath(clonedir, "ParameterSchedulers"),
                        path = "paramschedulers",
                        name = "ParameterSchedulers",
                        giturl = "https://github.com/FluxML/ParameterSchedulers.jl.git",
                    ),
                ],
            ),
            # MultiDocumenter.Column(
            #     "High-level training libraries",
            #     [
            #         MultiDocumenter.MultiDocRef(
            #             upstream = joinpath(clonedir, "FluxTraining"),
            #             path = "fluxtraining",
            #             name = "FluxTraining",
            #             giturl = "https://github.com/FluxML/FluxTraining.jl.git",
            #         ),
            #         MultiDocumenter.MultiDocRef(
            #             upstream = joinpath(clonedir, "FastAI"),
            #             path = "fastai",
            #             name = "FastAI",
            #             giturl = "https://github.com/FluxML/FastAI.jl.git",
            #         ),
            #     ],
            # ),
        ],
    ),
    MultiDocumenter.MegaDropdownNav(
        "Models",
        [
            MultiDocumenter.Column(
                "Computer Vision",
                [
                    MultiDocumenter.MultiDocRef(
                        upstream = joinpath(clonedir, "Metalhead"),
                        path = "metalhead",
                        name = "Metalhead",
                        giturl = "https://github.com/FluxML/Metalhead.jl.git",
                    ),
                ],
            ),
            MultiDocumenter.Column(
                "Natural Language Processing",
                [
                    MultiDocumenter.MultiDocRef(
                        upstream = joinpath(clonedir, "Transformers"),
                        path = "transformers",
                        name = "Transformers",
                        giturl = "https://github.com/chengchingwen/Transformers.jl.git",
                    ),
                ],
            ),
        ],
    ),
]

outpath = mktempdir()

MultiDocumenter.make(
    outpath,
    docs;
    search_engine = MultiDocumenter.SearchConfig(
        index_versions = ["stable"],
        engine = MultiDocumenter.FlexSearch,
    )
)

if "deploy" in ARGS
    @warn "Deploying to GitHub" ARGS
    gitroot = normpath(joinpath(@__DIR__, ".."))
    run(`git pull`)
    outbranch = "gh-pages"
    has_outbranch = true
    if !success(`git checkout $outbranch`)
        has_outbranch = false
        if !success(`git switch --orphan $outbranch`)
            @error "Cannot create new orphaned branch $outbranch."
            exit(1)
        end
    end
    for file in readdir(gitroot; join = true)
        endswith(file, ".git") && continue
        rm(file; force = true, recursive = true)
    end
    for file in readdir(outpath)
        cp(joinpath(outpath, file), joinpath(gitroot, file))
    end
    run(`git add .`)
    if success(`git commit -m 'Aggregate documentation'`)
        @info "Pushing updated documentation."
        if has_outbranch
            run(`git push`)
        else
            run(`git push -u origin $outbranch`)
        end
        run(`git checkout main`)
    else
        @info "No changes to aggregated documentation."
    end
else
    @info "Skipping deployment, 'deploy' not passed. Generated files in docs/out." ARGS
    cp(outpath, joinpath(@__DIR__, "out"), force = true)
end

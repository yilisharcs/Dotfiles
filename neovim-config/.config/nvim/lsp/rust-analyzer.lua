return {
        cmd = { "lspmux" },
        filetypes = { "rust" },
        root_markers = {
                "Cargo.toml",
                "Cargo.lock",
        },
        settings = {
                ["rust_analyzer"] = {
                        cargo = { allFeatures = true },
                        check = {
                                overrideCommand = {
                                        "cargo",
                                        "clippy",
                                        "--fix",
                                        "--allow-dirty",
                                        "--message-format=json-diagnostic-rendered-ansi",
                                },
                        },
                },
        },
}

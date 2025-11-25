return {
        -- cmd = { "lspmux" },
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_markers = {
                "Cargo.toml",
                "Cargo.lock",
        },
        settings = {
                ["rust-analyzer"] = {
                        cargo = { allFeatures = true },
                        check = {
                                command = "clippy",
                                ignore = {
                                        "dead_code",
                                        "unused_variables",
                                        "unused_mut",
                                },
                        },
                        diagnostics = {
                                disabled = {
                                        "unlinked-file",
                                },
                        },
                },
        },
}

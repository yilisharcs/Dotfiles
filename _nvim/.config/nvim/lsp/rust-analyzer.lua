return {
        cmd = { "lspmux" },
        filetypes = { "rust" },
        root_markers = {
                "Cargo.toml",
                "Cargo.lock",
        },
        settings = {
                ["rust-analyzer"] = {
                        checkOnSave = false,
                        cargo = { features = "all" },
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

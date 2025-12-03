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
                        checkOnSave = false,
                        cargo = { allFeatures = true },
                        -- NOTE: I'm using bacon to populate the quickfix list {{{
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
                        -- }}}
                },
        },
}

return {
        "https://github.com/stevearc/conform.nvim",
        event = "BufReadPost",
        opts = {
                formatters_by_ft = {
                        c = { "clang-format" },
                        lua = { "stylua" },
                        rust = {
                                -- Rust shim is slower than providing the path manually
                                "/home/yilisharcs/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rustfmt",
                                lsp_format = "fallback",
                        },
                },
                format_on_save = {
                        timeout_ms = 2000,
                },
        },
}

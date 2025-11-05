return {
        "https://github.com/stevearc/conform.nvim",
        event = "BufReadPost",
        opts = {
                formatters_by_ft = {
                        c = { "clang-format" },
                        lua = { "stylua" },
                        rust = { "rustfmt", lsp_format = "fallback" },
                },
                format_on_save = {
                        timeout_ms = 2000,
                },
        },
}

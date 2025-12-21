return {
        "https://github.com/stevearc/conform.nvim",
        event = "BufReadPost",
        opts = {
                formatters_by_ft = {
                        lua = { "stylua" },
                        rust = { "rustfmt" },
                },
                formatters = {
                        rustfmt = {
                                -- Rust shim is slower than providing the path manually
                                command = "/home/yilisharcs/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rustfmt",
                        },
                },
                format_after_save = function(bufnr)
                        local name = vim.api.nvim_buf_get_name(bufnr)
                        if name:find("Projects/github.com/neovim/neovim/", 1, true) then return end
                        if name:find("diffview://", 1, true) then return end
                        return { timeout_ms = 2000 }
                end,
        },
}

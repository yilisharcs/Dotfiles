return {
        "williamboman/mason.nvim",
        build = ":MasonInstall " ..
            "lua-language-server " ..
            "tinymist " ..
            "vim-language-server",
        ft = {
                "lua",
                "markdown",
                "rust",
                "typst",
                "vim",
        },
        keys = {
                { "<leader>qm", "<CMD>Mason<CR>", desc = "[MASON] Menu" }
        },
        opts = {
                ui = {
                        border = "rounded",
                        backdrop = 100,
                }
        },
        init = function()
                vim.lsp.enable({
                        "luals",
                        "rust-analyzer",
                        "typls",
                        "vimls",
                })
        end
}

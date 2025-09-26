return {
        "williamboman/mason.nvim",
        build = ":MasonInstall " ..
            "clangd " ..
            "lua-language-server " ..
            "tinymist " ..
            "vim-language-server",
        ft = {
                "c",
                "cpp",
                "lua",
                "nu",
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
                        "clangd",
                        "luals",
                        "nuls",
                        "rust-analyzer",
                        "typls",
                        "vimls",
                })
        end
}

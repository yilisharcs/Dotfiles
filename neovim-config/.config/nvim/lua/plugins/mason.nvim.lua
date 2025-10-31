return {
        "https://github.com/williamboman/mason.nvim",
        -- stylua: ignore start
        build = ":MasonInstall "
              .. "clangd "
              .. "lua-language-server "
              .. "tinymist "
              .. "vim-language-server",
        -- stylua: ignore end
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
                { "<leader>qm", "<CMD>Mason<CR>", desc = "Open Mason menu" },
        },
        init = function()
                vim.lsp.enable({
                        "clangd",
                        "luals",
                        "nuls", -- External
                        "rust-analyzer", -- External
                        "typls",
                        "vimls",
                })

                -- Ensure Mason can detect fnm
                vim.env.PATH = vim.fs.abspath(".local/share/fnm/aliases/default/bin") .. ":" .. os.getenv("PATH")
        end,
        opts = {
                ui = {
                        border = "rounded",
                        backdrop = 100,
                },
        },
}

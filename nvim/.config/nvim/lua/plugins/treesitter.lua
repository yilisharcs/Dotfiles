return {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
                "RRethy/nvim-treesitter-endwise",
                "HiPhish/rainbow-delimiters.nvim",
        },
        build = ":TSUpdate",
        cond = not vim.g.shell_editor == true,
        event = { "BufReadPost [^:]*", "BufNewFile" },
        config = function()
                require("nvim-treesitter.configs").setup({
                        ensure_installed = {
                                "asm",
                                "bash",
                                "c",
                                "comment",
                                "desktop",
                                "diff",
                                "editorconfig",
                                "git_config",
                                "gitcommit",
                                "gitignore",
                                "html",
                                "ini",
                                "json",
                                "lua",
                                "markdown",
                                "markdown_inline",
                                "meson",
                                -- "muttrc",
                                "ninja",
                                "nu",
                                "objdump",
                                -- "php",
                                "python",
                                "query",
                                "rust",
                                "strace",
                                "toml",
                                "typst",
                                "udev",
                                "vim",
                                "vimdoc",
                                -- "wgsl_bevy",
                                "xml",
                                "yaml",
                        },
                        sync_install = false,
                        auto_install = true,
                        ignore_install = {
                                "make",
                                "tmux",
                        },
                        highlight = { enable = true },
                        indent = { enable = true },
                        additional_vim_regex_highlighting = { "markdown" },
                })

                vim.keymap.set("n", "<M-u>", "<CMD>TSBufToggle highlight<CR>", { desc = "[TS] Toggle highlights" })
                vim.keymap.set("n", "<leader><F9>", "<CMD>InspectTree<CR>", { desc = "[TS] Inspect tree" })

                vim.cmd([[
                        " Required: treesitter resets filetype syntax opts
                        augroup Markdown_Syn
                                au!
                                au BufEnter *.md set syntax=ON
                        augroup END
                ]])
        end
}

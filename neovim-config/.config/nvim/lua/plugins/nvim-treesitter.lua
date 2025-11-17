return {
        "https://github.com/nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        dependencies = {
                "https://github.com/RRethy/nvim-treesitter-endwise",
        },
        cond = not vim.g.shell_editor == true,
        event = { "BufReadPost [^:]*", "BufNewFile" },
        config = function()
                local filetypes = {
                        "asm",
                        "bash",
                        "c",
                        "comment",
                        "cpp",
                        "css",
                        "desktop",
                        "diff",
                        "editorconfig",
                        "git_config",
                        "git_rebase",
                        "gitattributes",
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
                }
                require("nvim-treesitter").install(filetypes)
                vim.api.nvim_create_autocmd({ "FileType" }, {
                        desc = "Enable nvim-treesitter features",
                        group = vim.api.nvim_create_augroup(
                                "PlugTreesitter",
                                { clear = true }
                        ),
                        pattern = filetypes,
                        callback = function()
                                vim.treesitter.start()
                                vim.bo.indentexpr =
                                        "v:lua.require'nvim-treesitter'.indentexpr()"
                                if vim.bo.filetype == "markdown" then
                                        vim.bo.syntax = "ON"
                                end
                        end,
                })

                vim.keymap.set(
                        "n",
                        "<M-u>",
                        "<CMD>TSBufToggle highlight<CR>",
                        { desc = "Toggle treesitter highlights" }
                )
                vim.keymap.set(
                        "n",
                        "<leader><F9>",
                        "<CMD>InspectTree<CR>",
                        { desc = "Inspect treesitter AST" }
                )
        end,
}

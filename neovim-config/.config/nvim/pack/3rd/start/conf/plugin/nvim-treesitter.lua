if vim.g.shell_editor then return end

vim.pack.add({
        "https://github.com/nvim-treesitter/nvim-treesitter",
        "https://github.com/RRethy/nvim-treesitter-endwise",
        "https://github.com/HiPhish/rainbow-delimiters.nvim",
}, { load = true })

-- local group = vim.api.nvim_create_augroup("Vimpack_Treesitter", { clear = true })
-- vim.api.nvim_create_autocmd("PackChanged", {
--         desc = "Update Treesitter parsers",
--         group = group,
--         callback = function(event)
--                 if vim.g.did_vimpack_nvim_treesitter == 1 then return end
--                 vim.g.did_vimpack_nvim_treesitter = 1
--                 if event.data.kind == "update" then
--                         ---@diagnostic disable-next-line: param-type-mismatch
--                         local ok = pcall(vim.cmd, "TSUpdate")
--                         if ok then
--                                 vim.notify(
--                                         "TSUpdate completed successfully!",
--                                         vim.log.levels.INFO,
--                                         { title = "vim.pack" })
--                         else
--                                 vim.notify(
--                                         "TSUpdate command not available yet, skipping",
--                                         vim.log.levels.WARN,
--                                         { title = "vim.pack" })
--                         end
--                 end
--         end
-- })

require("nvim-treesitter.configs").setup({
        ensure_installed = {
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
                "jsonc",
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
        indent = { enable = true },
        highlight = {
                enable = true,
                additional_vim_regex_highlighting = { "markdown" },
        },
})

vim.keymap.set("n", "<M-u>", "<CMD>TSBufToggle highlight<CR>", { desc = "[TS] Toggle highlights" })
vim.keymap.set("n", "<leader><F9>", "<CMD>InspectTree<CR>", { desc = "[TS] Inspect tree" })

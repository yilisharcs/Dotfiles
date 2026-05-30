if vim.g.shell_editor then
        return
end

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
        "glsl",
        "html",
        "ini",
        "javascript",
        "json",
        "just",
        "lua",
        "markdown",
        "markdown_inline",
        "meson",
        -- "muttrc",
        "ninja",
        "nix",
        "nu",
        "objdump",
        -- "php",
        "python",
        "query",
        "rust",
        "strace",
        "toml",
        "udev",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "zig",
}

require("nvim-treesitter").install(filetypes)
vim.api.nvim_create_autocmd({ "FileType" }, {
        desc = "Enable nvim-treesitter features",
        group = vim.api.nvim_create_augroup("PlugTreesitter", { clear = true }),
        pattern = filetypes,
        callback = function()
                vim.treesitter.start()
                -- FIXME: treesitter indentation for these filetypes is buggy;
                --        fallback to built-in.
                if
                        not vim.tbl_contains({
                                "nix",
                                "vim",
                        }, vim.bo.filetype)
                then
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
                -- NOTE: i have custom syntax highlighting for these filetypes
                if
                        vim.tbl_contains({
                                "markdown",
                                "rust",
                        }, vim.bo.filetype)
                then
                        vim.bo.syntax = "ON"
                end
        end,
})

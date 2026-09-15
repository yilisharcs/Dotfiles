if vim.g.shell_editor then
    return
end

local filetypes = {
    -- low-level
    "asm",
    "m68k",
    "objdump",
    "strace",
    -- shell
    "bash",
    "nu",
    -- vcs
    "diff",
    "git_config",
    "git_rebase",
    "gitattributes",
    "gitcommit",
    "gitignore",
    "jjdescription",
    -- nvim package
    "c",
    "lua",
    "markdown",
    "markdown_inline",
    "query",
    "vim",
    "vimdoc",
    -- dev
    "cpp",
    "fennel",
    "glsl",
    "python",
    "rust",
    "zig",
    -- build
    "just",
    "meson",
    "ninja",
    -- config
    "css",
    "ini",
    "json",
    "nix",
    "toml",
    "xml",
    "yaml",
    -- rcfiles
    "desktop",
    "editorconfig",
    -- "muttrc",
    "tmux",
    "udev",
    -- web
    "html",
    "javascript",
    -- "php",
    --
    "comment",
}

require("nvim-treesitter").install(filetypes)
vim.api.nvim_create_autocmd({ "FileType" }, {
    desc = "Enable nvim-treesitter features",
    group = vim.api.nvim_create_augroup("PlugTreesitter", { clear = true }),
    pattern = filetypes,
    callback = function()
        vim.treesitter.start()
        -- FIXME: treesitter indentation for these filetypes is buggy; fallback to built-in
        if not vim.tbl_contains({
            "nix",
            "vim",
        }, vim.bo.filetype) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
        if
            vim.tbl_contains({
                "jjdescription",
                "markdown",
                "rust",
            }, vim.bo.filetype)
        then
            -- jujutsu specifically needs it scheduled
            vim.schedule(function()
                vim.bo.syntax = "ON"
            end)
        else
            -- HACK: syn=ON fires for files it shouldn't if scheduled
            vim.schedule(function()
                vim.bo.syntax = "OFF"
            end)
        end
    end,
})

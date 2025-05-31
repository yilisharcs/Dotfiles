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
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "comment",
        "nix",
        "nu",
        "query",
        "rust",
        "toml",
        "typst",
        "udev",
        "vim",
        "vimdoc",
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

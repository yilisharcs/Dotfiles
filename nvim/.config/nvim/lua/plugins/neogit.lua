return {
  "NeogitOrg/neogit",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "CmdlineEnter",
  keys = {
    { "<leader>i", "<CMD>Neogit<CR>" },
  },
  init = function()
    vim.cmd([[
      cnoreabbrev <expr> git (getcmdtype() ==# ':' && getcmdline() =~# '^git') ? 'Neogit' : 'git'

      augroup Neo_Legit
        au!
        au Filetype NeogitCommitMessage setlocal iskeyword+=-,'
      augroup END
    ]])
  end,
  opts = {
    graph_style = "unicode",
  }
}

return {
  "yilisharcs/wikibrowse.nvim",
  enabled = false,
  dev = true,
  lazy = false,
  cmd = "WikiBrowse",
  keys = {
    { "<leader>e", "<CMD>WikiBrowse pizza<CR>" },
  },
  init =
      function()
        vim.cmd([[
        cnoreabbrev <expr> wiki (getcmdtype() ==# ':' && getcmdline() =~# '^wiki') ? 'WikiBrowse' : 'wiki'
      ]])
      end,
  opts = true
}

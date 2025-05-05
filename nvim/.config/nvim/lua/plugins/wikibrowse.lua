return {
  'yilisharcs/wikibrowse.nvim',
  dev = true,
  lazy = false,
  -- keys = {
  --   { '<leader>y', function() require('wikibrowse').wiki_open() end },
  -- },
  -- init =
  --   function()
  --     vim.cmd([[
  --       cnoreabbrev <expr> wiki (getcmdtype() ==# ':' && getcmdline() =~# '^wiki') ? 'WikiBrowse' : 'wiki'
  --     ]])
  --   end,
  opts = true
}

return {
  {
    'chrisgrieser/nvim-spider',
    event = { 'InsertEnter' },
    keys = {
      { 'w',  '<CMD>lua require("spider").motion("w")<CR>',  mode = { 'n', 'x', 'o' } },
      { 'e',  '<CMD>lua require("spider").motion("e")<CR>',  mode = { 'n', 'x', 'o' } },
      { 'b',  function() require("spider").motion("b") end,  mode = { 'n', 'x', 'o' } },
      { 'ge', '<CMD>lua require("spider").motion("ge")<CR>', mode = { 'n', 'x', 'o' } },
      -- -- won't load if typed too fast the first time. likely an issue with how lazy handles remap=true maps
      -- { '<C-w>', '<ESC>cvb', mode = 'i', remap = true },
    },
    opts = {},
    config = function(_, opts)
      require('spider').setup(opts)

      vim.keymap.set('i', '<C-w>', '<Esc>cvb', { remap = true })
    end
  },
}

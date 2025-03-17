return {
  {
    'chrisgrieser/nvim-various-textobjs',
    keys = {
      { 'ac', '<CMD>lua require("various-textobjs").subword("outer")<CR>', mode = { 'x', 'o' } },
      { 'ic', '<CMD>lua require("various-textobjs").subword("inner")<CR>', mode = { 'x', 'o' } },
    },
    opts = { useDefaultKeymaps = false },
  }
}

return {
  {
    'mbbill/undotree',
    keys = {
      { '<leader>u', vim.cmd.UndotreeToggle, desc = '[UNDO] Toggle Undotree' }
    },
    init = function()
      vim.cmd([[
        let g:undotree_SplitWidth=float2nr(&columns * 0.27 + 0.5)
        let g:undotree_WindowLayout=4
        let g:undotree_SetFocusWhenToggle=1
      ]])
    end
  }
}

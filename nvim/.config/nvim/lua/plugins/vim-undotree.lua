return {
  "yilisharcs/undotree",
  keys = {
    { "<leader>u", "<CMD>UndotreeToggle<CR>", desc = "Toggle history bar" }
  },
  config = function()
    vim.cmd([[
      let g:undotree_SplitWidth=float2nr(&columns * 0.27 + 0.5)
      let g:undotree_WindowLayout=4
      let g:undotree_SetFocusWhenToggle=1
    ]])
  end
}

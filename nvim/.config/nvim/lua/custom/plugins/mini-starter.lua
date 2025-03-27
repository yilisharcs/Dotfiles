return {
  {
    'echasnovski/mini.starter', -- see `:h MiniStarter.config`.
    enabled = false,
    version = false,
    lazy = false,
    opts = {
      header = '',
      footer = '',
    },
    init = function()
      vim.cmd([[
        augroup Mini_Starter_BS
          au!
          au User MiniStarterOpened nnoremap <buffer> <C-h> <CMD>lua MiniStarter.add_to_query()<CR>
          au User MiniStarterOpened nnoremap <buffer> <C-o> <C-o><C-o>
        augroup END
      ]])
    end
  },
}

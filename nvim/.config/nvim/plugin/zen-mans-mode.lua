vim.api.nvim_create_user_command('ZenMansMode', function()
  if vim.g.Zen_Mans_Mode ~= true then
    vim.g.Zen_Mans_Mode = true

    vim.cmd([[
      tab split
      set noruler
      set nonu nornu
      set laststatus=0
      set showtabline=0
      set foldcolumn=4
      if exists('$TMUX')
        silent :!tmux set-option -g status off
      endif

      hi ZenMans guibg=none guifg=#1e1e2e
      set winhighlight+=WinSeparator:ZenMans

      augroup ZenMans
        " Closes ZenMansMode if window changes
        au WinEnter * ZenMansMode
      augroup END
    ]])

    local win_width = vim.o.columns * 0.04
    local magic_width = math.floor(win_width)

    Magic_Bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(Magic_Bufnr, false, {
      split = 'right',
      width = magic_width,
      focusable = false,
      win = 0,
      style = 'minimal',
    })
  else
    vim.g.Zen_Mans_Mode = false

    vim.cmd([[
      augroup ZenMans
        " Must be called here; nvim_buf_delete will be called twice and error otherwise
        au!
      augroup END
    ]])

    vim.api.nvim_buf_delete(Magic_Bufnr, { force = true })

    vim.cmd([[
      tabclose
      set ruler
      set nu rnu
      set laststatus=2
      set showtabline=1
      if &diff
        set foldcolumn=2
      else
        set foldcolumn=0
      endif
      set winhighlight-=WinSeparator:ZenMans
      if exists('$TMUX')
        silent :!tmux set-option -g status on
      endif
    ]])
  end
end, {})
vim.keymap.set('n', '<F11>', vim.cmd.ZenMansMode)

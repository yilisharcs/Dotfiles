if vim.g.neovide then
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_left = 2
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_confirm_quit = true
  vim.g.neovide_cursor_smooth_blink = true
  vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.g.neovide_cursor_animate_command_line = true

  vim.go.guifont = 'JetBrainsMono Nerd Font Mono:h13'
  vim.g.neovide_scale_factor = 1.0
  vim.keymap.set({ 'n', 't' }, '<C-->', '<CMD>let g:neovide_scale_factor-=0.1<CR>')
  vim.keymap.set({ 'n', 't' }, '<C-=>', '<CMD>let g:neovide_scale_factor+=0.1<CR>')
  vim.keymap.set({ 'n', 't' }, '<C-0>', '<CMD>let g:neovide_scale_factor=1.0<CR>')

  vim.g.neovide_fullscreen = false
  vim.go.linespace = 2
  function Neovide_F11()
    if vim.g.neovide_fullscreen == false then
      vim.g.neovide_fullscreen = true
      vim.go.linespace = 2
    else
      vim.g.neovide_fullscreen = false
      vim.go.linespace = 2
    end
  end

  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<F11>', '<CMD>call Neovide_F11()<CR>')

  vim.keymap.set('n', '<C-S-V>', '<C-r>+', { desc = "Paste from clipboard" })
  vim.keymap.set('t', '<C-S-V>', '<C-\\><C-n>pi', { desc = "Paste from clipboard" })

  -- Neovide doesn't register C-4 as C-\
  vim.keymap.set('t', '<C-4><C-n>', [[<C-\><C-n>]])
  vim.keymap.set('t', '<C-4><C-r>', [['<C-\><C-n>"'.nr2char(getchar()).'pi']],
    { expr = true, desc = 'Paste from register $@' })

  -- Tmux-like workflow
  vim.keymap.set('n', '<C-SPACE><C-^>', '<CMD>wincmd g<TAB><CR>')
  -- C-^ registers as <TAB> for reasons unknown
  vim.keymap.set('t', '<C-SPACE><C-6>', '<CMD>wincmd g<TAB><CR>')
  vim.keymap.set('n', '<C-SPACE><LEFT>', '<CMD>-tabmove<CR>')
  vim.keymap.set('n', '<C-SPACE><RIGHT>', '<CMD>+tabmove<CR>')
  vim.keymap.set('t', '<C-SPACE>t', '<CMD>tab split<CR>')

  vim.keymap.set('t', '<C-SPACE>[', '<CMD>silent! !tmux copy-mode<TAB><CR>')
  vim.keymap.set('t', '<C-SPACE>d', '<CMD>silent! !tmux detach<CR>')

  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<C-SPACE>-', '<CMD>new | term<CR>')
  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<C-SPACE>=', '<CMD>vnew | term<CR>')
  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<C-SPACE>c', '<CMD>tabnew | term<CR>')
  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<C-SPACE>x', '<CMD>tabclose<CR>')

  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<C-SPACE>1', '<CMD>1tabnext<CR>')
  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<C-SPACE>2', '<CMD>2tabnext<CR>')
  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<C-SPACE>3', '<CMD>3tabnext<CR>')
  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<C-SPACE>4', '<CMD>4tabnext<CR>')
  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<C-SPACE>5', '<CMD>5tabnext<CR>')
  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<C-SPACE>6', '<CMD>6tabnext<CR>')
  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<C-SPACE>7', '<CMD>7tabnext<CR>')
  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<C-SPACE>8', '<CMD>8tabnext<CR>')
  vim.keymap.set({ 'n', 'x', 'i', 'c', 't' }, '<C-SPACE>9', '<CMD>9tabnext<CR>')

  vim.cmd([[
    augroup Neovide_Gen_Opts
      au!
      " Set default cwd if opened with no files as arguments
      au UIEnter * if argc(-1) == 0 | cd ~/.dotfiles | endif
      " Close nu buffers as if {cmd} wasn't supplied to :term
      au TermClose *:nu* silent! execute 'bdelete! '.expand('<abuf>')
    augroup END
  ]])
end

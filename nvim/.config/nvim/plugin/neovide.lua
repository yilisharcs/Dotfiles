if vim.g.neovide then
  vim.go.linespace = 1
  vim.g.neovide_transparency = 0.93
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_confirm_quit = true
  vim.g.neovide_fullscreen = false
  vim.g.neovide_cursor_smooth_blink = true
  vim.g.neovide_cursor_animate_command_line = true

  vim.api.nvim_set_hl(0, 'TreesitterContext', { bg = '#161616', blend = 20 })

  vim.keymap.set({ 'n', 't' }, '<C-Space><C-^>', '<CMD>wincmd g<Tab><CR>')
  vim.keymap.set('i', '<C-S-v>', '<C-r>+')
  vim.keymap.set('t', '<C-S-v>', [[<C-\><C-n>pi]])
  vim.keymap.set('n', '<S-Space>O', "<CMD>call append(line('.')-1, repeat('', v:count1))<CR>",
    { silent = true, desc = 'Newline above' })

  -- neovide doesn't register C-4 as C-\
  vim.keymap.set('t', '<C-4><C-n>', [[<C-\><C-n>]], { desc = "Neovide doesn't register C-4 as C-\\" })
  vim.keymap.set('t', '<C-4><C-r>', [['<C-\><C-n>"' . nr2char(getchar()) . 'pi']])
end

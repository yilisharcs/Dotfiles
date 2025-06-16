if vim.g.neovide then
  -- Set default cwd if opened with no files as arguments
  vim.api.nvim_create_autocmd({ "UIEnter" }, {
    group = vim.api.nvim_create_augroup("Neovide_Default_Dir", { clear = true }),
    callback = function()
      vim.cmd([[
        if argc(-1) == 0
          cd ~/.dotfiles
        endif
      ]])
    end
  })

  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_left = 2
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_confirm_quit = true
  vim.g.neovide_cursor_smooth_blink = true
  vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.g.neovide_cursor_animate_command_line = true
  vim.o.winblend = 1
  vim.g.neovide_floating_shadow = false

  vim.o.inccommand = "nosplit"

  vim.g.neovide_scale_factor = 1.0
  vim.keymap.set({ "n", "t" }, "<C-->", "<CMD>let g:neovide_scale_factor-=0.1<CR>")
  vim.keymap.set({ "n", "t" }, "<C-=>", "<CMD>let g:neovide_scale_factor+=0.1<CR>")
  vim.keymap.set({ "n", "t" }, "<C-0>", "<CMD>let g:neovide_scale_factor=1.0<CR>")

  vim.g.neovide_fullscreen = true
  vim.go.linespace = 1
  function Neovide_F11()
    if vim.g.neovide_fullscreen == false then
      vim.g.neovide_fullscreen = true
      vim.go.linespace = 1
    else
      vim.g.neovide_fullscreen = false
      vim.go.linespace = 2
    end
    if package.loaded["vim._extui"] then
      vim.cmd("sleep 500m")
      vim.cmd("new | close")
    end
  end

  vim.keymap.set({ "n", "x", "i", "c", "t" }, "<F11>", "<CMD>lua Neovide_F11()<CR>")
end

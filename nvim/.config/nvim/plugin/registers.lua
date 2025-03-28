local Set_Registers = vim.api.nvim_create_augroup('SetRegisters', { clear = true })

vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  desc     = 'Modify registers on launch',
  group    = Set_Registers,
  callback = function()
    -- Pure vimscript on ft-vim is finicky with comments
    vim.cmd([[
      " 97-102 = a-z
      for i in range(98,102) | silent! call setreg(nr2char(i), []) | endfor
      for i in range(104,122) | silent! call setreg(nr2char(i), []) | endfor

      " toggle capitalization
      let @c='wvg~'
    ]])
  end
})

vim.api.nvim_create_autocmd({ 'VimLeavePre' }, {
  desc     = 'Clear registers on exit',
  group    = Set_Registers,
  callback = function()
    -- 97-102 = a-z
    vim.cmd("for i in range(98,102) | silent! call setreg(nr2char(i), [' ']) | endfor")
    vim.cmd("for i in range(104,122) | silent! call setreg(nr2char(i), [' ']) | endfor")
  end
})

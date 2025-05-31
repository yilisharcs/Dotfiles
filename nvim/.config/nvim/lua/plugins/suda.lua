return {
  "lambdalisue/suda.vim",
  init = function()
    vim.cmd([[
      cnoreabbrev <expr> sudo (getcmdtype() ==# ':' && getcmdline() =~# '^sudo') ? 'SudaWrite' : 'sudo'
    ]])
  end
}

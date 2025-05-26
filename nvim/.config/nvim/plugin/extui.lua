require('vim._extui').enable({
  enable = true,
  msg = {
    pos = 'cmd',
    box = { timeout = 2500 }
  },
})

vim.o.cmdheight = 0

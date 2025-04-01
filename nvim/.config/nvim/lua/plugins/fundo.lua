return {
  {
    'kevinhwang91/nvim-fundo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = { 'BufReadPost [^:]*', 'BufNewFile' },
    build = function()
      require('fundo').install()
    end,
    config = function()
      require('fundo').setup()
      vim.o.undofile = true
    end
  }
}

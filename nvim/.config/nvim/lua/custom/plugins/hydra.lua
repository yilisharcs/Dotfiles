return {
  {
    -- 'nvimtools/hydra.nvim',
    'cathyprime/hydra.nvim', -- until #46 is fixed
    keys = { '<C-w>', 'z' },
    init = function()
      vim.opt.lazyredraw = false -- interferes with winning.vim
    end,
    config = function()
      require('custom.hydra')
    end
  }
}

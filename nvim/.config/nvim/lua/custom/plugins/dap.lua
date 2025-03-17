return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- 'nvimtools/hydra.nvim',
      'cathyprime/hydra.nvim', -- until #46 is fixed
      'theHamsta/nvim-dap-virtual-text',
      { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
    },
    keys = { '<leader>d' },
    config = function()
      require('custom.dap')
    end
  }
}

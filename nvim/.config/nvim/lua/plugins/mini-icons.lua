return {
  'echasnovski/mini.icons', -- see `:h MiniIcons.config`.
  version = false,
  lazy = true,
  specs = { { 'nvim-tree/nvim-web-devicons', enabled = false, optional = true } },
  init = function()
    package.preload['nvim-web-devicons'] = function()
      require('mini.icons').mock_nvim_web_devicons()
      return package.loaded['nvim-web-devicons']
    end

    vim.api.nvim_create_autocmd('ColorScheme', {
      group    = vim.api.nvim_create_augroup('Mini_Icons_Hl', { clear = true }),
      callback = function()
        vim.api.nvim_set_hl(0, 'MiniIconsAzure', { fg = '#74c7ec' })
        vim.api.nvim_set_hl(0, 'MiniIconsBlue', { fg = '#89b4fa' })
        vim.api.nvim_set_hl(0, 'MiniIconsCyan', { fg = '#94e2d5' })
        vim.api.nvim_set_hl(0, 'MiniIconsGreen', { fg = '#a6e3a1' })
        vim.api.nvim_set_hl(0, 'MiniIconsGrey', { fg = '#cdd6f4' })
        vim.api.nvim_set_hl(0, 'MiniIconsOrange', { fg = '#fab387' })
        vim.api.nvim_set_hl(0, 'MiniIconsPurple', { fg = '#cba6f7' })
        vim.api.nvim_set_hl(0, 'MiniIconsRed', { fg = '#f38ba8' })
        vim.api.nvim_set_hl(0, 'MiniIconsYellow', { fg = '#f9e2af' })
      end
    })
  end,
}

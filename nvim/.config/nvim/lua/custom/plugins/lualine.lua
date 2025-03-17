return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cond = not vim.g.is_tty,
    event = { 'VeryLazy' },
    init = function()
      vim.go.showmode = false
    end,
    opts = {
      options = {
        icons_enabled        = true,
        section_separators   = vim.g.neovide and {} or { left = '', right = '' },
        component_separators = vim.g.neovide and {} or { left = '', right = '' },
        theme                = {
          normal = {
            a = { bg = '#89b4fa', fg = '#181825', gui = 'bold' },
            b = { bg = '#313244', fg = '#89b4fa', gui = 'bold' },
            c = { bg = '#181825', fg = '#cdd6f4' },
          },
          insert = {
            a = { bg = '#a6e3a1', fg = '#1e1e2e', gui = 'bold' },
            b = { bg = '#313244', fg = '#a6e3a1', gui = 'bold' },
          },
          terminal = {
            a = { bg = '#a6e3a1', fg = '#1e1e2e', gui = 'bold' },
            b = { bg = '#313244', fg = '#a6e3a1', gui = 'bold' },
          },
          visual = {
            a = { bg = '#cba6f7', fg = '#1e1e2e', gui = 'bold' },
            b = { bg = '#313244', fg = '#cba6f7', gui = 'bold' },
          },
          replace = {
            a = { bg = '#f38ba8', fg = '#1e1e2e', gui = 'bold' },
            b = { bg = '#313244', fg = '#f38ba8', gui = 'bold' },
          },
          command = {
            a = { bg = '#fab387', fg = '#1e1e2e', gui = 'bold' },
            b = { bg = '#313244', fg = '#fab387', gui = 'bold' },
          },
          inactive = {
            a = { bg = '#181825', fg = '#89b4fa', gui = 'bold' },
            b = { bg = '#181825', fg = '#45475a', gui = 'bold' },
            c = { bg = '#181825', fg = '#6c7086' },
          },
        },
      },
      sections = {
        lualine_a = {
          'branch',
        },
        lualine_b = {
          'diff',
          'diagnostics',
          {
            'filetype',
            icon_only = true,
            padding = { left = 1, right = 0 }
          },
        },
        lualine_c = {
          { 'filename', path = 1 },
        },
        lualine_x = {
          { 'location', padding = 2 }
        },
        lualine_y = {
          'progress',
        },
        lualine_z = {
          'mode',
        }
      },
      inactive_sections = {
        lualine_a = { 'branch' },
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { { 'location', padding = 12 } },
        lualine_y = { 'progress' },
        lualine_z = {}
      },
      extensions = {
        'fugitive',
        'fzf',
        'lazy',
        'man',
        'mason',
        'nvim-dap-ui',
        'quickfix',
        'toggleterm',
      }
    }
  }
}

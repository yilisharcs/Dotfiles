return {
  'yilisharcs/lualine.nvim',
  branch = 'lf-extension',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  init = function()
    vim.go.showmode = false
  end,
  opts = {
    options = {
      icons_enabled        = true,
      section_separators   = { left = '', right = '' },
      component_separators = { left = '│', right = '│' },
      theme                = {
        normal = {
          a = { bg = '#181825', fg = '#89b4fa', gui = 'bold' },
          b = { bg = '#313244', fg = '#89b4fa', gui = 'bold' },
          c = { bg = '#181825', fg = '#edf6f4' },
        },
        insert = {
          a = { bg = '#181825', fg = '#a6e3a1', gui = 'bold' },
          b = { bg = '#313244', fg = '#a6e3a1', gui = 'bold' },
        },
        terminal = {
          a = { bg = '#181825', fg = '#a6e3a1', gui = 'bold' },
          b = { bg = '#313244', fg = '#a6e3a1', gui = 'bold' },
        },
        visual = {
          a = { bg = '#181825', fg = '#cba6f7', gui = 'bold' },
          b = { bg = '#313244', fg = '#cba6f7', gui = 'bold' },
        },
        replace = {
          a = { bg = '#181825', fg = '#f38ba8', gui = 'bold' },
          b = { bg = '#313244', fg = '#f38ba8', gui = 'bold' },
        },
        command = {
          a = { bg = '#181825', fg = '#fab387', gui = 'bold' },
          b = { bg = '#313244', fg = '#fab387', gui = 'bold' },
        },
        inactive = {
          a = { bg = '#767676', fg = '#0f0f0f', gui = 'bold' },
          b = { bg = '#313244', fg = '#edf6f4', gui = 'bold' },
          c = { bg = '#767676', fg = '#0f0f0f', gui = 'bold' },
        },
      },
    },
    sections = {
      lualine_a = { 'branch' },
      lualine_b = {
        'diff',
        'diagnostics',
        {
          'filetype',
          icon_only = true,
          padding = { left = 1, right = 0 }
        },
      },
      lualine_c = { { 'filename', path = 1 } },
      lualine_x = {
        {
          'searchcount',
          maxcount = 999,
          timeout = 500,
          separator = { right = '' }
        },
        { 'location', padding = 2 }
      },
      lualine_y = { 'progress' },
      lualine_z = { 'mode' }
    },
    inactive_sections = {
      lualine_a = { 'branch' },
      lualine_b = {
        'diff',
        'diagnostics',
        {
          'filetype',
          icon_only = true,
          padding = { left = 1, right = 0 }
        },
      },
      lualine_c = { { 'filename', path = 1 } },
      lualine_x = { { 'location', padding = 2 } },
      lualine_y = { 'progress' },
      lualine_z = { 'mode' }
    },
    extensions = {
      'lf',
      'man',
      'oil',
      'quickfix',
      'toggleterm',
    }
  }
}

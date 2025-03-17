return {
  {
    'EdenEast/nightfox.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        transparent = true,
        dim_inactive = true,
        styles = {
          comments = 'bold',
          conditionals = 'italic',
          keywords = 'bold',
          types = 'italic,bold',
        },
        modules = {
          ['cmp'] = true,
          ['dap-ui'] = true,
          ['lazy.nvim'] = true,
          ['mini'] = true,
          ['sneak'] = true,
          ['whichkey'] = true,
        },
      },
      palettes = {
        all = {
          yellow = "#f9e2af",
        },
      },
    },
  }
}

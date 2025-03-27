return {
  {
    'saghen/blink.cmp',
    lazy = false,
    dependencies = { 'rafamadriz/friendly-snippets' }, -- snippet sources, optional
    version = '1.0.0',
    -- build = 'cargo build --release',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      enabled = function()
        return not vim.tbl_contains({ 'markdown' }, vim.bo.filetype)
            and vim.bo.buftype ~= 'prompt'
            and vim.b.completion ~= false
      end,
      cmdline = {
        completion = {
          menu = {
            auto_show = false
          },
        },
        keymap = {
          ['<C-k>'] = {},
        },
      },
      keymap = {
        preset = 'default',
        ['<C-k>'] = { 'show', 'show_documentation', 'hide_documentation', 'fallback' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<C-y>'] = {},
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-q>'] = { 'snippet_backward', 'fallback' },
        ['<C-j>'] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          'snippet_forward',
          'fallback'
        },
      },
      completion = {
        menu = {
          draw = {
            columns = { { 'item_idx' }, { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
            components = {
              item_idx = {
                text = function(ctx) return ctx.idx == 10 and '0' or ctx.idx >= 10 and ' ' or tostring(ctx.idx) end,
              },
            }
          }
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          window = { border = 'rounded' },
        },
      },
      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- Will be removed in a future release
        use_nvim_cmp_as_default = true,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
      },
      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'snippets', 'lsp', 'path', 'buffer' },
        providers = {
          cmdline = {
            enabled = function()
              -- Ignores cmdline completions when executing shell commands
              return vim.fn.getcmdtype() ~= ':' or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
            end
          }
        }
      },
      signature = { -- experimental feature
        enabled = true,
        window = { border = 'single' },
      },
    },
    opts_extend = { 'sources.default' },
  }
}

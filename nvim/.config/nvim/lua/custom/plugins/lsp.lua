return {
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      { 'williamboman/mason.nvim',       opts = { ui = { border = 'rounded' } } },
      'neovim/nvim-lspconfig',
      'j-hui/fidget.nvim',
      { 'lukas-reineke/lsp-format.nvim', opts = {} },
    },
    ft = {
      'c',
      'javascript',
      'typescript',
      'lua',
      'rust',
      'vim',
    },
    keys = {
      { '<leader>qm', vim.cmd.Mason, desc = 'Mason' }
    },
    config = function()
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = 'rounded' },
        jump = { float = true },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = vim.g.is_tty and 'E' or '',
            [vim.diagnostic.severity.WARN] = vim.g.is_tty and 'W' or '',
            [vim.diagnostic.severity.INFO] = vim.g.is_tty and 'I' or '',
            [vim.diagnostic.severity.HINT] = vim.g.is_tty and 'H' or '󰌶',
          },
        },
      })

      require('fidget').setup({
        progress = {
          display = {
            done_icon = '✔ ',
            progress_icon = { pattern = 'moon' },
          },
        },
        notification = {
          window = {
            winblend = vim.g.neovide and 100 or 0,
          },
        }
      })

      local on_attach = function(client, bufnr)
        require('lsp-format').on_attach(client, bufnr)
      end

      require('mason-lspconfig').setup({
        ensure_installed = {
          'lua_ls',
          'rust_analyzer',
          'ts_ls',
          'vimls',
        },
        handlers = {
          function(server) -- default handler
            require('lspconfig')[server].setup({
              on_attach = on_attach,
            })
          end,
          ['rust_analyzer'] = function()
            require('lspconfig').rust_analyzer.setup({
              on_attach = on_attach,
              cmd = { 'rustup', 'run', 'stable', 'rust-analyzer' },
              settings = {
                ['rust_analyzer'] = {
                  cargo = { allFeatures = true }
                }
              },
            })
          end,
          ['lua_ls'] = function()
            require('lspconfig').lua_ls.setup({
              on_attach = on_attach,
              settings = {
                Lua = {
                  runtime = {
                    version = 'LuaJIT',
                    path = { 'lua/?.lua', 'lua/?/init.lua' }
                  },
                  diagnostics = { globals = { 'vim' } },
                  workspace = {
                    library = { 'lua', vim.env.VIMRUNTIME, '${3rd}/luv/library' },
                    checkThirdParty = false,
                  },
                  telemetry = { enable = false },
                }
              }
            })
          end,
        },
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP Actions',
        callback = function(event)
          local handlers = vim.lsp.handlers
          handlers['textDocument/hover'] = vim.lsp.with(handlers.hover, { border = 'rounded' })
          handlers['textDocument/signatureHelp'] = vim.lsp.with(handlers.signature_help, { border = 'rounded' })

          local client = vim.lsp.get_clients()[1]
          local namespace = vim.lsp.diagnostic.get_namespace(client.id)

          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
          end

          local map = function(mode, lhs, rhs, desc)
            if desc then
              desc = '[LSP] ' .. desc
            end
            vim.keymap.set(mode, lhs, rhs, { silent = true, buffer = event.buf, desc = desc })
          end

          map('ca', 'wq', 'execute "Format sync" | wq')

          map('n', 'K', function() vim.lsp.buf.hover() end, 'Help') -- required if keywordprg is set
          -- map('i', '<C-k>', function() vim.lsp.buf.signature_help() end, 'Signature Help') -- provided by blink.cmp
          map('n', '<leader>-', function() vim.diagnostic.setqflist({ namespace = namespace }) end, 'Set Quickfix')

          map('n', 'gd', function() vim.lsp.buf.definition() end, 'Definition')
          map('n', 'grd', function() vim.lsp.buf.declaration() end, 'Declaration')
          map('n', 'grt', function() vim.lsp.buf.type_definition() end, 'Type Definition')
          map('n', 'grw', function() vim.lsp.buf.workspace_symbol() end, 'Workspace Symbol')
          -- Unnecessary in nvim v0.11.0
          map('n', 'grf', function() vim.diagnostic.open_float() end, 'Open Error Float')
          -- -- Defaults
          map('n', '[d', function() vim.diagnostic.goto_prev() end, 'Diagnostic Prev')
          map('n', ']d', function() vim.diagnostic.goto_next() end, 'Diagnostic Next')
          -- map('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Diagnostic Prev')
          -- map('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Diagnostic Next')
          map('n', 'grn', function() vim.lsp.buf.rename() end, 'Rename')
          map('n', 'gra', function() vim.lsp.buf.code_action() end, 'Code_action')
          map('n', 'grr', function() vim.lsp.buf.references() end, 'References')
          map('n', 'gri', function() vim.lsp.buf.implementation() end, 'Implementation')
        end
      })
    end
  },
}

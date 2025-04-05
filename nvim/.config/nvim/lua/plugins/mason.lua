return {
  {
    'williamboman/mason.nvim',
    ft = {
      'c',
      'cpp',
      'lua',
      'rust',
      'vim',
    },
    keys = {
      { '<leader>qm', vim.cmd.Mason, desc = '[MASON] Open Menu' }
    },
    opts = {
      ui = { border = 'rounded' }
    },
    init = function()
      vim.lsp.enable({
        'clangd',
        'luals',
        'rust-analyzer',
        'vimls',
      })

      vim.lsp.set_log_level('off')

      vim.lsp.config('*', {
        capabilities = {
          textDocument = {
            semanticTokens = {
              multilineTokenSupport = true,
            }
          }
        },
        root_markers = { '.git' },
      })

      vim.diagnostic.config({
        virtual_lines = { current_line = true },
        float = { border = 'rounded' },
        jump = { float = true },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.INFO] = '',
            [vim.diagnostic.severity.HINT] = '',
          },
          numhl = {
            [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
            [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
            [vim.diagnostic.severity.INFO] = 'DiagnosticSignInfo',
          }
        },
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP Actions',
        group = vim.api.nvim_create_augroup('LSProtocol', {}),
        callback = function(args)
          local map = function(mode, lhs, rhs, desc)
            if desc then
              desc = '[LSP] ' .. desc
            end
            vim.keymap.set(mode, lhs, rhs, { silent = true, buffer = args.buf, desc = desc })
          end

          local client = vim.lsp.get_clients()[1]
          local namespace = vim.lsp.diagnostic.get_namespace(client.id)
          map('n', 'grq', function() vim.diagnostic.setqflist({ namespace = namespace, open = true }) end,
            'Set Quickfix')

          local LSP_Opts = vim.api.nvim_create_augroup('LSP_Opts', { clear = false })

          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
            vim.api.nvim_create_autocmd('InsertEnter', {
              group = LSP_Opts,
              callback = function()
                if vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }) then
                  vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
                  vim.api.nvim_create_autocmd('InsertLeave', {
                    buffer = args.buf,
                    once = true,
                    callback = function() vim.lsp.inlay_hint.enable(true, { bufnr = args.buf }) end,
                  })
                end
              end
            })

            if not client:supports_method('textDocument/willSaveWaitUntil')
                and client:supports_method('textDocument/formatting') then
              vim.api.nvim_create_autocmd('BufWritePre', {
                group = LSP_Opts,
                buffer = args.buf,
                callback = function()
                  vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 3000 })
                end,
              })
            end
          end

          if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = false })
          end

          map('n', 'K', function() vim.lsp.buf.hover() end, 'Help') -- required if keywordprg is set
          map('n', 'grd', function() vim.lsp.buf.declaration() end, 'Declaration')
          map('n', 'grt', function() vim.lsp.buf.type_definition() end, 'Type Definition')
          map('n', 'grw', function() vim.lsp.buf.workspace_symbol() end, 'Workspace Symbol')
          map('n', 'grf', function() vim.diagnostic.open_float() end, 'Open Error Float')
        end
      })
    end
  }
}

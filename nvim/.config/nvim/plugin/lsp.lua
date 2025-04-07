vim.lsp.set_log_level('off')

vim.lsp.config('*', {
  root_markers = { '.git' },
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      }
    }
  }
})

vim.diagnostic.config({
  virtual_text = true,
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
    local client = vim.lsp.get_clients()[1]

    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = false })
    end

    if not client:supports_method('textDocument/willSaveWaitUntil')
        and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('LSP_Opts', { clear = false }),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 3000 })
        end,
      })
    end

    local map = function(mode, lhs, rhs, desc)
      if desc then
        desc = '[LSP] ' .. desc
      end
      vim.keymap.set(mode, lhs, rhs, { silent = true, buffer = args.buf, desc = desc })
    end

    local namespace = vim.lsp.diagnostic.get_namespace(client.id)
    map('n', 'grq', function() vim.diagnostic.setqflist({ namespace = namespace, open = true }) end,
      'Set Quickfix')

    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
      map('n', 'ga', function()
        if vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }) then
          vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
        else
          vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
      end)
    end

    map('n', 'K', function() vim.lsp.buf.hover() end, 'Help') -- required if keywordprg is set
    map('n', 'grd', function() vim.lsp.buf.declaration() end)
    map('n', 'grt', function() vim.lsp.buf.type_definition() end)
    map('n', 'grw', function() vim.lsp.buf.workspace_symbol() end)
    map('n', 'grf', function() vim.diagnostic.open_float() end, 'Open Error Float')
  end
})

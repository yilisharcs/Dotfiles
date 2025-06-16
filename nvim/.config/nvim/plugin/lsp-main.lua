vim.lsp.enable({
  "luals",
  "nil-nix",
  -- "rust-analyzer",
  -- "typls",
  "vimls",
})

vim.lsp.set_log_level("off")

vim.diagnostic.config({
  virtual_text = true,
  float = { border = "rounded" },
  jump = { float = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
      [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
      [vim.diagnostic.severity.INFO] = "DiagnosticSignHint",
    }
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP Actions",
  group = vim.api.nvim_create_augroup("LSProtocol", {}),
  callback = function(args)
    local client = vim.lsp.get_clients()[1]

    local map = function(mode, lhs, rhs, desc)
      if desc then desc = "[LSP] " .. desc end
      vim.keymap.set(mode, lhs, rhs, { silent = true, buffer = args.buf, desc = desc })
    end

    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
      map("n", "<C-,>", function()
        if vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }) then
          vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
        else
          vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        end
      end)
    end

    map("n", "K", function() vim.lsp.buf.hover() end, "Help") -- required if keywordprg is set
    map("n", "grd", function() vim.lsp.buf.declaration() end, "Go to declaration")
    map("n", "grt", function() vim.lsp.buf.type_definition() end, "Go to type definition")
    map("n", "grw", function() vim.lsp.buf.workspace_symbol() end, "List workspace symbols")
    map("n", "grf", function() vim.diagnostic.open_float() end, "Open error float")
    map("n", "grq", function()
      vim.diagnostic.setqflist({ namespace = vim.lsp.diagnostic.get_namespace(client.id), open = true })
    end, "Send diagnostics to quickfix list")
  end
})

vim.cmd([[
  augroup Auto_Format
    au!
    au BufWritePre *.rs silent! RustFmt
  augroup END
]])

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group   = vim.api.nvim_create_augroup("Auto_Format_LSP", { clear = true }),
  pattern = {
    "*.lua",
    "*.vim",
    "*.typ",
  },
  command = "silent! lua vim.lsp.buf.format()"
})

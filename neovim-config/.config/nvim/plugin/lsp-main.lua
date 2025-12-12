vim.lsp.enable({
        "luals",
        "nuls", -- External
        "rust-analyzer", -- External
        "vimls",
})

vim.lsp.log.set_level("off")

-- HACK: The docs floating window does not respect `vim.o.winborder`. Does not respect
-- `vim.lsp.handlers["textDocument/signatureHelp"]` either. We must force it to obey.
vim.api.nvim_create_autocmd("CompleteChanged", {
        callback = function()
                vim.schedule(function()
                        local winid = vim.fn.complete_info().preview_winid
                        if winid and vim.api.nvim_win_is_valid(winid) then
                                vim.api.nvim_win_set_config(winid, { border = "rounded" })
                                -- We like treesitter highlighting
                                pcall(vim.api.nvim_set_option_value, "filetype", "markdown", {
                                        win = vim.api.nvim_win_get_buf(winid),
                                })
                        end
                end)
        end,
})

vim.diagnostic.config({
        virtual_text = true,
        float = { border = "rounded" },
        signs = { priority = 200 },
})

vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP Actions",
        group = vim.api.nvim_create_augroup("LSProtocol", {}),
        callback = function(args)
                local client = vim.lsp.get_clients()[1]
                local ns = vim.lsp.diagnostic.get_namespace(client.id)

                vim.lsp.completion.enable(true, client.id, args.buf, {
                        autotrigger = true,
                        convert = function(item)
                                return { abbr = item.label:gsub("%b()", "") }
                        end,
                })

                local map = function(mode, lhs, rhs, desc)
                        if desc then desc = "[LSP] " .. desc end
                        vim.keymap.set(mode, lhs, rhs, {
                                silent = true,
                                buffer = args.buf,
                                desc = desc,
                        })
                end

                if client.server_capabilities.inlayHintProvider then
                        map("n", "<C-,>", function()
                                if
                                        vim.lsp.inlay_hint.is_enabled({
                                                bufnr = args.buf,
                                        })
                                then
                                        vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
                                else
                                        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
                                end
                        end)
                end

                -- stylua: ignore start
                map("n", "K", function() vim.lsp.buf.hover() end, "Help") -- required if keywordprg is set
                map("n", "grd", function() vim.lsp.buf.declaration() end, "Go to declaration")
                map("n", "grt", function() vim.lsp.buf.type_definition() end, "Go to type definition")
                map("n", "grw", function() vim.lsp.buf.workspace_symbol() end, "List workspace symbols")
                map("n", "grf", function() vim.diagnostic.open_float() end, "Open error float")
                map("n", "grq", function() vim.diagnostic.setqflist({ namespace = ns }) end, "Quickfix diagnostics")
                -- stylua: ignore end
        end,
})

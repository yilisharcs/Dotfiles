local hostname = vim.fn.system("uname -n"):gsub("\n", "")
if hostname == "gato" then
        vim.lsp.enable({
                "fennel-ls",
                -- "luals",
                "nil-nix",
                "nuls",
                -- "rust-analyzer",
                -- "zls",
        })
else
        vim.lsp.enable({
                "fennel-ls",
                "luals",
                "nil-nix",
                "nuls",
                -- "rust-analyzer",
                "zls",
        })
end

vim.diagnostic.config({
        virtual_text = true,
        float = { border = "rounded" },
        signs = { priority = 200 },
})

vim.lsp.log.set_level(vim.log.levels.OFF)

-- HACK: the docs floating window does not respect `vim.o.winborder`. we must force it to obey.
local _complete_set = vim.api.nvim__complete_set
---@diagnostic disable-next-line: duplicate-set-field
vim.api.nvim__complete_set = function(index, opts)
        local info = _complete_set(index, opts)
        if info.winid and vim.api.nvim_win_is_valid(info.winid) then
                vim.api.nvim_win_set_config(info.winid, { border = "rounded" })
        end
        return info
end

vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP Actions",
        group = vim.api.nvim_create_augroup("LSProtocol", {}),
        callback = function(args)
                local client = vim.lsp.get_clients()[1]

                vim.lsp.completion.enable(true, client.id, args.buf, {
                        autotrigger = true,
                        convert = function(item)
                                return { abbr = item.label:gsub("%b()", "") }
                        end,
                })

                local map = function(mode, lhs, rhs, desc)
                        if desc then
                                desc = "[LSP] " .. desc
                        end
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

                -- required if keywordprg is set
                map("n", "K", function()
                        vim.lsp.buf.hover()
                end, "Help")
                map("i", "<C-s>", function()
                        vim.lsp.buf.signature_help()
                end, "Show signature help")
                map("n", "grd", function()
                        vim.lsp.buf.declaration()
                end, "Go to declaration")
                map("n", "grt", function()
                        vim.lsp.buf.type_definition()
                end, "Go to type definition")
                map("n", "grw", function()
                        vim.lsp.buf.workspace_symbol()
                end, "List workspace symbols")
                map("n", "grf", function()
                        vim.diagnostic.open_float()
                end, "Open error float")

                -- multiline diagnostic messages contain \n which nvim internally
                -- converts to \0 when storing in quickfix items. the vimscript->lua
                -- bridge truncates strings at \0, making the full text invisible to
                -- the lua-based quickfixtextfunc, but NOT invisible to ME!
                -- stripping \n here prevents that entirely.
                local function format(diagnostic)
                        return (diagnostic.message:gsub("\n", ""))
                end
                map("n", "grq", function()
                        vim.diagnostic.setqflist({
                                format = format,
                        })
                end, "Quickfix diagnostics")
                map("n", "gre", function()
                        vim.diagnostic.setqflist({
                                format = format,
                                severity = vim.diagnostic.severity.ERROR,
                        })
                end, "Quickfix error diagnostics")
        end,
})

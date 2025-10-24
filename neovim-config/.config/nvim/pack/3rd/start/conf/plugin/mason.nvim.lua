vim.pack.add({
        "https://github.com/williamboman/mason.nvim",
})

-- local group = vim.api.nvim_create_augroup("Vimpack_Mason", { clear = true })
-- vim.api.nvim_create_autocmd("PackChanged", {
--         desc = "Update Mason binaries",
--         group = group,
--         callback = function(event)
--                 if vim.g.did_vimpack_mason == 1 then return end
--                 vim.g.did_vimpack_mason = 1
--                 if event.data.kind == "update" or event.data.kind == "install" then
--                         local cmd = table.concat({
--                                 ":MasonInstall",
--                                 --
--                                 "clangd",
--                                 "lua-language-server",
--                                 "tinymist",
--                                 "vim-language-server",
--                         }, " ")
--                         ---@diagnostic disable-next-line: param-type-mismatch
--                         local ok = pcall(vim.cmd, cmd)
--                         if ok then
--                                 vim.notify(
--                                         "MasonInstall completed successfully!",
--                                         vim.log.levels.INFO,
--                                         { title = "vim.pack" })
--                         else
--                                 vim.notify(
--                                         "MasonInstall command not available yet, skipping",
--                                         vim.log.levels.WARN,
--                                         { title = "vim.pack" })
--                         end
--                 end
--         end
-- })

require("mason").setup({
        ui = {
                border = "rounded",
                backdrop = 100,
        }
})

vim.keymap.set("n", "<leader>qm", "<CMD>Mason<CR>", { desc = "Open Mason menu" })

vim.lsp.enable({
        "clangd",
        "luals",
        "nuls",          -- External
        "rust-analyzer", -- External
        "typls",
        "vimls",
})

-- Ensure Mason can detect fnm
vim.env.PATH =
    vim.fs.abspath(".local/share/fnm/aliases/default/bin")
    .. ":"
    .. os.getenv("PATH")

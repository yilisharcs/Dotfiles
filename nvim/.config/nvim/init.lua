vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "-", "<CMD>Ex<CR>")
vim.keymap.set("n", "<leader>ql", "<CMD>Lazy<CR>")

vim.env.NVIM_LISTEN_SOCKET = vim.v.servername

if vim.v.argv[3] ~= nil then
        local shell_editor = {
                "^/tmp/%S+%.nu$",
                "^/tmp/bash%-fc%.%w+$",
        }
        for _, pat in ipairs(shell_editor) do
                if string.match(vim.v.argv[3], pat) ~= nil then
                        vim.g.shell_editor = true
                end
        end
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
                vim.api.nvim_echo({
                        { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                        { out,                            "WarningMsg" },
                        { "\nPress any key to exit..." },
                }, true, {})
                vim.fn.getchar()
                os.exit(1)
        end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ import = "plugins" }, {
        change_detection = { notify = false },
        dev = {
                path = "~/Projects/plugins-nvim",
                patterns = {},
                fallback = false,
        },
        install = {
                colorscheme = { "lunaperche" },
        },
        ui = {
                border = "rounded",
                backdrop = 100,
        },
})

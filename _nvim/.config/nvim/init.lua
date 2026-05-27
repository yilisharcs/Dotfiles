-- restore system XDG paths for child processes (xdg-open, etc.)
-- this doesn't affect RTP because it's already been calculated.
if vim.env._OLD_XDG_DATA_DIRS then
        vim.env.XDG_DATA_DIRS = vim.env._OLD_XDG_DATA_DIRS
end
if vim.env._OLD_XDG_CONFIG_DIRS then
        vim.env.XDG_CONFIG_DIRS = vim.env._OLD_XDG_CONFIG_DIRS
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

if #vim.v.argf ~= 0 and string.match(vim.v.argf[1], "^/tmp/%S+%.nu$") ~= nil then
        vim.g.shell_editor = true
end

vim.g.netrw_banner = 0
vim.keymap.set("n", "-", "<CMD>Ex<CR>", { desc = "Fallback file explorer " })

vim.keymap.set("n", "<leader>h", "`H", { desc = "File mark `H" })
vim.keymap.set("n", "<leader>j", "`J", { desc = "File mark `J" })
vim.keymap.set("n", "<leader>k", "`K", { desc = "File mark `K" })
vim.keymap.set("n", "<leader>l", "`L", { desc = "File mark `L" })

vim.keymap.set("n", "<leader>P", ":= P()<LEFT>", { desc = "Printf util" })
function P(...)
        local args = {}
        for _, arg in ipairs({ ... }) do
                table.insert(args, vim.inspect(arg))
        end
        print(unpack(args))
        return ...
end

-- EDITOR OPTIONS
-- enable project-local configuration
vim.o.exrc = true

-- sync clipboard between OS and Nvim
vim.api.nvim_create_autocmd("UIEnter", {
        callback = function()
                vim.o.clipboard = "unnamedplus"
        end,
})

vim.cmd("aunmenu PopUp.How-to\\ disable\\ mouse")
vim.cmd("aunmenu PopUp.-2-")

-- long-running undo trees
vim.o.swapfile = false
vim.o.undofile = true
vim.o.backup = true
vim.o.backupext = ".backup"
vim.o.backupdir = os.getenv("HOME") .. "/.local/state/nvim/backup//"

vim.o.spelllang = "en_us"

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.linebreak = true
vim.o.scrolloff = 4
vim.o.sidescrolloff = 4

-- indenting
vim.o.tabstop = 8
vim.o.softtabstop = 8
vim.o.shiftwidth = 8
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.cursorlineopt = "number"

-- hide search finish warning
vim.opt.shortmess:append({ s = true })

-- proper splits
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.tabclose = "uselast"

vim.o.foldcolumn = "1"
vim.o.foldmethod = "marker"
vim.o.foldlevel = 0

vim.o.numberwidth = 3
vim.o.signcolumn = "yes:1"
vim.o.statuscolumn = "%C%l%s"
vim.o.cmdheight = 1

vim.opt.isfname:append({ "@-@" })

vim.o.pumheight = math.floor(vim.o.lines * 0.25 + 0.5)
vim.o.completeopt = "noselect,menuone,popup,fuzzy"

-- <C-a> and <C-x> don't recognize signed numbers
vim.opt.nrformats:append({ "unsigned" })

-- no more ~ on empty buffer space
vim.o.fillchars = "eob: "

vim.o.guicursor = "a:block,c-ci-i-r:blinkwait700-blinkoff700-blinkon700"

vim.opt.diffopt:prepend({ "algorithm:patience", "hiddenoff" })

-- terminal scrollback
vim.o.scrollback = 100000

vim.o.updatetime = 1500
vim.o.virtualedit = "block"
vim.o.winborder = "rounded"
vim.o.winwidth = 15

-- nushell doesn't grok vi
vim.o.shell = "/run/current-system/sw/bin/bash"

-- display vs TTY
vim.o.list = true
vim.o.termguicolors = true
vim.opt_global.listchars = { nbsp = "␣", tab = "│ ", trail = "•" }

if os.getenv("DISPLAY") == nil then
        vim.o.termguicolors = false
end

vim.o.background = "dark"
vim.cmd.colorscheme("silverwine")

-- PACKAGE MANAGER
vim.g.loaded_tutor_mode_plugin = 1

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({
                "git",
                "clone",
                "--filter=blob:none",
                "--branch=stable",
                lazyrepo,
                lazypath,
        })
        if vim.v.shell_error ~= 0 then
                vim.api.nvim_echo({
                        { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                        { out, "WarningMsg" },
                        { "\nPress any key to exit..." },
                }, true, {})
                vim.fn.getchar()
                os.exit(1)
        end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ import = "plugins" }, {
        change_detection = {
                notify = false,
        },
        dev = {
                path = vim.fs.joinpath(vim.fn.stdpath("config"), "pack/dev/opt"),
        },
        -- stop pestering me about luarocks!!
        rocks = {
                enabled = false,
        },
        ui = {
                size = {
                        height = 0.93,
                        width = 0.99,
                },
                border = "rounded",
                backdrop = 100,
        },
        performance = {
                -- gonna be real with ya, i kinda need pack/ sometimes
                rtp = { reset = false },
        },
})
vim.keymap.set("n", "<leader>ql", "<CMD>Lazy<CR>")

vim.api.nvim_create_autocmd("User", {
        desc = "Useful for plugin devs? I don't think so!",
        pattern = "VeryLazy",
        command = "autocmd! BufWritePost *.rockspec",
})

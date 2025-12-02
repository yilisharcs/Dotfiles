vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Expose socket env variable outside of nvim
vim.env.NVIM_LISTEN_SOCKET = vim.v.servername

if string.match(vim.v.argv[#vim.v.argv], "^/tmp/%S+%.nu$") ~= nil then
        vim.g.shell_editor = true
end

vim.keymap.set("n", "-", "<CMD>Ex<CR>", { desc = "Fallback file explorer " })
vim.keymap.set("n", "<leader>h", "`H", { desc = "File mark `H" })
vim.keymap.set("n", "<leader>j", "`J", { desc = "File mark `J" })
vim.keymap.set("n", "<leader>k", "`K", { desc = "File mark `K" })
vim.keymap.set("n", "<leader>l", "`L", { desc = "File mark `L" })

-- EDITOR OPTIONS
-- Enable project-local configuration
vim.o.exrc = true

-- Sync clipboard between OS and Neovim
vim.api.nvim_create_autocmd("UIEnter", {
        callback = function()
                vim.o.clipboard = "unnamedplus"
        end,
})
vim.g.clipboard = "xclip"

vim.cmd("aunmenu PopUp.How-to\\ disable\\ mouse")
vim.cmd("aunmenu PopUp.-2-")

-- Long-running undo trees
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

-- Indenting
vim.o.tabstop = 8
vim.o.softtabstop = 8
vim.o.shiftwidth = 8
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.cursorlineopt = "number"

-- Hide search finish warning
vim.opt.shortmess:append({ s = true })

-- Proper splits
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.tabclose = "uselast"

vim.o.foldcolumn = "1"
vim.o.foldmethod = "marker"
vim.o.foldlevel = 0

vim.o.numberwidth = 3
vim.o.signcolumn = "yes:1"
vim.o.statuscolumn = "%C%l%s"

vim.opt.isfname:append({ "@-@" })

vim.o.pumheight = math.floor(vim.o.lines * 0.25 + 0.5)
vim.o.completeopt = "noselect,menuone,popup,fuzzy"

-- Ctrl-a/x doesn't recognize signed numbers
vim.opt.nrformats:append({ "unsigned" })

-- No more ~ on empty buffer space
vim.o.fillchars = "eob: "

vim.o.guicursor = "a:block,c-ci-i-r:blinkwait700-blinkoff700-blinkon700"

vim.opt.diffopt:prepend({ "algorithm:patience", "hiddenoff" })

-- Terminal scrollback
vim.o.scrollback = 100000

vim.o.updatetime = 1500
vim.o.virtualedit = "block"
vim.o.winborder = "rounded"
vim.o.winwidth = 15

-- Nushell doesn't grok vi
vim.o.shell = vim.fn.exepath("bash")

-- Display vs TTY
vim.o.list = true
vim.o.termguicolors = true
vim.opt_global.listchars = { nbsp = "␣", tab = "› ", trail = "•" }

if os.getenv("DISPLAY") == nil then vim.o.termguicolors = false end

vim.cmd.colorscheme("tricky")

-- PACKAGE MANAGER
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
                path = vim.fs.joinpath(
                        vim.fn.stdpath("config"),
                        "pack/dev/opt"
                ),
        },
        ui = {
                size = {
                        height = 0.93,
                        width = 0.99,
                },
                border = "rounded",
                backdrop = 100,
        },
})
vim.keymap.set("n", "<leader>ql", "<CMD>Lazy<CR>")

vim.api.nvim_create_autocmd("User", {
        desc = "Useful for plugin devs? I don't think so!",
        pattern = "VeryLazy",
        command = "autocmd! BufWritePost *.rockspec",
})

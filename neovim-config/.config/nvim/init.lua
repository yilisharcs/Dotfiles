vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Expose socket env variable outside of nvim
vim.env.NVIM_LISTEN_SOCKET = vim.v.servername

if string.match(vim.v.argv[#vim.v.argv], "^/tmp/%S+%.nu$") ~= nil then vim.g.shell_editor = true end

-- EDITOR OPTIONS
-- Enable project-local configuration
vim.o.exrc = true

-- Add luarocks to packages and packpath
local data = vim.fn.stdpath("data")
local rocks = vim.fs.joinpath(data, "site/rocks")
package.path = package.path .. ";" .. rocks .. "/share/lua/5.1/?.lua;" .. rocks .. "/share/lua/5.1/?/init.lua"
package.cpath = package.cpath .. ";" .. rocks .. "/lib/lua/5.1/?.so"

-- Sync clipboard between OS and Neovim
vim.opt.clipboard:append({ "unnamedplus" })
vim.g.clipboard = "xclip"

vim.o.grepprg = "vimgrep.nu"
vim.o.makeprg = "mask"

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
vim.o.wrap = false
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
vim.o.completeopt = "noinsert,menuone,popup,fuzzy"

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

-- Rusty-tags support with custom tagfile name
vim.opt.tags:append({ "./rtags", ",rtags" })

-- Nushell doesn't grok vi
vim.o.shell = vim.fn.exepath("bash")

-- Display vs TTY
vim.o.list = true
vim.o.termguicolors = true
vim.opt_global.listchars = { nbsp = "␣", tab = "› ", trail = "•" }

if os.getenv("DISPLAY") == nil then vim.o.termguicolors = false end

vim.cmd.colorscheme("tricky")

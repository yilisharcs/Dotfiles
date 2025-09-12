-- Enable project-local configuration
vim.o.exrc = true

-- Sync clipboard between OS and Neovim
vim.opt.clipboard:append({ "unnamedplus" })
vim.g.clipboard = "xclip"

vim.o.ignorecase = true
vim.o.smartcase = true

-- Indenting
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.wrap = false
vim.o.linebreak = true

-- Long-running undo trees
vim.o.swapfile = false
vim.o.undofile = true

vim.o.scrolloff = 4
vim.o.sidescrolloff = 4

vim.o.number = true
vim.o.relativenumber = true

-- Hide search finish warning
vim.opt.shortmess:append({ s = true })

-- Proper splits
vim.o.splitright = true
vim.o.splitbelow = true

-- Fold opts
vim.o.foldcolumn = "0"
vim.o.foldmethod = "marker"
vim.o.foldlevel = 0

-- Column opts
vim.o.numberwidth = 3
vim.o.signcolumn = "yes:1"
vim.o.statuscolumn = "%l%s"

vim.opt.isfname:append({ "@-@" })

vim.o.pumheight = math.floor(vim.o.lines * 0.25 + 0.5)
vim.o.completeopt = "noinsert,menuone,popup,fuzzy"

-- Ctrl-a/x doesn't recognize signed numbers
vim.opt.nrformats:append({ "unsigned" })

-- No more ~ on empty buffer space
vim.o.fillchars = "eob: "

vim.o.guicursor = "a:block,c-ci-i-r:blinkwait700-blinkoff700-blinkon700"

vim.opt.diffopt:prepend({ "algorithm:patience" })

vim.o.cursorline = true
vim.o.cursorlineopt = "number"

vim.o.grepprg = "rg --vimgrep"

-- Terminal scrollback
vim.o.scrollback = 100000

vim.o.updatetime = 1000
vim.o.virtualedit = "block"
vim.o.winborder = "rounded"
vim.o.inccommand = "split"

-- Nushell doesn't grok vi
vim.o.shell = vim.fn.exepath("bash")

-- Display vs TTY
vim.o.list = true
vim.o.termguicolors = true
vim.opt.listchars = { nbsp = "␣", tab = "› ", trail = "•" }

if vim.env.DISPLAY == nil then
  vim.o.termguicolors = false
end

vim.cmd.colorscheme("tricky")

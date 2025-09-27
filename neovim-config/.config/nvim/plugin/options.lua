-- Enable project-local configuration
vim.o.exrc = true

-- Sync clipboard between OS and Neovim
vim.opt.clipboard:append({ "unnamedplus" })
vim.g.clipboard = "xclip"

vim.o.ignorecase = true
vim.o.smartcase = true

-- Indenting
vim.o.tabstop = 8
vim.o.softtabstop = 8
vim.o.shiftwidth = 8
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
vim.o.foldcolumn = "1"
vim.o.foldmethod = "marker"
vim.o.foldlevel = 0

-- Column opts
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

vim.o.cursorline = true
vim.o.cursorlineopt = "number"

vim.o.grepprg = "vimgrep.nu"

-- Terminal scrollback
vim.o.scrollback = 100000

vim.o.updatetime = 1000
vim.o.virtualedit = "block"
vim.o.winborder = "rounded"

if vim.fn.exepath("nu") ~= "" then
        vim.o.shell = vim.fn.exepath("nu")
        vim.o.shelltemp = false
        vim.o.shellredir = "o+e> %s"
        vim.o.shellcmdflag = "--no-config-file --no-newline --stdin -c"
        vim.o.shellpipe =
        "| complete | update stderr { ansi strip } | tee { get stderr | save --force --raw %s } | into record"
end
vim.keymap.set("ca", "nu", function()
        if vim.fn.getcmdtype() == ":" then
                local cmd = vim.fn.getcmdline()
                if cmd:match("^('<,'>)!nu")
                    or cmd:match("^%.!nu")
                    or cmd:match("^%.,%$!nu")
                    or cmd:match("^%.,%.%+%d+!nu")
                then
                        return "nu -c $in"
                else
                        return "nu"
                end
        end
end, { expr = true })

-- Display vs TTY
vim.o.list = true
vim.o.termguicolors = true
vim.opt.listchars = { nbsp = "␣", tab = "› ", trail = "•" }

if os.getenv("DISPLAY") == nil then
        vim.o.termguicolors = false
end

vim.cmd.colorscheme("tricky")

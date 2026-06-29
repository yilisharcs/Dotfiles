vim.loader.enable()

require("utils.snacks.bigfile")

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

if
        #vim.v.argf ~= 0
        and (string.match(vim.v.argf[1], "^/tmp/bash%-fc%.%w+$") or string.match(vim.v.argf[1], "^/tmp/%S+%.nu$"))
then
        vim.g.shell_editor = true
end

vim.g.netrw_banner = 0
vim.keymap.set("n", "-", "<CMD>Ex<CR>", { desc = "Fallback file explorer " })

vim.keymap.set("n", "<leader>h", "`H", { desc = "File mark `H" })
vim.keymap.set("n", "<leader>j", "`J", { desc = "File mark `J" })
vim.keymap.set("n", "<leader>k", "`K", { desc = "File mark `K" })
vim.keymap.set("n", "<leader>l", "`L", { desc = "File mark `L" })

vim.keymap.set("n", "<leader>p", ":= P()<LEFT>", { desc = "Printf util" })
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

vim.cmd("silent! aunmenu PopUp.How-to\\ disable\\ mouse")
vim.cmd("silent! aunmenu PopUp.-2-")

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
vim.o.shortmess = vim.o.shortmess .. "s"

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

vim.o.isfname = vim.o.isfname .. ",@-@"

vim.o.pumheight = math.floor(vim.o.lines * 0.25 + 0.5)
vim.o.completeopt = "noselect,menuone,popup,fuzzy"

-- <C-a> and <C-x> don't recognize signed numbers
vim.o.nrformats = vim.o.nrformats .. ",unsigned"

-- no more ~ on empty buffer space
vim.o.fillchars = "eob: "

vim.o.guicursor = "a:block,c-ci-i-r:blinkwait700-blinkoff700-blinkon700"
vim.o.smoothscroll = true

vim.o.diffopt = "algorithm:patience,hiddenoff," .. vim.o.diffopt

-- terminal scrollback
vim.o.scrollback = 100000

vim.o.updatetime = 1500
vim.o.virtualedit = "block"
vim.o.winborder = "rounded"
vim.o.winwidth = 15

-- display vs TTY
vim.o.list = true
vim.o.listchars = "nbsp:␣,tab:│ ,trail:•"
if os.getenv("DISPLAY") == nil then
        vim.o.termguicolors = false
else
        vim.o.termguicolors = true

        vim.o.title = true
        vim.o.titlestring = "%t%( [%M]%) (%{expand('%:p:~:h')}) - Nvim"
end

vim.o.background = "dark"
vim.cmd.colorscheme("silverwine")

vim.filetype.add({
        extension = {
                log = "log",
                xxd = "xxd",
        },
        pattern = {
                ["/nix/store/.*%-bash_profile"] = "bash",
                ["/nix/store/.*%-bashrc"] = "bash",
                ["/nix/store/.*%-profile"] = "bash",
                ["/nix/store/.*.Xresources"] = "xdefaults",
        },
})

-- PACKAGE MANAGER
vim.g.loaded_tutor_mode_plugin = 1

vim.pack.add({
        -- conform.nvim
        {
                src = "https://github.com/stevearc/conform.nvim",
        },
        -- diffview.nvim
        {
                src = "https://github.com/sindrets/diffview.nvim",
        },
        -- fzf-lua
        {
                src = "https://github.com/ibhagwan/fzf-lua",
        },
        -- [dev] hex.nvim (lazy: false)
        -- {
        --         src = "https://github.com/yilisharcs/hex.nvim",
        --         version = "undolevel"
        -- },
        -- hydra.nvim (lazy: false)
        {
                src = "https://github.com/nvimtools/hydra.nvim",
        },
        -- mini.nvim
        --      nvim-treesitter/nvim-treesitter
        {
                src = "https://github.com/nvim-mini/mini.nvim",
        },
        {
                src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
                version = "main",
        },
        -- nvim-treesitter
        {
                src = "https://github.com/nvim-treesitter/nvim-treesitter",
                version = "main",
                data = { build = "TSUpdate" },
        },
        {
                src = "https://github.com/HiPhish/rainbow-delimiters.nvim",
        },
        {
                src = "https://github.com/RRethy/nvim-treesitter-endwise",
        },
        -- octo.nvim
        --      ibhagwan/fzf-lua
        {
                src = "https://github.com/pwntester/octo.nvim",
        },
        -- toggleterm.nvim
        {
                src = "https://github.com/akinsho/toggleterm.nvim",
        },
        -- vim-sneak
        {
                src = "https://github.com/justinmk/vim-sneak",
        },
        {
                src = "https://github.com/tpope/vim-repeat",
        },
        -- vim-symlink
        {
                src = "https://github.com/aymericbeaumet/vim-symlink",
        },
        -- which-key.nvim (lazy: false)
        {
                src = "https://github.com/folke/which-key.nvim",
        },
        -- [dev] yazi.nvim
        --      ibhagwan/fzf-lua
        -- {
        --         src = "https://github.com/mikavilpas/yazi.nvim",
        -- },
        {
                src = "https://github.com/nvim-lua/plenary.nvim",
        },
}, { load = true })

-- TODO: test this
vim.api.nvim_create_autocmd("PackChanged", {
        callback = function(ev)
                local hook = ev.data.spec.data and ev.data.spec.data.build
                if hook then
                        vim.cmd(hook)
                end
        end,
})

vim.g.netrw_banner = 0          -- disable annoying banner
vim.g.netrw_altfile = 1         -- alternate file is not netrw
vim.g.netrw_list_hide = '\\./$' -- hide directory entries (pollutes numbered registers)

local opts = { remap = true, nowait = true, buffer = true }

vim.keymap.set('n', 'h', '<Plug>NetrwBrowseUpDir', opts)      -- go up directory
vim.keymap.set('n', 'l', '<Plug>NetrwLocalBrowseCheck', opts) -- open <cfile>
vim.keymap.set('n', 'i', '<Plug>NetrwOpenFile', opts)         -- new file
vim.keymap.set('n', 'I', '<Plug>NetrwMakeDir', opts)          -- new directory
vim.keymap.set('n', 'r', 'R', opts)                           -- rename
vim.keymap.set('n', 'q', '<CMD>e #<CR>', opts)                -- close netrw

-- Imitate lf keybinds as fallback
vim.keymap.set('n', 'g/', '<CMD>edit /<CR>', opts)
vim.keymap.set('n', 'gc', '<CMD>edit ~/.dotfiles<CR>', opts)
vim.keymap.set('n', 'gh', '<CMD>edit $HOME<CR>', opts)
vim.keymap.set('n', 'gn', '<CMD>edit ~/.config/nvim<CR>', opts)
vim.keymap.set('n', 'gz', '<CMD>edit ~/.local/share/nvim/lazy<CR>', opts)

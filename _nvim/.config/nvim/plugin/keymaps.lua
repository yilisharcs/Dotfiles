vim.keymap.set({ "n", "x" }, "<Space>", "<Nop>", { silent = true })

vim.keymap.set({ "n", "x" }, "<leader>K", "K", { desc = "Look up word under cursor" })
vim.keymap.set({ "x", "i" }, "<C-c>", "<ESC>", { silent = true })
vim.keymap.set("n", "<C-q>", "@@", { desc = "Repeat previous register" })
vim.keymap.set("o", "<C-a>", "<CMD>normal! ggVG<CR>", { desc = "Operate on entire buffer" })

vim.keymap.set({ "i", "c" }, "<C-b>", "<LEFT>")
vim.keymap.set({ "i", "c" }, "<C-f>", "<RIGHT>")
vim.keymap.set("c", "<C-y>", "<C-f>", { desc = "Open command-line window" })
vim.keymap.set(
        "c",
        "<C-k>",
        [[<c-\>e getcmdpos() == 1 ? "" : getcmdline()[:getcmdpos()-2]<CR>]],
        { desc = "Delete words after cursor" }
)
vim.keymap.set("c", "<C-a>", "<HOME>")
vim.keymap.set("c", "<C-x><C-a>", "<C-a>", { desc = "Insert matches on cursor pattern" })
vim.keymap.set("c", "<C-x><C-d>", "<C-d>", { desc = "List matches on cursor pattern" })
vim.keymap.set("c", "<C-d>", "<DEL>")
vim.keymap.set("i", "<C-d>", function()
        local _, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line_len = #vim.api.nvim_get_current_line()
        if col == line_len then
                return "<C-d>"
        else
                return "<DEL>"
        end
end, { expr = true })

vim.keymap.set("x", "<", "<gv", { desc = "Indent selection backwards" })
vim.keymap.set("x", ">", ">gv", { desc = "Indent selection forwards" })
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection downwards" })
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection upwards" })

vim.keymap.set("n", "X", '"zx"zp', { desc = "Transpose characters" })
vim.keymap.set({ "n", "x" }, "x", '"_x', { desc = "Delete without overwriting the clipboard register" })
vim.keymap.set("n", "C", '"_C', { desc = "Delete without overwriting the clipboard register" })
vim.keymap.set("n", "U", "<C-r>", { desc = "Intuitive redo" })
vim.keymap.set("n", "gf", "gF", { desc = "Go to file under cursor" })

vim.keymap.set("n", "<C-w>t", "<C-w>T", { desc = "Move buffer to new tab" })
vim.keymap.set("n", "<C-w>c", "<CMD>tabclose<CR>", { desc = "Close current tab" })
vim.keymap.set("n", "g-", "<CMD>-tabmove<CR>", { desc = "Move tab left" })
vim.keymap.set("n", "g+", "<CMD>+tabmove<CR>", { desc = "Move tab right" })

vim.keymap.set({ "n", "x" }, "'", "`", { desc = "Jump to mark $@" })
vim.keymap.set("n", "cgn", '*``"_cgn', { desc = "Match word and change ahead" })
vim.keymap.set("n", "cgN", '*``"_cgN', { desc = "Match word and change behind" })
vim.keymap.set("n", "dgn", '*``"_dgn', { desc = "Match word and delete ahead" })
vim.keymap.set("n", "dgN", '*``"_dgN', { desc = "Match word and delete behind" })

vim.keymap.set("n", "gw", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Replace word" })
vim.keymap.set("n", "gW", ":%s/\\<<C-r><C-a>\\>/<C-r><C-a>/gI<Left><Left><Left>", { desc = "Replace contiguous word" })
vim.keymap.set("x", "gw", '"zy:%s/\\<<C-r>z\\>/<C-r>z/gI<Left><Left><Left>', { desc = "Replace selection" })

vim.keymap.set("n", "dy", "<CMD>diffthis<CR>", { desc = "Enable diff mode for the current buffer" })
vim.keymap.set("n", "du", "<CMD>diffoff<CR>", { desc = "Disable diff mode for the current buffer" })
vim.keymap.set("x", "<C-o>", ":'<,'>diffget<CR>", { silent = true, desc = "Get diff from alt buffer" })
vim.keymap.set("x", "<C-p>", ":'<,'>diffput<CR>", { silent = true, desc = "Change diff of alt buffer" })

vim.keymap.set("n", "cu", function()
        if vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), "v:val.quickfix")) == 1 then
                return "<CMD>botright copen | wincmd p<CR>"
        else
                return "<CMD>cclose<CR>"
        end
end, { expr = true, desc = "Toggle quickfix list" })
vim.keymap.set("n", "co", function()
        if vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), "v:val.loclist")) == 1 then
                return "<CMD>botright lopen | wincmd p<CR>"
        else
                return "<CMD>lclose<CR>"
        end
end, { expr = true, desc = "Toggle location list" })

vim.keymap.set("n", "<C-k>", "<CMD>cpfile<CR>zz", { desc = "Quickfix previous file" })
vim.keymap.set("n", "<C-j>", "<CMD>cnfile<CR>zz", { desc = "Quickfix next file" })
vim.keymap.set("n", "<leader><C-p>", "<CMD>cabove<CR>", { desc = "Quickfix error above cursor" })
vim.keymap.set("n", "<leader><C-n>", "<CMD>cbelow<CR>", { desc = "Quickfix error below cursor" })
vim.keymap.set("n", "<M-p>", "<CMD>lprev<CR>zz", { desc = "Loclist previous error" })
vim.keymap.set("n", "<M-n>", "<CMD>lnext<CR>zz", { desc = "Loclist next error" })

vim.keymap.set("n", "gz", "jmzk<CMD>m .+1<CR>==`z", { desc = "Swap lines" })
vim.keymap.set("n", "gj", "i<CR><ESC>k$", { desc = "Split current line at the cursor position" })

vim.keymap.set("n", "gcap", "gcip", { remap = true })
vim.keymap.set("n", "gcA", 'oz<ESC>gcckJfz"_cl', { remap = true, desc = "Add comment on EoL" })
vim.keymap.set("n", "gc$", "i<CR><ESC>gcck$J", { remap = true, desc = "Comment out text until EoL" })
vim.keymap.set("n", "gcO", "Oz<ESC>gccfza<BS>", { remap = true, desc = "Add comment above current line" })
vim.keymap.set("n", "gco", "oz<ESC>gccfza<BS>", { remap = true, desc = "Add comment below current line" })

vim.keymap.set({ "n", "x", "o" }, "j", "(&wrap ? 'gj' : 'j')", { expr = true })
vim.keymap.set({ "n", "x", "o" }, "k", "(&wrap ? 'gk' : 'k')", { expr = true })
vim.keymap.set(
        { "n", "x" },
        "<C-d>",
        "(&wrap ? '<C-d>' : '<C-d>zz')",
        { expr = true, desc = "Center half-scroll down" }
)
vim.keymap.set({ "n", "x" }, "<C-u>", "(&wrap ? '<C-u>' : '<C-u>zz')", { expr = true, desc = "Center half-scroll up" })
vim.keymap.set(
        { "n", "x" },
        "<C-f>",
        "(&wrap ? '<C-f>' : '<C-f>zz')",
        { expr = true, desc = "Center full-scroll down" }
)
vim.keymap.set({ "n", "x" }, "<C-b>", "(&wrap ? '<C-b>' : '<C-b>zz')", { expr = true, desc = "Center full-scroll up" })
vim.keymap.set({ "n", "x" }, "<F8>", "<CMD>setlocal wrap! wrap?<CR>", { desc = "Toggle wrap" })

-- terminal emulators don't register C-4 as C-\
vim.keymap.set("t", "<C-4><C-n>", [[<C-\><C-n>]])
vim.keymap.set(
        "t",
        [[<C-\><C-r>]],
        [['<C-\><C-n>"'.nr2char(getchar()).'pi']],
        { expr = true, desc = "Paste from register $@" }
)

vim.keymap.set("n", "<F6>", function()
        if vim.b.toggle_comment_hl ~= nil then
                vim.b.toggle_comment_hl = nil
                vim.wo[0][0].winhighlight = ""
        else
                vim.b.toggle_comment_hl = true
                vim.wo[0][0].winhighlight = "Comment:CommentHide"
        end
end)

vim.keymap.set("n", "<F9>", "<CMD>Inspect<CR>", { desc = "Inspect element under cursor" })
vim.keymap.set("n", "<leader><F9>", "<CMD>InspectTree<CR>", { desc = "Inspect treesitter AST" })
vim.keymap.set("n", "<F10>", "<CMD>!chmod +x %<CR>", { desc = "Give executable permissions to the current file" })
vim.keymap.set(
        "n",
        "<leader><F10>",
        "<CMD>!chmod -x %<CR>",
        { desc = "Remove executable permissions of the current file" }
)

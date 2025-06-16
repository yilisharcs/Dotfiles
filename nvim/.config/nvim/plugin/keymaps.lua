vim.keymap.set({ "n", "x" }, "<SPACE>", "<Nop>", { silent = true })

vim.keymap.set({ "n", "x" }, "<leader>K", "K", { desc = "Look up word under cursor" })
vim.keymap.set({ "x", "i" }, "<C-c>", "<ESC>", { silent = true })
vim.keymap.set("n", "<C-q>", "@@", { desc = "Repeat previous register" })
vim.keymap.set("o", "<C-a>", "<CMD>normal! ggVG<CR>", { desc = "Operate on entire buffer" })

vim.keymap.set({ "i", "c" }, "<C-b>", "<LEFT>")
vim.keymap.set({ "i", "c" }, "<C-f>", "<RIGHT>")
vim.keymap.set("c", "<C-y>", "<C-f>", { desc = "Open command-line window" })
vim.keymap.set("c", "<C-k>", [[<c-\>e getcmdpos() == 1 ? "" : getcmdline()[:getcmdpos()-2]<CR>]],
  { desc = "Delete words after cursor" })
vim.keymap.set("c", "<C-a>", "<HOME>")
vim.keymap.set("c", "<C-x><C-a>", "<C-a>", { desc = "Insert matches on cursor pattern" })
vim.keymap.set({ "i", "c" }, "<C-d>", "<DEL>")
vim.keymap.set("c", "<C-x><C-d>", "<C-d>", { desc = "List matches on cursor pattern" })

vim.keymap.set("x", "<", "<gv", { desc = "Indent selection backwards" })
vim.keymap.set("x", ">", ">gv", { desc = "Indent selection forwards" })
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection downwards" })
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection upwards" })

vim.keymap.set("n", "X", '"zx"zp', { desc = "Transpose characters" })
vim.keymap.set({ "n", "x" }, "x", '"_x', { desc = "Delete without overwriting the clipboard register" })
vim.keymap.set("n", "C", '"_C', { desc = "Delete without overwriting the clipboard register" })
vim.keymap.set("n", "U", "<C-r>", { desc = "Intuitive redo" })
vim.keymap.set("n", "gf", "gF", { desc = "Go to file under cursor" })
vim.keymap.set("n", "<C-w>t", "<CMD>tab split<CR>", { desc = "Open buffer in new tab" })

vim.keymap.set({ "n", "x" }, "'", "`", { desc = "Jump to mark $@" })
vim.keymap.set("n", "cgn", '*``"_cgn', { desc = "Match word and change ahead" })
vim.keymap.set("n", "cgN", '*``"_cgN', { desc = "Match word and change behind" })
vim.keymap.set("n", "dgn", '*``"_dgn', { desc = "Match word and delete ahead" })
vim.keymap.set("n", "dgN", '*``"_dgN', { desc = "Match word and delete behind" })

vim.keymap.set("n", "gw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word under cursor" })
vim.keymap.set("n", "gW", [[:%s/\<<C-r><C-a>\>/<C-r><C-a>/gI<Left><Left><Left>]],
  { desc = "Replace contiguous text under cursor" })

vim.keymap.set("n", "dy", "<CMD>diffthis<CR>", { desc = "Enable diff mode for the current body" })
vim.keymap.set("x", "<C-o>", ":'<,'>diffget<CR>", { silent = true, desc = "Get diff from alt buffer" })
vim.keymap.set("x", "<C-p>", ":'<,'>diffput<CR>", { silent = true, desc = "Change diff of alt buffer" })

vim.keymap.set("n", "<leader>h", "`H", { desc = "File mark `H" })
vim.keymap.set("n", "<leader>j", "`J", { desc = "File mark `J" })
vim.keymap.set("n", "<leader>k", "`K", { desc = "File mark `K" })
vim.keymap.set("n", "<leader>l", "`L", { desc = "File mark `L" })

vim.keymap.set({ "n", "x", "i", "c", "t" }, "<M-h>", "<CMD>wincmd h<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<M-j>", "<CMD>wincmd j<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<M-k>", "<CMD>wincmd k<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<M-l>", "<CMD>wincmd l<CR>")

vim.keymap.set("n", "cu", function()
  return vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), "v:val.quickfix")) == 1
    and "<CMD>botright copen | wincmd p<CR>" or "<CMD>cclose<CR>"
end, { expr = true, desc = "Toggle quickfix list" })

vim.keymap.set("n", "<C-k>", "<CMD>cpfile<CR>zz", { desc = "Quickfix previous file" })
vim.keymap.set("n", "<C-j>", "<CMD>cnfile<CR>zz", { desc = "Quickfix next file" })
vim.keymap.set("n", "<C-p>", "<CMD>cprev<CR>zz", { desc = 'Quickfix previous error' })
vim.keymap.set("n", "<C-n>", "<CMD>cnext<CR>zz", { desc = "Quickfix next error" })
vim.keymap.set("n", "<leader><C-p>", "<CMD>cabove<CR>", { desc = "Quickfix error above cursor" })
vim.keymap.set("n", "<leader><C-n>", "<CMD>cbelow<CR>", { desc = "Quickfix error below cursor" })

vim.keymap.set("n", "gz", function()
    vim.ui.open("https://github.com/" .. vim.fn.expand("<cfile>"))
  end,
  { desc = "Open github repo under cursor" })
vim.keymap.set("x", "gz", function()
    vim.cmd('norm! "zy')
    vim.ui.open("https://github.com/" .. vim.fn.getreg("z"))
  end,
  { desc = "Open selection on github" })

vim.keymap.set("n", "Z", "jmzk<CMD>m .+1<CR>==`z", { desc = "Swap lines" })
vim.keymap.set("n", "gj", "i<CR><ESC>k$", { desc = "Split current line at the cursor position" })

vim.keymap.set("n", "gcap", "gcip", { remap = true })
vim.keymap.set("n", "gcA", 'oz<ESC>gcckJfz"_cl', { remap = true, desc = "Add comment on EoL" })
vim.keymap.set("n", "gc$", "i<CR><ESC>gcck$J", { remap = true, desc = "Comment out text until EoL" })
vim.keymap.set("n", "gcO", "Oz<ESC>gccfza<BS>", { remap = true, desc = "Add comment above current line" })
vim.keymap.set("n", "gco", "oz<ESC>gccfza<BS>", { remap = true, desc = "Add comment below current line" })

vim.keymap.set({ "n", "x", "o" }, "j", "(&wrap ? 'gj' : 'j')", { expr = true })
vim.keymap.set({ "n", "x", "o" }, "k", "(&wrap ? 'gk' : 'k')", { expr = true })
vim.keymap.set({ "n", "x" }, "<C-d>", "(&wrap ? '<C-d>' : '<C-d>zz')",
  { expr = true, desc = "Center half-scroll down" })
vim.keymap.set({ "n", "x" }, "<C-u>", "(&wrap ? '<C-u>' : '<C-u>zz')",
  { expr = true, desc = "Center half-scroll up" })
vim.keymap.set({ "n", "x" }, "<C-f>", "(&wrap ? '<C-f>' : '<C-f>zz')",
  { expr = true, desc = "Center full-scroll down" })
vim.keymap.set({ "n", "x" }, "<C-b>", "(&wrap ? '<C-b>' : '<C-b>zz')",
  { expr = true, desc = "Center full-scroll up" })
vim.keymap.set({ "n", "x" }, "<F8>", '<CMD>setlocal wrap! wrap?<CR>', { desc = "Toggle wrap" })

vim.keymap.set({ "n", "i", "c" }, "<C-S-V>", "<C-r>+", { desc = "Paste from clipboard" })
vim.keymap.set("t", "<C-S-V>", "<C-\\><C-n>pi", { desc = "Paste from clipboard" })
vim.keymap.set("t", "<C-4><C-r>", [['<C-\><C-n>"'.nr2char(getchar()).'pi']],
  { expr = true, desc = "Paste from register $@" })

-- Lots of terminal programs don't register C-4 as C-\
vim.keymap.set("t", "<C-4><C-n>", [[<C-\><C-n>]])

-- Tmux-like workflow
vim.keymap.set("n", "<C-SPACE><C-^>", "<CMD>wincmd g<TAB><CR>")
-- C-^ registers as <TAB> for reasons unknown
vim.keymap.set("t", "<C-SPACE><C-6>", "<CMD>wincmd g<TAB><CR>")
vim.keymap.set("t", "<C-SPACE><C-^>", "<CMD>wincmd g<TAB><CR>")
vim.keymap.set("n", "<C-SPACE><LEFT>", "<CMD>-tabmove<CR>")
vim.keymap.set("n", "<C-SPACE><RIGHT>", "<CMD>+tabmove<CR>")
vim.keymap.set({ "n", "t" }, "<C-SPACE>t", "<CMD>wincmd T<CR>", { desc = "Open buffer in new tab" })

vim.keymap.set({ "n", "x", "i", "c", "t" }, "<C-SPACE>c", "<CMD>tabnew | term nu<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<C-SPACE>x", "<CMD>tabclose<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<C-SPACE>h", "<CMD>tabnew | term btop<CR>")

vim.keymap.set({ "n", "x", "i", "c", "t" }, "<C-SPACE>1", "<CMD>1tabnext<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<C-SPACE>2", "<CMD>2tabnext<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<C-SPACE>3", "<CMD>3tabnext<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<C-SPACE>4", "<CMD>4tabnext<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<C-SPACE>5", "<CMD>5tabnext<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<C-SPACE>6", "<CMD>6tabnext<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<C-SPACE>7", "<CMD>7tabnext<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<C-SPACE>8", "<CMD>8tabnext<CR>")
vim.keymap.set({ "n", "x", "i", "c", "t" }, "<C-SPACE>9", "<CMD>9tabnext<CR>")

vim.keymap.set("n", "<F9>", "<CMD>Inspect<CR>", { desc = "Inspect element under cursor" })
vim.keymap.set("n", "<F10>", "<CMD>!chmod +x %<CR>",
  { desc = "Give executable permissions to the current file" })
vim.keymap.set("n", "<leader><F10>", "<CMD>!chmod -x %<CR>",
  { desc = "Remove executable permissions of the current file" })

function P(...)
  local args = {}
  for _, arg in ipairs({ ... }) do
    table.insert(args, vim.inspect(arg))
  end
  print(unpack(args))
  return ...
end

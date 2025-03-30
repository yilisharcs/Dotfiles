vim.keymap.set({ 'n', 'x' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set({ 'n', 'x' }, '<leader>K', 'K', { desc = ':help accomodates for LSP' })
vim.keymap.set('i', '<C-c>', "(col('.') > 1 ? '<ESC><Right>' : '<ESC>')", { silent = true, expr = true })
vim.keymap.set('n', '<C-b>', '@@', { desc = 'Repeat previous register' })
vim.keymap.set('o', '<C-a>', '<CMD>normal! ggVG<CR>', { desc = 'Operate on entire buffer' })

vim.keymap.set('t', [[<C-\><C-r>]], [['<C-\><C-n>"'.nr2char(getchar()).'pi']], { expr = true, desc = 'Terminal paste' })
vim.keymap.set('x', '<', '<gv', { desc = 'Indent sticky selection' })
vim.keymap.set('x', '>', '>gv', { desc = 'Indent sticky selection' })
vim.keymap.set('x', 'J', ":m '>+1<CR>gv=gv", { silent = true, desc = 'Move sticky selection' })
vim.keymap.set('x', 'K', ":m '<-2<CR>gv=gv", { silent = true, desc = 'Move sticky selection' })

vim.keymap.set({ 'n', 'x' }, 'x', '"_x', { desc = 'Delete without overwriting clipboard' })
vim.keymap.set('n', 'C', '"_C', { desc = 'Delete without overwriting clipboard' })
vim.keymap.set({ 'n', 'x' }, "'", '`', { desc = 'More ergonomic mark' })
vim.keymap.set('n', 'U', '<C-r>', { remap = true, desc = 'Intuitive redo' })

vim.keymap.set('n', '<C-w>H', '<C-w>H<C-w>=')
vim.keymap.set('n', '<C-w>J', '<C-w>J<C-w>=')
vim.keymap.set('n', '<C-w>K', '<C-w>K<C-w>=')
vim.keymap.set('n', '<C-w>L', '<C-w>L<C-w>=')

vim.keymap.set('n', '<C-w>t', '<CMD>tab split<CR>', { desc = 'Open buffer in new tab' })
vim.keymap.set('n', [[<C-\><C-w>t]], '<CMD>tab split<CR>', { desc = 'Open terminal in new tab' })
vim.keymap.set('n', 'cgn', '*``"_cgn', { desc = 'Change next <cword>' })
vim.keymap.set('n', 'cgN', '*``"_cgN', { desc = 'Change prev <cword>' })

vim.keymap.set('n', '-g', ':silent grep -F ""<Left>', { desc = 'Grep to quickfix list' })
vim.keymap.set('x', '-g', '"zy:silent grep -F "<C-r>z"<CR>', { desc = 'Grep selection' })
vim.keymap.set('n', '-G', ':" %:p:h<Home>silent grep -F "', { desc = 'Grep from $HOME dir' })
vim.keymap.set('x', '-G', '"zy:silent grep -F "<C-r>z" %:p:h<CR>', { desc = 'Grep from file dir' })
vim.keymap.set('n', '-w', ':silent grep -F "<C-r><C-w>"<CR>', { desc = 'Grep <cword>' })
vim.keymap.set('n', '-W', ':silent grep -F "<C-r><C-a>"<CR>', { desc = 'Grep <cWORD>' })
vim.keymap.set('n', '-h', ':helpgrep <C-r><C-w><CR>', { desc = 'Helpgrep <cword>' })
vim.keymap.set('n', '-H', ':helpgrep <C-r><C-a><CR>', { desc = 'Helpgrep <cWORD>' })
vim.keymap.set('x', '-h', '"zy:helpgrep <C-r>z<CR>', { desc = 'Helpgrep selection' })
vim.keymap.set('n', '-s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Replace <cword>' })
vim.keymap.set('n', '-S', [[:%s/\<<C-r><C-a>\>/<C-r><C-a>/gI<Left><Left><Left>]], { desc = 'Replace <cWORD>' })
vim.keymap.set('x', '-s', [["zy:%s/<C-r>z/<C-r>z/gI<Left><Left><Left>]], { desc = 'Replace selection' })

-- Readline-style
vim.keymap.set({ 'i', 'c' }, '<C-b>', '<Left>')
vim.keymap.set({ 'i', 'c' }, '<C-f>', '<Right>')
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('i', '<C-a>', '<C-o>^')
vim.keymap.set('i', '<C-e>', '<End>')
vim.keymap.set({ 'i', 'c' }, '<C-x><C-a>', '<C-a>')
vim.keymap.set('c', '<C-k>', [[<c-\>e getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos()-2]<CR>]],
  { desc = 'Delete text after cursor' })

vim.keymap.set({ 'i', 'c' }, '<C-d>', '<DEL>')
vim.keymap.set('c', '<C-y>', "(pumvisible() ? '<C-y>' : '<C-f>')", { expr = true, desc = 'Cmd history or confirm cmp' })

vim.keymap.set('n', 'dy', '<CMD>diffthis<CR>', { desc = 'Enable diff mode' })
vim.keymap.set('x', '<C-o>', ":'<,'>diffget<CR>", { silent = true, desc = 'Diff copy from alt buffer' })
vim.keymap.set('x', '<C-p>', ":'<,'>diffput<CR>", { silent = true, desc = 'Diff paste to alt buffer' })

vim.cmd([[
  function! List_Gmarks()
    marks ABCDEFGIMNOPQRSTUVWXYZ
    marks HJKL
    echo('`')
    try
      let s:mark = toupper(nr2char(getchar()))
    catch /^Vim:Interrupt$/
    endtry
    redraw
    silent! execute 'normal! `'..s:mark
  endfunction
]])
vim.keymap.set('n', "<leader>'", '<CMD>call List_Gmarks()<CR>', { desc = 'List global marks' })

vim.keymap.set('n', '<leader><leader>h', '`H')
vim.keymap.set('n', '<leader><leader>j', '`J')
vim.keymap.set('n', '<leader><leader>k', '`K')
vim.keymap.set('n', '<leader><leader>l', '`L')

vim.keymap.set('n', 'cu', function()
  return vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), 'v:val.quickfix')) == 1
      and '<CMD>botright copen | wincmd p<CR>' or '<CMD>silent! cclose<CR>'
end, { expr = true, desc = 'Toggle quickfix list' })

vim.keymap.set('n', '<C-j>', '<CMD>cpfile<CR>zz', { desc = 'Quickfix prev file' })
vim.keymap.set('n', '<C-k>', '<CMD>cnfile<CR>zz', { desc = 'Quickfix next file' })
vim.keymap.set('n', '<C-p>', '<CMD>cprev<CR>zz', { desc = 'Quickfix prev' })
vim.keymap.set('n', '<C-n>', '<CMD>cnext<CR>zz', { desc = 'Quickfix next' })
vim.keymap.set('n', '<leader><C-p>', '<CMD>cabove<CR>', { desc = 'Quickfix above cursor' })
vim.keymap.set('n', '<leader><C-n>', '<CMD>cbelow<CR>', { desc = 'Quickfix below cursor' })

vim.keymap.set('n', '<F8>', '<CMD>setlocal wrap! wrap? linebreak!<CR>')
vim.keymap.set({ 'n', 'x', 'o' }, 'j', "(&wrap ? 'gj' : 'j')", { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'k', "(&wrap ? 'gk' : 'k')", { expr = true })
vim.keymap.set('n', '<C-d>', "(&wrap ? '<C-d>' : '<C-d>zz')", { expr = true, desc = 'Centered scrolling' })
vim.keymap.set('n', '<C-u>', "(&wrap ? '<C-u>' : '<C-u>zz')", { expr = true, desc = 'Centered scrolling' })

vim.keymap.set('n', '<F10>', '<CMD>!chmod +x %<CR>', { desc = 'Give executable permissions' })
vim.keymap.set('n', '<leader><F10>', '<CMD>!chmod -x %<CR>', { desc = 'Remove executable permissions' })

vim.keymap.set('n', 'gz', '"zyi\':call jobstart("googler https://github.com/<C-r>z")<CR>')
vim.keymap.set('x', 'gz', '"zy:call jobstart("googler https://github.com/<C-r>z")<CR>')

vim.keymap.set('n', 'Z', 'jmzk<CMD>m .+1<CR>==`z', { desc = 'Swap lines' })
vim.keymap.set('n', 'gj', 'i<CR><ESC>k$', { desc = 'Split current line at the cursor position' })

-- teej enhanced inspect function
function P(...)
  local args = {}
  for _, arg in ipairs({ ... }) do
    table.insert(args, vim.inspect(arg))
  end
  print(unpack(args))
  return ...
end

vim.keymap.set('n', '<leader>P', ':lua P()<Left>', { desc = 'Print data structures' })

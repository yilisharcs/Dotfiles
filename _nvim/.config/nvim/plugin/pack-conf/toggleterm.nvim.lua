require("toggleterm").setup({
        shade_terminals = vim.o.background == "dark" and true or false,
        open_mapping = "<C-g>",
        float_opts = {
                border = "rounded",
                height = math.floor(vim.o.lines * 0.8),
        },
        size = function(term)
                if term.direction == "horizontal" then
                        return math.floor(vim.o.lines * 0.4)
                elseif term.direction == "vertical" then
                        return math.floor(vim.o.columns * 0.5)
                end
        end,
})

vim.keymap.set("n", "<leader>th", "<CMD>ToggleTerm direction=horizontal<CR>", { desc = "Toggle horizontal terminal" })
vim.keymap.set("n", "<leader>tv", "<CMD>ToggleTerm direction=vertical<CR>", { desc = "Toggle vertical terminal" })
vim.keymap.set("n", "<leader>tt", "<CMD>ToggleTerm direction=tab<CR>", { desc = "Toggle tab terminal" })

local Terminal = require("toggleterm.terminal").Terminal

vim.keymap.set("n", "<leader>i", function()
        Terminal:new({
                cmd = "jjui",
                direction = "tab",
                display_name = "JJUI",
                count = 2,
                dir = vim.fn.getcwd(),
        }):open()
end, { desc = "Toggle Jujutsu UI terminal" })

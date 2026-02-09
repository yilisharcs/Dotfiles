return {
        "https://github.com/akinsho/toggleterm.nvim",
        version = "*",
        event = "VeryLazy",
        keys = {
                {
                        "<C-Space>g",
                        "<CMD>ToggleTerm direction=vertical<CR>",
                        desc = "Toggleterm plain vertical",
                },
        },
        opts = {
                shade_terminals = vim.o.background == "dark" and true or false,
                open_mapping = "<C-g>",
                shell = vim.fn.executable("nu") == 1 and vim.fn.exepath("nu") or vim.o.shell,
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
        },
}

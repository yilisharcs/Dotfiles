return {
        "https://github.com/akinsho/toggleterm.nvim",
        version = "*",
        event = "VeryLazy",
        opts = {
                open_mapping = "<C-g>",
                shell = vim.fn.executable("nu") == 1 and vim.fn.exepath("nu")
                        or vim.o.shell,
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
        config = function(_, opts)
                require("toggleterm").setup(opts)

                local Terminal = require("toggleterm.terminal").Terminal

                local gemini = Terminal:new({
                        cmd = "tmux new -A -s gemini 'gemini'",
                        direction = "float",
                        display_name = "GEMINI",
                        count = 2,
                })
                vim.keymap.set("n", "<leader><F2>", function()
                        gemini:toggle()
                end)

                local gh_dash = Terminal:new({
                        cmd = "gh dash",
                        dir = "~",
                        direction = "float",
                        display_name = "GITHUB DASHBOARD",
                        count = 3,
                })
                vim.keymap.set("n", "<leader><F3>", function()
                        gh_dash:toggle()
                end)

                local btop = Terminal:new({
                        cmd = "btop",
                        direction = "float",
                        display_name = "RESOURCE MONITOR",
                        count = 4,
                })
                vim.keymap.set("n", "<leader><F4>", function()
                        btop:toggle()
                end)
        end,
}

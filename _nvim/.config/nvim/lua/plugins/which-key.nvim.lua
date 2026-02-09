return {
        "https://github.com/folke/which-key.nvim",
        lazy = false,
        keys = {
                {
                        "<leader>?",
                        function()
                                require("which-key").show({ global = false })
                        end,
                        desc = "List buffer-local keymaps",
                },
        },
        opts = {
                win = {
                        border = "solid",
                },
        },
}

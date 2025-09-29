return {
        "yilisharcs/wikibrowse.nvim",
        dev = true,
        lazy = false,
        cmd = "Wikibrowse",
        keys = {
                { "<leader>e", "<CMD>Wikibrowse pizza<CR>" },
        },
        init = function()
                vim.keymap.set("ca", "wiki", function()
                        if vim.fn.getcmdtype() == ":" then
                                local cmd = vim.fn.getcmdline()
                                if cmd:match("^wiki") then
                                        return "Wikibrowse"
                                else
                                        return "wiki"
                                end
                        end
                end, { expr = true })
        end,
        opts = true
}

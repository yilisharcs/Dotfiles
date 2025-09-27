return {
        "yilisharcs/wikibrowse.nvim",
        enabled = false,
        dev = true,
        lazy = false,
        cmd = "WikiBrowse",
        keys = {
                { "<leader>e", "<CMD>WikiBrowse pizza<CR>" },
        },
        init = function()
                vim.keymap.set("ca", "wiki", function()
                        if vim.fn.getcmdtype() == ":" then
                                local cmd = vim.fn.getcmdline()
                                if cmd:match("^wiki") then
                                        return "WikiBrowse"
                                else
                                        return "wiki"
                                end
                        end
                end, { expr = true })
        end,
        opts = true
}

return {
        "yilisharcs/wikibrowse.nvim",
        dev = true,
        config = function()
                vim.g.wikibrowse = {
                        -- lang = "pt"
                }

                vim.api.nvim_create_user_command("Reload", function()
                        vim.cmd("write")
                        vim.cmd("restart")
                end, {})
                vim.keymap.set("n", "<leader>e", "<CMD>Wikibrowse pizza<CR>")
                vim.keymap.set("n", "<leader>w", "<CMD>Reload<CR>")
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
        end
}

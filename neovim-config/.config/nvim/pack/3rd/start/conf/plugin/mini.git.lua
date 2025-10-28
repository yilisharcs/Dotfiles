local executable = "git"

require("mini.git").setup({
        job = {
                git_executable = executable,
        },
})

vim.keymap.set("ca", "git", function()
        if vim.fn.getcmdtype() == ":" then
                local cmd = vim.fn.getcmdline()
                if cmd:match("^git") then
                        return "Git"
                else
                        return "git"
                end
        end
end, { expr = true })
vim.keymap.set("ca", "jj", function()
        if vim.fn.getcmdtype() == ":" then
                local cmd = vim.fn.getcmdline()
                if cmd:match("^jj") then
                        return "Git"
                else
                        return "jj"
                end
        end
end, { expr = true })

if executable == "git" then
        vim.keymap.set(
                "n",
                "<leader>gd",
                "<CMD>diffthis<CR><CMD>vert Git show HEAD:%<CR><CMD>difft<CR><C-w>w",
                { desc = "Diff current file" }
        )

        vim.keymap.set(
                "n",
                "<leader>gb",
                "mzgg<CMD>vert Git blame -- %<CR><C-w>l<CMD>set cursorbind<CR><CMD>set scrollbind<CR>`z",
                { desc = "Git blame" }
        )

        local ns = vim.api.nvim_create_namespace("mini_git_blame")
        local group = vim.api.nvim_create_augroup("MiniGitBlame", { clear = true })
        vim.api.nvim_create_autocmd({ "FileType" }, {
                desc = "Format git blame",
                pattern = "git",
                group = group,
                callback = function()
                        local name = vim.api.nvim_buf_get_name(0)
                        if not name:match("^minigit://.*/git blame") then return end

                        local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
                        local match = line:find("[+-]%d%d%d%d")
                        vim.cmd.resize({ match + 5, mods = { vertical = true } })

                        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
                        local last_line = vim.api.nvim_buf_line_count(0) - 1
                        for lnum = 0, last_line do
                                vim.api.nvim_buf_set_extmark(0, ns, lnum, match + 4, {
                                        virt_text = { { ")", "Normal" } },
                                        virt_text_pos = "overlay",
                                })
                        end

                        vim.api.nvim_set_option_value("cursorbind", true, { scope = "local" })
                        vim.api.nvim_set_option_value("scrollbind", true, { scope = "local" })
                        vim.api.nvim_set_option_value("winfixwidth", true, { scope = "local" })
                        vim.api.nvim_set_option_value("winfixbuf", true, { scope = "local" })
                        vim.api.nvim_set_option_value("number", false, { scope = "local" })
                        vim.api.nvim_set_option_value("relativenumber", false, { scope = "local" })
                        vim.api.nvim_set_option_value("signcolumn", "no", { scope = "local" })
                        vim.api.nvim_set_option_value("foldcolumn", "0", { scope = "local" })
                        vim.api.nvim_set_option_value("statuscolumn", "", { scope = "local" })
                end,
        })
elseif executable == "jj" then
        -- Pending
end

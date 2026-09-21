if vim.g.shell_editor then
    return
end

require("mini.git").setup({
    job = { git_executable = "git" },
})
_G.MiniGit = MiniGit

local vcs_bin = MiniGit.config.job.git_executable

local group = vim.api.nvim_create_augroup("MyMiniGit", { clear = true })

if vcs_bin == "git" then
    require("utils.cabbrev")({
        ["Git"] = { "git" },
    })

    vim.keymap.set("n", "<leader>gd", function()
        vim.cmd.diffthis()
        vim.cmd(("vert Git show HEAD~%d:%%"):format(vim.v.count))
        vim.cmd.wincmd("w")
    end, { desc = "Diff current file" })
    vim.api.nvim_create_autocmd({ "FileType" }, {
        desc = "MiniGit diff buffers",
        group = group,
        callback = function()
            local name = vim.api.nvim_buf_get_name(0)
            if not name:match("^minigit://%d*/git show HEAD~") then
                return
            end

            local basename = vim.fs.basename(name)
            vim.api.nvim_buf_set_name(0, "minigit://" .. basename)
            vim.api.nvim_set_option_value("modifiable", false, { scope = "local" })
            vim.cmd.diffthis()
        end,
    })

    vim.keymap.set({ "n", "x" }, "<leader>gs", function()
        MiniGit.show_at_cursor()
    end, { desc = "Git show at cursor" })

    vim.keymap.set("n", "<leader>gD", function()
        MiniGit.show_diff_source({
            split = "tab",
            target = "both",
        })
        vim.cmd.diffthis()
        vim.cmd.wincmd("w")
        vim.cmd.diffthis()
        vim.cmd.wincmd("w")
    end, { desc = "Git diff source (before+after)" })

    vim.keymap.set(
        "n",
        "<leader>gb",
        "mzgg<CMD>vert Git blame -- %<CR><C-w>W<CMD>set cursorbind scrollbind nowrap nofoldenable<CR>`z",
        { desc = "View git blame" }
    )

    local ns = vim.api.nvim_create_namespace("mini_git_blame")
    vim.api.nvim_create_autocmd({ "FileType" }, {
        desc = "Format MiniGit blame buffer",
        pattern = "git",
        group = group,
        callback = function()
            local name = vim.api.nvim_buf_get_name(0)
            if not name:match("^minigit://.*/git blame") then
                return
            end

            local source_win = vim.fn.win_getid(vim.fn.winnr("#"))
            vim.w.minigit_leave = function()
                vim.wo[source_win].cursorbind = false
                vim.wo[source_win].scrollbind = false
            end

            local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)
            local match = line[1]:find("[+-]%d%d%d%d")
            vim.cmd.resize({ match + 5, mods = { vertical = true } })

            vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
            local last_line = vim.api.nvim_buf_line_count(0)
            for lnum = 0, last_line - 1 do
                vim.api.nvim_buf_set_extmark(0, ns, lnum, match + 4, {
                    virt_text = { { ")", "Normal" } },
                    virt_text_pos = "overlay",
                })
            end

            local opts = { scope = "local" }
            vim.api.nvim_set_option_value("modifiable", false, opts)
            vim.api.nvim_set_option_value("wrap", false, opts)
            vim.api.nvim_set_option_value("cursorbind", true, opts)
            vim.api.nvim_set_option_value("scrollbind", true, opts)
            vim.api.nvim_set_option_value("winfixwidth", true, opts)
            vim.api.nvim_set_option_value("winfixbuf", true, opts)
            vim.api.nvim_set_option_value("number", false, opts)
            vim.api.nvim_set_option_value("relativenumber", false, opts)
            vim.api.nvim_set_option_value("signcolumn", "no", opts)
            vim.api.nvim_set_option_value("foldcolumn", "0", opts)
            vim.api.nvim_set_option_value("foldenable", false, opts)
            vim.api.nvim_set_option_value("statuscolumn", "", opts)
        end,
    })

    vim.api.nvim_create_autocmd("BufWinLeave", {
        desc = "Execute MiniGit blame cleanup",
        group = group,
        callback = function()
            local leave = vim.w.minigit_leave
            if leave then
                leave()
                vim.w.minigit_leave = nil
            end
        end,
    })
elseif vcs_bin == "jj" then
    require("utils.cabbrev")({
        ["Git"] = { "jj" },
    })
    -- TODO
end

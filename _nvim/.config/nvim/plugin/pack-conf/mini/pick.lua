if vim.g.shell_editor then
    return
end

require("mini.extra").setup()
_G.MiniExtra = MiniExtra

require("mini.pick").setup({
    mappings = {
        caret_left = "<C-b>",
        caret_right = "<C-f>",
        choose_marked = "<C-q>",
        delete_char = "<C-h>",
        delete_char_right = "<C-d>",
        refine = "<C-y>",
        refine_marked = "<M-y>",
        scroll_down = "<C-j>",
        scroll_left = "<Left>",
        scroll_right = "<Right>",
        scroll_up = "<C-k>",
        toggle_info = "<F9>",
    },
    source = {
        show = function(buf_id, items, query)
            return MiniPick.default_show(buf_id, items, query, { show_icons = os.getenv("DISPLAY") })
        end,
    },
    window = {
        config = { width = vim.o.columns },
        prompt_prefix = "▶ ",
    },
})
_G.MiniPick = MiniPick

-- mini.pick pickers
vim.keymap.set("n", "<leader>fi", MiniPick.builtin.files, { desc = "List all files" })
vim.keymap.set("n", "<leader>fb", MiniPick.builtin.buffers, { desc = "Pick open buffers" })
vim.keymap.set("n", "<leader>fk", MiniPick.builtin.help, { desc = "Pick help tags" })
vim.keymap.set("n", "<leader>fg", MiniPick.builtin.grep_live, { desc = "Live grep" })

-- mini.extra pickers
vim.keymap.set("n", "<leader>fl", MiniExtra.pickers.git_files, { desc = "Pick git files" })
vim.keymap.set("n", "<leader>fc", MiniExtra.pickers.git_commits, { desc = "Pick commits" })
vim.keymap.set("n", "<leader>fh", MiniExtra.pickers.oldfiles, { desc = "Pick file history" })
vim.keymap.set("n", "<leader>fK", MiniExtra.pickers.keymaps, { desc = "List mappings" })
vim.keymap.set("n", "<leader>fm", function()
    MiniExtra.pickers.manpages({}, {
        source = {
            choose = function(item)
                local name, section = item:match("^(%S+)%s+%(([^)]+)%)")

                if name then
                    local uri = string.format("man://%s(%s)", name, section)
                    MiniPick.default_choose(uri)
                end
            end,
        },
    })
end, { desc = "Pick man pages" })
-- stylua: ignore start
vim.keymap.set("n", "<leader>fa", function() MiniExtra.pickers.marks({ scope = "global" }) end, { desc = "Global marks" })
vim.keymap.set("n", "<leader>fA", function() MiniExtra.pickers.marks({ scope = "buf" }) end, { desc = "Buffer marks" })
vim.keymap.set("n", "<C-r>", function() MiniExtra.pickers.history({ scope = ":" }) end, { desc = "Command history" })
-- stylua: ignore end

-- custom pickers
MiniPick.registry.args = function()
    return MiniPick.start({
        source = {
            items = vim.fn.argv(),
            name = "Arglist",
            choose = function(item)
                if item == nil then
                    return
                end
                vim.api.nvim_win_call(MiniPick.get_picker_state().windows.target, function()
                    vim.cmd.edit(vim.fn.fnameescape(item))
                end)
            end,
        },
    })
end
vim.keymap.set("n", "<C-h>", MiniPick.registry.args, { desc = "Open arglist" })

MiniPick.registry.git_files_changed = function()
    return MiniPick.builtin.cli(
        { command = { "git", "ls-files", "-m", "-o", "--exclude-standard" } },
        { source = { name = "Git files (modified+untracked)" } }
    )
end
vim.keymap.set("n", "<leader>fL", MiniPick.registry.git_files_changed, { desc = "Pick modified+untracked files" })

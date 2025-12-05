local icons_cond
if os.getenv("DISPLAY") == nil then
        icons_cond = false
else
        icons_cond = true
end

return {
        "https://github.com/ibhagwan/fzf-lua",
        keys = {
                {
                        "<leader>fi",
                        "<CMD>FzfLua files<CR>",
                        desc = "[FZF] List all files",
                },
                {
                        "<leader>fl",
                        "<CMD>FzfLua git_files<CR>",
                        desc = "[FZF] List tracked files",
                },
                {
                        "<leader>fh",
                        "<CMD>FzfLua oldfiles<CR>",
                        desc = "[FZF] File history",
                },
                {
                        "<leader>fb",
                        "<CMD>FzfLua buffers<CR>",
                        desc = "[FZF] Open buffers",
                },
                {
                        "<leader>fc",
                        "<CMD>FzfLua git_commits<CR>",
                        desc = "[FZF] List commits",
                },
                {
                        "<leader>fg",
                        "<CMD>FzfLua live_grep_native<CR>",
                        desc = "[FZF] Live grep",
                },
                {
                        "<leader>fk",
                        "<CMD>FzfLua helptags<CR>",
                        desc = "[FZF] Help tags",
                },
                {
                        "<leader>fK",
                        "<CMD>FzfLua keymaps<CR>",
                        desc = "[FZF] List mappings",
                },
                {
                        "<C-;>",
                        "<CMD>FzfLua marks<CR>",
                        desc = "[FZF] Get global marks",
                },
                {
                        "<C-h>",
                        "<CMD>FzfLua args<CR>",
                        desc = "[FZF] Open arglist",
                },
                {
                        "<C-r>",
                        "<CMD>FzfLua command_history<CR>",
                        mode = { "n", "x" },
                        desc = "[FZF] Search command history",
                },
                {
                        "<C-x><C-f>",
                        function()
                                require("fzf-lua").complete_path({
                                        cmd = table.concat({
                                                "fd",
                                                "--color=never",
                                                "--hidden",
                                                "--follow",
                                                "--no-ignore",
                                        }, " "),
                                })
                        end,
                        mode = "i",
                        desc = "[FZF] Complete Path",
                },
                {
                        "<leader>fs",
                        function()
                                local opts = {}
                                opts.winopts = { title = " Projects " }
                                opts.actions = {
                                        ["default"] = function(selected)
                                                vim.cmd("tabe " .. selected[1])
                                                vim.cmd("tcd " .. selected[1])
                                        end,
                                }
                                local dirs = {
                                        "~/Projects/github.com/yilisharcs/",
                                        "~/.config/nvim/pack/dev/opt/",
                                        "~/.local/share/nvim/lazy/",
                                        "~/.local/share/bob/nightly/share/nvim/runtime/",
                                        "~/",
                                }
                                require("fzf-lua").fzf_exec(
                                        table.concat({
                                                "fd",
                                                "--hidden",
                                                "--follow",
                                                "--type d",
                                                "--exact-depth 1",
                                                ". ",
                                        }, " ")
                                                .. table.concat(dirs, " "),
                                        opts
                                )
                        end,
                        desc = "[FZF] New project tab",
                },
        },
        init = function()
                require("fzf-lua").register_ui_select()
        end,
        opts = {
                "ivy",
                keymap = {
                        builtin = {
                                ["<C-k>"] = "preview-page-up",
                                ["<C-j>"] = "preview-page-down",
                                ["<F1>"] = "toggle-help",
                                ["<F2>"] = "toggle-fullscreen",
                                ["<F4>"] = "toggle-preview",
                        },
                        fzf = {
                                ["ctrl-q"] = "select-all+accept",
                                ["alt-a"] = "toggle-all",
                                ["alt-g"] = "last",
                                ["alt-G"] = "first",
                        },
                },
                fzf_colors = {
                        ["hl"] = { "fg", "Type", "bold" },
                        ["hl+"] = { "fg", "Type", "bold" },
                },
                command_history = {
                        fzf_colors = {
                                ["hl"] = { "fg", "Type", "bold" },
                                ["hl+"] = { "fg", "Type", "bold" },
                        },
                },
                winopts = {
                        treesitter = { enabled = false },
                        preview = {
                                winopts = {
                                        numberwidth = 4,
                                        statuscolumn = " %l%s",
                                },
                        },
                },
                hls = { buf_nr = "FzfLuaCustomMarks" },
                git = {
                        files = { file_icons = icons_cond },
                },
                files = {
                        file_icons = icons_cond,
                        fd_opts = table.concat({
                                "--color=never",
                                "--hidden",
                                "--no-ignore",
                                "--type f",
                                "--type l",
                        }, " "),
                },
                grep = {
                        rg_opts = table.concat({
                                "--color=always",
                                "--column",
                                "--line-number",
                                "--no-heading",
                                "--smart-case",
                                "--max-columns=4096",
                                "--hidden",
                                "-g=!.git",
                                "-e",
                        }, " "),
                },
                marks = {
                        sort = true,
                        marks = "[^%d%.\"'<>]",
                        fzf_opts = {
                                ["--cycle"] = true,
                                ["--tiebreak"] = "begin",
                        },
                },
                args = {
                        files_only = false,
                },
        },
}

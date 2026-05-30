local icons_cond = os.getenv("DISPLAY") ~= nil

-- NOTE: silly shim to increase startup time. i will never get
--       the hour i spent on profiling this back...
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(...)
        require("fzf-lua").register_ui_select()
        return vim.ui.select(...)
end

require("fzf-lua").setup({
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
                        "--no-ignore-vcs",
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
                        "-g=!.jj",
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
})

-- stylua: ignore start
vim.keymap.set(
        "n",
        "<leader>fi",
        "<CMD>FzfLua files<CR>",
        { desc = "[FZF] List all files" }
)
vim.keymap.set(
        "n",
        "<leader>fl",
        "<CMD>FzfLua git_files<CR>",
        { desc = "[FZF] List git files" }
)
vim.keymap.set(
        "n",
        "<leader>fL",
        function()
                require("fzf-lua").git_files({ cmd = "git ls-files -m -o --exclude-standard" })
        end,
        { desc = "[FZF] List modified files" }
)
vim.keymap.set(
        "n",
        "<leader>fh",
        "<CMD>FzfLua oldfiles<CR>",
        { desc = "[FZF] File history" }
)
vim.keymap.set(
        "n",
        "<leader>fb",
        "<CMD>FzfLua buffers<CR>",
        { desc = "[FZF] Open buffers" }
)
vim.keymap.set(
        "n",
        "<leader>fc",
        "<CMD>FzfLua git_commits<CR>",
        { desc = "[FZF] List commits" }
)
vim.keymap.set(
        "n",
        "<leader>fg",
        "<CMD>FzfLua live_grep_native<CR>",
        { desc = "[FZF] Live grep" }
)
vim.keymap.set(
        "n",
        "<leader>fk",
        "<CMD>FzfLua helptags<CR>",
        { desc = "[FZF] Help tags" }
)
vim.keymap.set(
        "n",
        "<leader>fK",
        "<CMD>FzfLua keymaps<CR>",
        { desc = "[FZF] List mappings" }
)
vim.keymap.set(
        "n",
        "<C-;>",
        "<CMD>FzfLua marks<CR>",
        { desc = "[FZF] Get global marks" }
)
vim.keymap.set(
        "n",
        "<C-h>",
        "<CMD>FzfLua args<CR>",
        { desc = "[FZF] Open arglist" }
)
vim.keymap.set(
        { "n", "x" },
        "<C-r>",
        "<CMD>FzfLua command_history<CR>",
        { desc = "[FZF] Search command history" }
)
vim.keymap.set(
        "i",
        "<C-x><C-f>",
        function()
                require("fzf-lua").complete_path({
                        cmd = table.concat({
                                "fd",
                                "--color=never",
                                "--hidden",
                                "--follow",
                                "--no-ignore-vcs",
                        }, " "),
                })
        end,
        { desc = "[FZF] Complete path" }
)
vim.keymap.set(
        "n",
        "<leader>fs",
        function()
                local function tabedit(selected)
                        local is_empty = false
                        local buf = vim.api.nvim_buf_get_name(0)
                        if
                                (buf == "" and not vim.bo.modified) -- empty buffer
                                or vim.fn.isdirectory(buf) == 1 -- empty *directory* buffer, completely different thing
                        then
                                is_empty = true
                        end

                        if is_empty then
                                vim.cmd("edit " .. selected[1])
                        else
                                vim.cmd("tabe " .. selected[1])
                        end

                        vim.cmd("tcd " .. selected[1])
                end

                local opts = {}
                opts.winopts = { title = " Projects " }
                opts.actions = {
                        ["default"] = tabedit,
                        ["ctrl-t"] = tabedit,
                        ["ctrl-s"] = function(selected)
                                vim.cmd("new")
                                vim.cmd("edit " .. selected[1])
                        end,
                        ["ctrl-v"] = function(selected)
                                vim.cmd("vnew")
                                vim.cmd("edit " .. selected[1])
                        end,
                }
                local dirs = {
                        "~/Projects/codeberg.org/yilisharcs/",
                        "~/Projects/codeberg.org/",
                        "~/Projects/github.com/yilisharcs/",
                        "~/Projects/github.com/",
                        "~/.local/share/nvim/site/pack/core/opt",
                        "~/Games/.plugin/Sonic-3-AIR/_core/Games/sonic3air_game/bonus/sonic3air_dev/scripts",
                        "~/Documents/",
                        "~/",
                }
                require("fzf-lua").fzf_exec(table.concat({
                        "fd",
                        "--hidden",
                        "--follow",
                        "--type d",
                        "--exact-depth 1",
                        ". ",
                }, " ") .. table.concat(dirs, " "), opts)
        end,
        { desc = "[FZF] New project tab" }
)

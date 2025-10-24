vim.pack.add({
        "https://github.com/ibhagwan/fzf-lua",
}, { load = true })

local icons_cond
if os.getenv("DISPLAY") == nil then
        icons_cond = false
else
        icons_cond = true
end
local fd_exclude = "--exclude={Trash,.git,.cache,state/undo,target}"

require("fzf-lua").setup({
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
        winopts = {
                height = 0.80,
                width = 0.90,
                row = 0.50,
                col = 0.55,
                backdrop = 100,
                border = "rounded",
                preview = { border = "rounded" },
                treesitter = { enabled = false },
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
                        fd_exclude,
                }, " "),
                winopts = {
                        preview = { layout = "vertical" },
                },
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
        helptags = {
                winopts = { height = 0.5 },
        },
        marks = {
                sort = true,
                marks = "[^%d%.\"'<>]",
                fzf_opts = {
                        ["--cycle"] = true,
                        ["--tiebreak"] = "begin",
                },
                winopts = {
                        preview = { layout = "vertical" },
                },
        },
})
require("fzf-lua").register_ui_select()

vim.keymap.set("n", "<leader>fi", "<CMD>FzfLua files<CR>", { desc = "[FZF] List all files" })
vim.keymap.set("n", "<leader>fl", "<CMD>FzfLua git_files<CR>", { desc = "[FZF] List tracked files" })
vim.keymap.set("n", "<leader>fh", "<CMD>FzfLua oldfiles<CR>", { desc = "[FZF] File history" })
vim.keymap.set("n", "<leader>fb", "<CMD>FzfLua buffers<CR>", { desc = "[FZF] Buffers" })
vim.keymap.set("n", "<leader>fc", "<CMD>FzfLua git_commits<CR>", { desc = "[FZF] Commits" })
vim.keymap.set("n", "<leader>fg", "<CMD>FzfLua live_grep_native<CR>", { desc = "[FZF] Live grep" })
vim.keymap.set("n", "<leader>fk", "<CMD>FzfLua helptags<CR>", { desc = "[FZF] Help tags" })
vim.keymap.set("n", "<leader>fK", "<CMD>FzfLua keymaps<CR>", { desc = "[FZF] List mappings" })
vim.keymap.set("n", "<C-h>", "<CMD>FzfLua marks<CR>", { desc = "[FZF] Get global marks" })
vim.keymap.set({ "n", "x" }, "<C-r>", "<CMD>FzfLua command_history<CR>", { desc = "[FZF] Search command history" })
vim.keymap.set("i", "<C-x><C-f>", function()
        require("fzf-lua").complete_path({
                cmd = table.concat({
                        "fd",
                        "--color=never",
                        "--hidden",
                        "--follow",
                        "--no-ignore",
                        fd_exclude,
                }, " "),
        })
end, { desc = "[FZF] Complete path" })
vim.keymap.set("n", "<leader>fs", function()
        local opts = {}
        opts.winopts = { title = " Projects " }
        opts.actions = {
                ["default"] = function(selected)
                        vim.cmd("tabnew " .. selected[1])
                        vim.cmd("tcd " .. selected[1])
                end,
        }
        local dirs = {
                "~/Projects/",
                "~/.config/nvim/pack/dev/opt/",
                -- "~/.local/share/nvim/lazy/",
                "~/.local/share/nvim/site/pack/core/opt/",
                "~/.local/share/bob/nightly/share/nvim/runtime/",
                "~/",
        }
        require("fzf-lua").fzf_exec(table.concat({
                "fd",
                "--hidden",
                "--follow",
                "--type d",
                "--no-ignore",
                "--exact-depth 1",
                ". ",
        }, " ") .. table.concat(dirs, " "), opts)
end, { desc = "[FZF] New project tab" })

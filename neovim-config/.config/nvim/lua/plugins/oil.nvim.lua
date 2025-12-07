local function follow_symlink()
        local e = require("oil").get_cursor_entry()
        if not e or not e.meta or not e.meta.link then return end

        local fo = {}
        fo.link = e.meta.link
        fo.type = e.meta.link_stat.type

        local ABSOLUTE = 0
        local RELATIVE = 1

        if fo.link:sub(1, 1) == "/" then
                fo.find = ABSOLUTE
                fo.path = fo.link
        else
                fo.find = RELATIVE
                local cwd = require("oil").get_current_dir()
                fo.path = vim.fs.normalize(vim.fs.joinpath(cwd, fo.link))
        end

        if fo.type == "file" then
                fo.path = vim.fs.dirname(fo.path)
                fo.seek_file = vim.fs.basename(fo.link)
        end

        require("oil").open(fo.path, {}, function()
                if not fo.seek_file then return end
                vim.fn.search(vim.fn.fnameescape(fo.seek_file))
        end)
end

return {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        lazy = false,
        keys = {
                { "-", "<CMD>Oil<CR>", desc = "Open file explorer" },
        },
        opts = {
                default_file_explorer = true,
                columns = {
                        "icon",
                        "permissions",
                        "size",
                        "mtime",
                },
                win_options = {
                        signcolumn = "yes:1",
                },
                delete_to_trash = true,
                skip_confirm_for_simple_edits = true,
                prompt_save_on_select_new_entry = true,
                lsp_file_methods = {
                        enabled = false,
                },
                constrain_cursor = "name",
                view_options = {
                        show_hidden = true,
                        is_always_hidden = function(name)
                                return name == ".."
                        end,
                },
                watch_for_changes = true,
                keymaps = {
                        ["<leader>fi"] = {
                                function()
                                        require("fzf-lua").files({
                                                cwd = require("oil").get_current_dir(),
                                        })
                                end,
                                mode = "n",
                                nowait = true,
                                desc = "Find files from current directory",
                        },
                        ["<leader>fl"] = {
                                function()
                                        require("fzf-lua").git_files({
                                                cwd = require("oil").get_current_dir(),
                                        })
                                end,
                                mode = "n",
                                nowait = true,
                                desc = "Find files from current directory",
                        },
                        ["<leader>;"] = {
                                "actions.open_cmdline",
                                opts = {
                                        shorten_path = true,
                                        modify = ":h",
                                },
                                desc = "Enter cmdline with the current directory as an argument",
                        },
                        ["_"] = {
                                "actions.open_cwd",
                                mode = "n",
                                nowait = true,
                        },
                        ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
                        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
                        ["ms"] = { "actions.change_sort", mode = "n" },
                        ["g/"] = { "<CMD>edit /<CR>", nowait = true },
                        ["ga"] = {
                                "<CMD>edit ~/Projects/github.com/yilisharcs/<CR>",
                                nowait = true,
                        },
                        ["gA"] = {
                                "<CMD>edit ~/Projects/github.com/sonicretro/skdisasm/<CR>",
                                nowait = true,
                        },
                        ["gb"] = { "<CMD>edit ~/notebook/<CR>", nowait = true },
                        ["gB"] = { "<CMD>edit ~/vault/<CR>", nowait = true },
                        ["gc"] = { "<CMD>edit ~/.config/<CR>", nowait = true },
                        ["gd"] = { "<CMD>edit ~/Downloads/<CR>", nowait = true },
                        ["ge"] = { "<CMD>edit ~/Documents/<CR>", nowait = true },
                        ["gh"] = { "<CMD>edit $HOME<CR>", nowait = true },
                        ["gf"] = { follow_symlink, nowait = true },
                        ["gi"] = { "<CMD>edit ~/Pictures/<CR>", nowait = true },
                        ["gl"] = { "<CMD>edit ~/Dotfiles/<CR>", nowait = true },
                        ["gm"] = { "<CMD>edit ~/Music/<CR>", nowait = true },
                        ["gn"] = { "<CMD>edit ~/.config/nvim/<CR>", nowait = true },
                        ["go"] = { "<CMD>edit ~/opt/<CR>", nowait = true },
                        ["gp"] = { "<CMD>edit ~/Projects/<CR>", nowait = true },
                        ["gr"] = { "<CMD>edit ~/.cargo/registry/src/<CR>", nowait = true },
                        ["gs"] = { "<CMD>edit ~/.local/bin/<CR>", nowait = true },
                        ["gu"] = { "<CMD>edit ~/Library/<CR>", nowait = true },
                        ["gv"] = { "<CMD>edit ~/Videos/<CR>", nowait = true },
                        ["gw"] = { "<CMD>edit ~/.wine/drive_c/<CR>", nowait = true },
                        ["gy"] = { "<CMD>edit ~/Games/<CR>", nowait = true },
                        ["gz"] = { "<CMD>edit ~/.local/share/nvim/lazy/<CR>", nowait = true },
                },
        },
}

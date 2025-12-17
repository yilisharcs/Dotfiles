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
                        case_insensitive = true,
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
                        ["gf"] = {
                                follow_symlink,
                                nowait = true,
                                desc = "Follow symlink",
                        },
                        ["g/"] = {
                                "<CMD>edit /<CR>",
                                nowait = true,
                                desc = "Go to root directory",
                        },
                        ["ga"] = {
                                "<CMD>edit ~/Projects/github.com/yilisharcs/<CR>",
                                nowait = true,
                                desc = "Go to ~/Projects/github.com/yilisharcs",
                        },
                        ["gA"] = {
                                "<CMD>edit ~/Projects/github.com/sonicretro/skdisasm/<CR>",
                                nowait = true,
                                desc = "Go to S3K Disassembly",
                        },
                        ["gb"] = {
                                "<CMD>edit ~/notebook/<CR>",
                                nowait = true,
                                desc = "Go to ~/notebook",
                        },
                        ["gB"] = {
                                "<CMD>edit ~/vault/<CR>",
                                nowait = true,
                                desc = "Go to ~/vault",
                        },
                        ["gc"] = {
                                "<CMD>edit ~/.config/<CR>",
                                nowait = true,
                                desc = "Go to ~/.config",
                        },
                        ["gd"] = {
                                "<CMD>edit ~/Downloads/<CR>",
                                nowait = true,
                                desc = "Go to ~/Downloads",
                        },
                        ["ge"] = {
                                "<CMD>edit ~/Documents/<CR>",
                                nowait = true,
                                desc = "Go to ~/Documents",
                        },
                        ["gh"] = {
                                "<CMD>edit $HOME<CR>",
                                nowait = true,
                                desc = "Go to $HOME",
                        },
                        ["gi"] = {
                                "<CMD>edit ~/Pictures/<CR>",
                                nowait = true,
                                desc = "Go to ~/Pictures",
                        },
                        ["gl"] = {
                                "<CMD>edit ~/Dotfiles/<CR>",
                                nowait = true,
                                desc = "Go to ~/Dotfiles",
                        },
                        ["gm"] = {
                                "<CMD>edit ~/Music/<CR>",
                                nowait = true,
                                desc = "Go to ~/Music",
                        },
                        ["gn"] = {
                                "<CMD>edit ~/.config/nvim/<CR>",
                                nowait = true,
                                desc = "Go to neovim config",
                        },
                        ["go"] = {
                                "<CMD>edit ~/opt/<CR>",
                                nowait = true,
                                desc = "Go to private /opt",
                        },
                        ["gp"] = {
                                "<CMD>edit ~/Projects/<CR>",
                                nowait = true,
                                desc = "Go to ~/Projects",
                        },
                        ["gr"] = {
                                "<CMD>edit ~/.cargo/registry/src/<CR>",
                                nowait = true,
                                desc = "Go to cargo registry",
                        },
                        ["gs"] = {
                                "<CMD>edit ~/.local/bin/<CR>",
                                nowait = true,
                                desc = "Go to private /bin",
                        },
                        ["gu"] = {
                                "<CMD>edit ~/Library/<CR>",
                                nowait = true,
                                desc = "Go to ~/Library",
                        },
                        ["gv"] = {
                                "<CMD>edit ~/Videos/<CR>",
                                nowait = true,
                                desc = "Go to ~/Videos",
                        },
                        ["gw"] = {
                                "<CMD>edit ~/.wine/drive_c/<CR>",
                                nowait = true,
                                desc = "Go to Wine C:",
                        },
                        ["gy"] = {
                                "<CMD>edit ~/Games/<CR>",
                                nowait = true,
                                desc = "Go to ~/Games",
                        },
                        ["gz"] = {
                                "<CMD>edit ~/.local/share/nvim/lazy/<CR>",
                                nowait = true,
                                desc = "Go to lazydir",
                        },
                        ["gZ"] = {
                                "<CMD>edit ~/.local/state/nvim/<CR>",
                                nowait = true,
                                desc = "Go to ~/.local/state/nvim",
                        },
                },
        },
}

local function create_symlink(relative)
        local source = vim.fn.getreg(vim.v.register)
        if source:sub(1, 1) ~= "/" then
                vim.notify(
                        "Not an absolute path: " .. (#source == 0 and "'(empty string)'" or source),
                        vim.log.levels.WARN
                )
                return
        end

        local oil_dir = require("oil").get_current_dir()

        -- `vim.fs.basename` returns an empty string for paths
        -- with a trailing slash aka directories; chop it off
        local abs_source = source:gsub("/$", "")
        local name = vim.fs.basename(abs_source)

        local target = abs_source
        if relative then
                -- split paths
                local from_parts = vim.split(oil_dir:gsub("/$", ""):sub(2), "/")
                local to_parts = vim.split(abs_source:gsub("/$", ""):sub(2), "/")

                -- find where the paths diverge
                local common = 0
                for i = 1, math.min(#from_parts, #to_parts) do
                        if from_parts[i] == to_parts[i] then
                                common = i
                        else
                                break
                        end
                end

                -- number of ../ needed to reach common ancestor
                local ups = #from_parts - common
                -- remaining path components to reach target
                local downs = { unpack(to_parts, common + 1) }
                -- build relative path
                target = string.rep("../", ups) .. table.concat(downs, "/")
        end

        -- deduplicate
        local link_name = name
        local i = 1
        while vim.uv.fs_stat(oil_dir .. link_name) do
                link_name = name .. "_" .. i
                i = i + 1
        end

        local entry = link_name .. " -> " .. target
        local lines = vim.api.nvim_buf_get_lines(0, -2, -1, false)
        table.insert(lines, entry)
        vim.api.nvim_buf_set_lines(0, -2, -1, false, lines)
end

local function goto_dir(path, desc)
        return { "<CMD>edit " .. path .. "<CR>", nowait = true, desc = desc or ("Go to " .. path) }
end

require("oil").setup({
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
        constrain_cursor = "name",
        watch_for_changes = true,
        view_options = {
                show_hidden = true,
                is_always_hidden = function(name)
                        return name == ".."
                end,
                case_insensitive = true,
        },
        keymaps = {
                ["<leader>;"] = {
                        function()
                                local dir = vim.fn.fnamemodify(require("oil").get_current_dir(), ":~")
                                vim.api.nvim_feedkeys(":MXCompile cd " .. dir .. " && ", "n", false)
                        end,
                        desc = "Open MXCompile with the current directory as an argument",
                },
                ["_"] = {
                        "actions.open_cwd",
                        mode = "n",
                        nowait = true,
                },
                ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
                -- ["<C-v>"] = { "actions.select", opts = { vertical = true } },
                ["ms"] = { "actions.change_sort", mode = "n" },
                -- fzf
                ["<leader>fi"] = {
                        function()
                                require("fzf-lua").files({
                                        cwd = require("oil").get_current_dir(),
                                })
                        end,
                        mode = "n",
                        nowait = true,
                        desc = "List all files from current directory",
                },
                ["<leader>fl"] = {
                        function()
                                require("fzf-lua").git_files({
                                        cwd = require("oil").get_current_dir(),
                                })
                        end,
                        mode = "n",
                        nowait = true,
                        desc = "List tracked files from current directory",
                },
                -- symlink
                ["<leader>y"] = {
                        "actions.yank_entry",
                        mode = "n",
                        nowait = true,
                },
                ["<leader>p"] = {
                        function()
                                create_symlink(false)
                        end,
                        mode = "n",
                        nowait = true,
                        desc = "Create absolute symlink from yanked path",
                },
                ["<leader>P"] = {
                        function()
                                create_symlink(true)
                        end,
                        mode = "n",
                        nowait = true,
                        desc = "Create relative symlink from yanked path",
                },
                -- goto
                ["gf"] = {
                        function()
                                local oil = require("oil")

                                local e = oil.get_cursor_entry()
                                if not (e and e.meta and e.meta.link) then
                                        return
                                end

                                local fo = {}
                                fo.link = e.meta.link
                                fo.type = e.meta.link_stat.type

                                local is_absolute = fo.link:sub(1, 1) == "/"
                                if is_absolute then
                                        fo.path = fo.link
                                else
                                        local cwd = oil.get_current_dir()
                                        fo.path = vim.fs.normalize(vim.fs.joinpath(cwd, fo.link))
                                end

                                if fo.type == "file" then
                                        fo.path = vim.fs.dirname(fo.path)
                                        fo.seek_file = vim.fs.basename(fo.link)
                                end

                                oil.open(fo.path, {}, function()
                                        if not fo.seek_file then
                                                return
                                        end
                                        vim.fn.search(vim.fn.fnameescape(fo.seek_file))
                                end)
                        end,
                        nowait = true,
                        desc = "Follow symlink under cursor",
                },
                ["g/"] = goto_dir("/"),
                ["gh"] = goto_dir("~/"),
                ["ga"] = goto_dir("~/Projects/github.com/yilisharcs/"),
                ["gb"] = goto_dir("~/Shared/notebook/"),
                -- TODO: delete this
                ["gB"] = goto_dir("~/Shared/notebook/vault/"),
                ["gc"] = goto_dir("~/.config/"),
                ["gd"] = goto_dir("~/Downloads/"),
                ["ge"] = goto_dir("~/Documents/"),
                ["gE"] = goto_dir("~/Documents/Archivum/"),
                ["gi"] = goto_dir("~/Pictures/"),
                ---- FIXME: lags on large directories
                -- ["gk"] = goto_dir("/nix/store/"),
                ["gl"] = goto_dir("~/Dotfiles/"),
                ["gm"] = goto_dir("~/Music/"),
                ["gn"] = goto_dir("~/.config/nvim/", "Go to nvim config"),
                ["go"] = goto_dir("~/opt/"),
                ["gp"] = goto_dir("~/Projects/"),
                ["gs"] = goto_dir("~/Projects/github.com/sonicretro/skdisasm/"),
                ["gu"] = goto_dir("~/Library/"),
                ["gv"] = goto_dir("~/Videos/"),
                ["gw"] = goto_dir("~/.wine/drive_c/", "Go to Wine C: drive"),
                ["gy"] = goto_dir("~/Games/.plugin/"),
                ["gz"] = goto_dir("~/.local/share/nvim/site/pack/core/opt/"),
                ["gZ"] = goto_dir("~/.local/state/nvim/"),
        },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>-", "<CMD>Oil .<CR>", { desc = "Open current working directory" })

package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
end

-- mini.align {{{
require("mini.align").setup({})
vim.keymap.set({ "n", "x" }, "g<leader>a", "ga", { desc = "Print ASCII value of character under cursor" })
-- }}}

-- mini.operators {{{
require("mini.operators").setup({
        evaluate = {
                prefix = "g=",
        },
        exchange = {
                prefix = "cx",
                reindent_linewise = true,
        },
        multiply = {
                prefix = "gm",
        },
        replace = {
                prefix = "cs",
                reindent_linewise = true,
        },
        sort = {
                prefix = "_s",
        },
})
require("mini.operators").make_mappings("exchange", {
        textobject = "cx",
        line = "cxx",
        selection = "X",
})
vim.keymap.set("x", "cl", "c") -- replacement for raw c, clobbered by the above

vim.keymap.set("n", "gyy", "mzgmmkgcc`zj", { remap = true, desc = "Duplicate and comment" })
vim.keymap.set("x", "gy", "gmmzgvgc`z", { remap = true, desc = "Duplicate and comment selection" })

vim.keymap.set("n", "csgn", "*``<CMD>lua MiniOperators.replace()<CR>g@gn", { desc = "Match word and replace ahead" })
vim.keymap.set("n", "csgN", "*``<CMD>lua MiniOperators.replace()<CR>g@gN", { desc = "Match word and replace behind" })
-- }}}

-- mini.pairs {{{
require("mini.pairs").setup({
        mappings = {
                ["("] = {},
                [")"] = {},
                ["["] = {},
                ["]"] = {},
                ["{"] = {},
                ['"'] = {},
                ["'"] = {},
                ["`"] = false,
        },
})

vim.keymap.set("i", "<C-h>", "v:lua.MiniPairs.bs()", { expr = true, replace_keycodes = false })
vim.keymap.set("i", "<C-w>", 'v:lua.MiniPairs.bs("\23")', { expr = true, replace_keycodes = false })
vim.keymap.set("i", "<C-u>", 'v:lua.MiniPairs.bs("\21")', { expr = true, replace_keycodes = false })
-- }}}

-- mini.splitjoin {{{
require("mini.splitjoin").setup({
        mappings = {
                toggle = "gJ",
        },
})
-- }}}

-- mini.surround {{{
require("mini.surround").setup({
        mappings = {
                add = "ys",
                delete = "yd",
                replace = "yc",
                find = "",
                find_left = "",
                highlight = "",
                update_n_lines = "",
        },
        respect_selection_type = true,
        search_method = "cover_or_next",
        custom_surroundings = {
                ["q"] = { -- quote
                        output = { left = '"', right = '"' },
                },
                ["B"] = { -- bold
                        input = { "%*%*().-()%*%*" },
                        output = { left = "**", right = "**" },
                },
                ["G"] = { -- code block
                        input = { "%```().-()%```" },
                        output = {
                                left = "```",
                                right = "\n```",
                        },
                },
        },
})

vim.keymap.del("x", "ys")
vim.keymap.set("x", "Y", ":<C-u>lua MiniSurround.add('visual')<CR>", { silent = true })
vim.keymap.set("n", "yS", "ys$", { remap = true })
vim.keymap.set("n", "yss", "ys_", { remap = true })
-- }}}

if vim.g.shell_editor then
        return
end

-- mini.ai {{{
require("mini.ai").setup({
        custom_textobjects = {
                a = require("mini.ai").gen_spec.treesitter({
                        a = "@parameter.outer",
                        i = "@parameter.inner",
                }, {}),
                c = require("mini.ai").gen_spec.treesitter({
                        a = "@call.outer",
                        i = "@call.inner",
                }, {}),
                f = require("mini.ai").gen_spec.treesitter({
                        a = "@function.outer",
                        i = "@function.inner",
                }, {}),
                g = require("mini.ai").gen_spec.treesitter({
                        a = {
                                "@conditional.outer",
                                "@loop.outer",
                        },
                        i = {
                                "@conditional.inner",
                                "@loop.inner",
                        },
                }, {}),
                -- code blocks
                G = { "```%S*\n?().-()\n?```" },
                -- em-dashed <FOO BAR>
                h = { "— ().-() —" },
                -- tagged
                ["<"] = { "<().-()>" },
        },
})
-- }}}

-- mini.bufremove {{{
require("mini.bufremove").setup({})
_G.MiniBufremove = MiniBufremove

vim.keymap.set("n", "<M-q>", function()
        if vim.bo.filetype == "help" then
                vim.cmd.bdelete()
        else
                MiniBufremove.delete()
        end
end, { desc = "Delete buffer" })
-- }}}

-- mini.clue {{{
require("mini.clue").setup({
        triggers = {
                { mode = { "n", "x" }, keys = "<Leader>" },
                { mode = "i", keys = "<C-x>" },
                { mode = { "n", "x" }, keys = "g" },
                { mode = { "n", "x" }, keys = "'" },
                { mode = { "n", "x" }, keys = "`" },
                { mode = { "n", "x" }, keys = '"' },
                { mode = { "i", "c" }, keys = "<C-r>" },
                { mode = "n", keys = "[" },
                { mode = "n", keys = "]" },
                { mode = "n", keys = "<C-w>" },
                { mode = { "n", "x" }, keys = "z" },
        },
        clues = {
                require("mini.clue").gen_clues.builtin_completion(),
                require("mini.clue").gen_clues.g(),
                require("mini.clue").gen_clues.marks(),
                require("mini.clue").gen_clues.registers(),
                require("mini.clue").gen_clues.square_brackets(),
                require("mini.clue").gen_clues.windows({
                        submode_resize = true,
                        submode_move = true,
                }),
                require("mini.clue").gen_clues.z(),
                { mode = "n", keys = "zh", postkeys = "z", desc = "Scroll right" },
                { mode = "n", keys = "zl", postkeys = "z", desc = "Scroll left" },
                { mode = "n", keys = "zH", postkeys = "z", desc = "Scroll right half screen" },
                { mode = "n", keys = "zL", postkeys = "z", desc = "Scroll left half screen" },
        },
        window = {
                delay = 500,
        },
})
-- }}}

-- mini.diff {{{
require("mini.diff").setup({
        view = {
                style = "sign",
                signs = {
                        add = "┃",
                        change = "┃",
                        delete = "┃",
                },
        },
})

vim.keymap.set("n", "<leader>gh", "<CMD>lua MiniDiff.toggle_overlay()<CR>", { desc = "[Git] Diff overlay" })
-- }}}

-- mini.git {{{
require("mini.git").setup({
        job = { git_executable = "git" },
})

---@diagnostic disable-next-line: undefined-global
local vcs_bin = MiniGit.config.job.git_executable

local group = vim.api.nvim_create_augroup("MyMiniGit", { clear = true })

if vcs_bin == "git" then
        require("utils.cabbrev")({
                ["Git"] = { "git" },
        })

        vim.keymap.set("n", "<leader>gd", function()
                vim.cmd.difft()
                                -- stylua: ignore
                                vim.cmd(("vert Git show HEAD~%d:%%"):format(vim.v.count))
                vim.cmd.wincmd("w")
        end, { desc = "Diff current file" })
        vim.api.nvim_create_autocmd({ "FileType" }, {
                desc = "MiniGit diff buffers",
                group = group,
                -- stylua: ignore
                callback = function()
                        local name = vim.api.nvim_buf_get_name(0)
                        if not name:match("^minigit://.*/git show HEAD~") then return end
                        local basename = vim.fs.basename(name)
                        vim.api.nvim_buf_set_name(0, "minigit://" .. basename)
                        vim.api.nvim_set_option_value("modifiable", false, { scope = "local" })
                        vim.cmd.diffthis()
                end,
        })

        vim.keymap.set(
                "n",
                "<leader>gb",
                "mzgg<CMD>vert Git blame -- %<CR><C-w>W<CMD>set cursorbind scrollbind<CR>`z",
                { desc = "Git blame" }
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
elseif vcs_bin == "jj" then
        require("utils.cabbrev")({
                ["Git"] = { "jj" },
        })
        -- pending
end
-- }}}

-- mini.hipatterns {{{
require("mini.hipatterns").setup({
        highlighters = {
                hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
                fixme = {
                        pattern = "%f[%w]()FIXME()%f[%W]",
                        group = "MiniHipatternsFixme",
                },
                hack = {
                        pattern = "%f[%w]()HACK()%f[%W]",
                        group = "MiniHipatternsHack",
                },
                todo = {
                        pattern = "%f[%w]()TODO()%f[%W]",
                        group = "MiniHipatternsTodo",
                },
                note = {
                        pattern = "%f[%w]()NOTE()%f[%W]",
                        group = "MiniHipatternsNote",
                },
                task = {
                        pattern = "TASK%(%d+%-%d+%.%w+%)",
                        group = "MiniHipatternsTodo",
                },
        },
})
-- }}}

-- mini.icons {{{
require("mini.icons").setup({
        filetype = {
                nu = { hl = "MiniIconsGreen" },
                c = { glyph = "" },
        },
        extension = {
                lemon = { glyph = "", hl = "MiniIconsYellow" },
        },
        file = {
                ["init.lua"] = { glyph = "󰢱" },
        },
})
-- }}}

-- mini.misc {{{
require("mini.misc").setup_auto_root({ ".git", ".jj" })
require("mini.misc").setup_restore_cursor({ center = false })
-- }}}

-- mini.notify {{{
require("mini.notify").setup({
        window = {
                max_width_share = vim.o.columns * 0.27 + 0.5,
                winblend = os.getenv("DISPLAY") and 2 or 0,
        },
})
_G.MiniNotify = MiniNotify

vim.keymap.set("n", "<leader>n", function()
        MiniNotify.show_history()
end, { desc = "Notification history" })
-- }}}

-- mini.sessions {{{
require("mini.sessions").setup({
        autoread = false,
        file = "",
        force = {
                read = false,
                write = true,
                delete = true,
        },
})

-- Save current session (or create one named after the directory)
vim.keymap.set("n", "<leader>ds", function()
        local name = vim.v.this_session ~= "" and vim.fs.basename(vim.v.this_session)
                or (vim.fs.basename(vim.uv.cwd()) .. ".vim")
        require("mini.sessions").write(name)
end, { desc = "Save current session" })
vim.keymap.set("n", "<leader>dl", function()
        require("mini.sessions").select()
end, { desc = "List sessions" })
vim.keymap.set("n", "<leader>dd", function()
        require("mini.sessions").select("delete")
end, { desc = "Delete session" })
vim.keymap.set("n", "<leader>dr", function()
        require("mini.sessions").restart()
end, { desc = "Restart with session" })
-- }}}

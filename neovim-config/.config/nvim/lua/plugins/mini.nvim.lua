return {
        "https://github.com/nvim-mini/mini.nvim",
        version = false,
        dependencies = {
                {
                        "https://github.com/nvim-treesitter/nvim-treesitter",
                        branch = "main",
                },
                {
                        "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
                        branch = "main",
                },
        },
        specs = {
                {
                        "https://github.com/nvim-tree/nvim-web-devicons",
                        enabled = false,
                        optional = true,
                },
        },
        init = function()
                package.preload["nvim-web-devicons"] = function()
                        require("mini.icons").mock_nvim_web_devicons()
                        return package.loaded["nvim-web-devicons"]
                end
        end,
        config = function()
                -- mini.ai {{{
                if not vim.g.shell_editor then
                        require("mini.ai").setup({
                                custom_textobjects = {
                                        -- FIXME: doesn't work
                                        a = require("mini.ai").gen_spec.treesitter(
                                                {
                                                        a = "@parameter.outer",
                                                        i = "@parameter.inner",
                                                },
                                                {}
                                        ),
                                        f = require("mini.ai").gen_spec.treesitter(
                                                {
                                                        a = "@function.outer",
                                                        i = "@function.inner",
                                                },
                                                {}
                                        ),
                                        g = require("mini.ai").gen_spec.treesitter(
                                                {
                                                        a = {
                                                                "@conditional.outer",
                                                                "@loop.outer",
                                                        },
                                                        i = {
                                                                "@conditional.inner",
                                                                "@loop.inner",
                                                        },
                                                },
                                                {}
                                        ),
                                        h = require("mini.ai").gen_spec.pair(
                                                "— ",
                                                " —",
                                                { type = "non-balanced" }
                                        ),
                                        ["<"] = require("mini.ai").gen_spec.pair(
                                                "<",
                                                ">",
                                                { type = "non-balanced" }
                                        ),
                                },
                        })
                end
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

                vim.keymap.set(
                        "n",
                        "<leader>gh",
                        "<CMD>lua MiniDiff.toggle_overlay()<CR>",
                        { desc = "[Git] Diff overlay" }
                )
                -- }}}

                -- mini.doc {{{
                require("mini.doc").setup({})
                -- }}}

                -- mini.git {{{
                require("mini.git").setup()
                require("utils.cabbrev")({
                        ["Git"] = { "git" },
                })

                local group = vim.api.nvim_create_augroup(
                        "MyMiniGit",
                        { clear = true }
                )
                vim.keymap.set(
                        "n",
                        "<leader>gd",
                        "<CMD>difft<CR><CMD>vert Git show HEAD:%<CR><C-w>W",
                        { desc = "Diff current file" }
                )
                vim.api.nvim_create_autocmd({ "FileType" }, {
                        desc = "MiniGit diff buffers",
                        group = group,
                        callback = function()
                                local name = vim.api.nvim_buf_get_name(0)
                                if
                                        not name:match(
                                                "^minigit://.*/git show HEAD:"
                                        )
                                then
                                        return
                                end
                                local basename = vim.fs.basename(name)
                                vim.api.nvim_buf_set_name(
                                        0,
                                        "minigit://" .. basename
                                )
                                vim.api.nvim_set_option_value(
                                        "modifiable",
                                        false,
                                        { scope = "local" }
                                )
                                vim.cmd.diffthis()
                        end,
                })

                vim.keymap.set(
                        "n",
                        "<leader>gb",
                        "mzgg<CMD>vert Git blame -- %<CR><C-w>W<CMD>set cursorbind<CR><CMD>set scrollbind<CR>`z",
                        { desc = "Git blame" }
                )

                local ns = vim.api.nvim_create_namespace("mini_git_blame")
                vim.api.nvim_create_autocmd({ "FileType" }, {
                        desc = "Format MiniGit blame buffer",
                        pattern = "git",
                        group = group,
                        callback = function()
                                local name = vim.api.nvim_buf_get_name(0)
                                -- stylua: ignore
                                if not name:match( "^minigit://.*/git blame") then return end

                                -- stylua: ignore
                                local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)
                                local match = line[1]:find("[+-]%d%d%d%d")
                                vim.cmd.resize({
                                        match + 5,
                                        mods = { vertical = true },
                                })

                                vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
                                local last_line = vim.api.nvim_buf_line_count(0)
                                for lnum = 0, last_line - 1 do
                                        vim.api.nvim_buf_set_extmark(
                                                0,
                                                ns,
                                                lnum,
                                                match + 4,
                                                {
                                                        -- stylua: ignore
                                                        virt_text = { { ")", "Normal" } },
                                                        virt_text_pos = "overlay",
                                                }
                                        )
                                end

                                -- stylua: ignore start
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
                                vim.api.nvim_set_option_value("statuscolumn", "", opts)
                                -- stylua: ignore end
                        end,
                })
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
                                todo_rust_macro = {
                                        pattern = "todo!%(%)",
                                        group = "MiniHipatternsFixme",
                                },
                        },
                })
                -- }}}

                -- mini.icons {{{
                require("mini.icons").setup({
                        filetype = {
                                nu = { hl = "MiniIconsGreen" },
                        },
                        file = {
                                ["init.lua"] = { glyph = "󰢱" },
                        },
                })
                -- }}}

                -- mini.misc {{{
                require("mini.misc").setup_auto_root({ ".git" })
                require("mini.misc").setup_restore_cursor({ center = false })
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

                vim.keymap.set(
                        "n",
                        "gyy",
                        "mzgmmkgcc`zj",
                        { remap = true, desc = "Duplicate and comment" }
                )
                vim.keymap.set("x", "gy", "gmmzgvgc`z", {
                        remap = true,
                        desc = "Duplicate and comment selection",
                })
                -- }}}

                -- mini.pairs {{{
                require("mini.pairs").setup({
                        modes = {
                                insert = true,
                                command = false,
                                terminal = false,
                        },
                        mappings = {
                                --stylua: ignore start
                                ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\].", register = { bs = true, cr = true } },
                                ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\].", register = { bs = true, cr = true } },
                                ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\].", register = { bs = true, cr = true } },
                                ["<"] = { action = "open", pair = "<>", neigh_pattern = "[^ \\].", register = { bs = true } },
                                [">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },
                                ["|"] = { action = "closeopen", pair = "||", neigh_pattern = "[\\{\\][}]", register = { bs = true } }, -- closures
                                ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a&<\\][^>]", register = { cr = false }, }, -- lifetimes
                                ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^%a\\].", register = { cr = false } },
                                --stylua: ignore end
                        },
                })

                local map_bs = function(lhs, rhs)
                        vim.keymap.set(
                                "i",
                                lhs,
                                rhs,
                                { expr = true, replace_keycodes = false }
                        )
                end

                map_bs("<C-h>", "v:lua.MiniPairs.bs()")
                map_bs("<C-w>", "v:lua.MiniPairs.bs('\23')")
                map_bs("<C-u>", "v:lua.MiniPairs.bs('\21')")

                vim.cmd([[
                        augroup Cmdlinewin_No_Pairs
                                au!
                                au CmdwinEnter * lua vim.b.minipairs_disable = true
                        augroup END
                ]])
                -- }}}

                -- mini.sessions {{{
                require("mini.sessions").setup({
                        force = {
                                read = false,
                                write = true,
                                delete = true,
                        },
                })

                vim.keymap.set("n", "<leader>mn", function()
                        local cwd = vim.fs.basename(vim.uv.cwd())
                        require("mini.sessions").write(cwd .. ".vim")
                end, { desc = "Make session" })
                vim.keymap.set("n", "<leader>ml", function()
                        require("mini.sessions").select()
                end, { desc = "List sessions" })
                vim.keymap.set("n", "<leader>md", function()
                        require("mini.sessions").delete()
                end, { desc = "Delete session" })
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
                                ["B"] = { -- Bold
                                        input = { "%*%*().-()%*%*" },
                                        output = { left = "**", right = "**" },
                                },
                                ["G"] = { -- Code block
                                        input = { "%```().-()%```" },
                                        output = {
                                                left = "```",
                                                right = "\n```",
                                        },
                                },
                        },
                })

                vim.keymap.del("x", "ys")
                vim.keymap.set(
                        "x",
                        "Y",
                        ":<C-u>lua MiniSurround.add('visual')<CR>",
                        { silent = true }
                )
                vim.keymap.set("n", "yS", "ys$", { remap = true })
                vim.keymap.set("n", "yss", "ys_", { remap = true })
                -- }}}
        end,
}

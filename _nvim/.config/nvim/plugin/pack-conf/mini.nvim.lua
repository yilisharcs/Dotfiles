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

vim.keymap.set("n", "g==", "^g=$", { remap = true, desc = "Evaluate line" })

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
        ["'"] = false,
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
    elseif vim.bo.filetype == "man" then
        vim.cmd.quit()
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
        config = {
            width = math.floor(vim.o.columns * 0.27 - 0.5),
        },
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

vim.keymap.set("n", "<leader>gh", "<CMD>lua MiniDiff.toggle_overlay()<CR>", { desc = "Overlay git diff" })
-- }}}

-- mini.git {{{
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
                -- stylua: ignore
                callback = function()
                        local name = vim.api.nvim_buf_get_name(0)
                        if not name:match("^minigit://%d*/git show HEAD~") then return end
                        local basename = vim.fs.basename(name)
                        vim.api.nvim_buf_set_name(0, "minigit://" .. basename)
                        vim.api.nvim_set_option_value("modifiable", false, { scope = "local" })
                        vim.cmd.diffthis()
                end,
    })

    vim.keymap.set({ "n", "x" }, "<leader>gs", function()
        MiniGit.show_at_cursor()
    end, { desc = "Git show at cursor" })

    vim.keymap.set({ "n", "x" }, "<leader>gS", function()
        MiniGit.show_range_history()
    end, { desc = "Git range history" })

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
        winblend = os.getenv("DISPLAY") and 25 or 0,
    },
})
_G.MiniNotify = MiniNotify

-- suppress luals progress spam
local ignore_progress = {
    "Diagnosing",
    "Diagnosing workspace",
    "Processing full semantic tokens",
}
local Client = require("vim.lsp.client")
---@diagnostic disable-next-line: invisible
local _notification = Client._notification
local suppressed = {}
--/@ ~/Projects/github.com/neovim/neovim/runtime/lua/vim/lsp/client.lua:1388
---@diagnostic disable-next-line: invisible
function Client:_notification(method, params)
    if method == "$/progress" then
        local kind = params.value and params.value.kind
        local id = ("%d\0%s"):format(self.id, tostring(params.token or ""))
        if kind == "begin" then
            local text = ("%s %s"):format(params.value.title or "", params.value.message or "")
            suppressed[id] = vim.iter(ignore_progress):any(function(pattern)
                return text:find(pattern, 1, true) ~= nil
            end)
        end
        if suppressed[id] then
            if kind == "end" then
                suppressed[id] = nil
            end
            return
        end
    end
    _notification(self, method, params)
end

vim.keymap.set("n", "<leader>n", function()
    MiniNotify.show_history()
end, { desc = "Notification history" })
-- }}}

-- mini.pick {{{

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

-- }}}

-- mini.sessions {{{
vim.o.sessionoptions = vim.o.sessionoptions .. ",globals"

require("mini.sessions").setup({
    autoread = false,
    file = "",
    force = {
        read = false,
        write = true,
        delete = true,
    },
    hooks = {
        -- "global variables that start with an uppercase letter and contain at least one lowercase letter"
        pre = {
            write = function()
                vim.g.CmeLastCmd = require("cme").__INTERNAL_H.state.last_cmd
            end,
        },
        post = {
            read = function()
                require("cme").__INTERNAL_H.state.last_cmd = vim.g.CmeLastCmd
            end,
        },
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

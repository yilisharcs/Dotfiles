local group = vim.api.nvim_create_augroup("My_Autocmds", { clear = true })

vim.api.nvim_create_autocmd({ "TextYankPost" }, {
        desc = "Highlight text on copy",
        group = group,
        callback = function()
                vim.hl.on_yank({ higroup = "Visual", timeout = 500 })
        end,
})

vim.api.nvim_create_autocmd({
        "CursorHold",
        "FileChangedShell",
        "TabEnter",
        "TermLeave",
        "WinEnter",
}, {
        desc = "Check for external changes",
        group = group,
        callback = function()
                if vim.bo.buftype ~= "nofile" then
                        vim.cmd.checktime()
                end
        end,
})

vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter", "WinEnter" }, {
        desc = "Enter terminal on insert mode",
        group = group,
        pattern = "term://*",
        callback = function()
                local buf = vim.api.nvim_buf_get_name(0)
                if not buf:match("compilation://*") then
                        vim.cmd.startinsert()
                end
        end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
        desc = "Insert comment leader",
        group = group,
        callback = function()
                vim.opt.formatoptions:append("r")
                if not vim.tbl_contains({ "markdown", "text" }, vim.bo.filetype) then
                        vim.opt.formatoptions:remove("o")
                end
        end,
})

vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "OptionSet" }, {
        desc = "Set listchars like indent-blankline",
        group = group,
        callback = function()
                if not vim.tbl_contains({
                        "Makefile",
                }, vim.bo.filetype) then
                        local append = "leadmultispace:▹" .. string.rep(" ", vim.o.shiftwidth - 1)
                        vim.wo[0][0].listchars = vim.go.listchars .. "," .. append
                end
        end,
})

vim.api.nvim_create_autocmd({ "VimEnter" }, {
        desc = "Set registers b-z on launch to overwrite one-off garbages",
        group = group,
        callback = function()
                for i = 98, 122 do
                        if i ~= 114 or i ~= 116 then
                                vim.fn.setreg(vim.fn.nr2char(i), {})
                        end
                end

                -- toggle case and advance word
                vim.fn.setreg("c", "wvg~")
                -- TODO: figure out what this does
                vim.fn.setreg("m", "JjJ^r>}j")
        end,
})

vim.api.nvim_create_autocmd({ "QuickFixCmdPost" }, {
        desc = "Automatically open the quickfix window",
        group = group,
        pattern = "[^l]*",
        nested = true,
        command = "cwindow",
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        desc = "Clear newline character from LLM output",
        group = group,
        callback = function()
                local cursor = vim.api.nvim_win_get_cursor(0)
                vim.cmd("silent! keeppatterns %s/\r$//e")
                vim.api.nvim_win_set_cursor(0, cursor)
        end,
})

vim.api.nvim_create_autocmd({ "ModeChanged" }, {
        desc = "Suppress ModeMsg in any visual mode so *v_g_CTRL-G* is visible",
        group = group,
        callback = function(opts)
                local function check_visual(m)
                        return vim.iter({
                                "v",
                                "vs",
                                "V",
                                "Vs",
                                "",
                                "s",
                        }):any(function(p)
                                return m == p
                        end)
                end

                local modes = vim.split(opts.match, ":")
                local is_visual = check_visual(modes[2])
                local was_visual = check_visual(modes[1])

                if is_visual and not was_visual and vim.o.showmode then
                        vim.o.showmode = false
                        vim.api.nvim_create_autocmd("ModeChanged", {
                                group = group,
                                callback = function(inner_opts)
                                        local inner_modes = vim.split(inner_opts.match, ":")
                                        if not check_visual(inner_modes[2]) then
                                                vim.o.showmode = true
                                                return true
                                        end
                                end,
                        })
                end
        end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        desc = 'Remove stupid "smart" quotes',
        group = vim.api.nvim_create_augroup("NoSmartQuotes", { clear = true }),
        callback = function()
                local name = vim.api.nvim_buf_get_name(0)
                if not name:find(".config/nvim/plugin/autocmds.lua", 1, true) then
                        return
                end
                if not name:find("Projects/github.com/neovim/neovim/", 1, true) then
                        return
                end

                local cursor = vim.api.nvim_win_get_cursor(0)
                vim.cmd('silent! keeppatterns %s/[“”]/"/ge')
                vim.cmd("silent! keeppatterns %s/[‘’]/'/ge")
                vim.api.nvim_win_set_cursor(0, cursor)
        end,
})

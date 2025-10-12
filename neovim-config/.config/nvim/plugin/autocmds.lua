local group = vim.api.nvim_create_augroup("My_Autocmds", { clear = true })

-- Highlight text on copy
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
        group = group,
        callback = function()
                vim.hl.on_yank({ higroup = "Visual", timeout = 500 })
        end
})

vim.api.nvim_create_autocmd({
        "CursorHold",
        "FileChangedShell",
        "TabEnter",
        "TermLeave",
        "WinEnter",
}, {
        group = group,
        callback = function()
                if vim.bo.buftype ~= "nofile" then
                        vim.cmd.checktime()
                end
        end
})

-- Open file under cursor on the terminal in a tab
vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter" }, {
        group = group,
        callback = function()
                vim.keymap.set("n", "gf", "<C-w>gF", { buffer = true })
        end
})

-- Enter terminal on insert mode
vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter", "WinEnter" }, {
        group = group,
        pattern = "term://*",
        command = "startinsert"
})

-- Newline doesn't insert comment from comment
vim.api.nvim_create_autocmd({ "FileType" }, {
        group = group,
        callback = function()
                vim.cmd("set formatoptions+=r")
                vim.cmd("set formatoptions-=o")
        end
})

-- Set listchars like indent-blankline
vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "OptionSet" }, {
        group = group,
        callback = function()
                if vim.bo.filetype ~= "snacks_notif" then
                        local append = "leadmultispace:│" .. string.rep(" ", vim.o.shiftwidth - 1)
                        vim.wo[0][0].listchars = vim.go.listchars .. "," .. append
                end
        end
})

-- Set registers b-z on launch. They're filled
-- with one-off macros and other such garbage.
vim.api.nvim_create_autocmd({ "VimEnter" }, {
        group = group,
        callback = function()
                for i = 98, 122 do
                        vim.fn.setreg(vim.fn.nr2char(i), {})
                end

                vim.fn.setreg("c", "wvg~")
                vim.fn.setreg("m", "JjJ^r>}j")
        end
})

-- Automatically open the quickfix window
vim.api.nvim_create_autocmd({ "QuickFixCmdPost" }, {
        group = group,
        pattern = "[^l]*",
        nested = true,
        command = "cwindow"
})

-- Clear newline character from LLM output
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        group = group,
        callback = function()
                local cursor = vim.api.nvim_win_get_cursor(0)
                vim.cmd("silent! keeppatterns %s/\r$//e")
                vim.api.nvim_win_set_cursor(0, cursor)
        end
})

-- Remove stupid "smart" quotes
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        group = group,
        callback = function()
                local bufname = vim.api.nvim_buf_get_name(0)
                if string.match(bufname, ".config/nvim/plugin/autocmds.lua") == nil then
                        local cursor = vim.api.nvim_win_get_cursor(0)
                        vim.cmd('silent! keeppatterns %s/[“”]/"/ge')
                        vim.cmd("silent! keeppatterns %s/[‘’]/'/ge")
                        vim.api.nvim_win_set_cursor(0, cursor)
                end
        end
})

-- Close nushell terminal buffers as if {cmd} wasn't supplied to :term
vim.api.nvim_create_autocmd({ "TermClose" }, {
        group = group,
        pattern = "*:/usr/bin/nu",
        command = "silent! execute 'bdelete! '.expand('<abuf>')"
})

vim.o.tagfunc = "v:lua.tafsk_resolve"

function _G.tafsk_resolve(pattern, flags, _)
        -- Extract: TASK((date)-(time).(hash))
        local id = vim.fn.expand("<cWORD>"):match("TASK%((%d+%-%d+%.%w+)%)")
        if not id then
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if #clients > 0 then return vim.lsp.tagfunc(pattern, flags) end
                return nil
        end

        local target = "tasks/" .. id .. "/TASK.md"
        local found = vim.fn.findfile(target, vim.uv.cwd())

        if found ~= "" then
                return {
                        {
                                name = id,
                                filename = found,
                                cmd = "7",
                        },
                }
        end

        vim.api.nvim_echo({ { "E426: Tag not found: " .. id, "ErrorMsg" } }, true, {})

        return {}
end

vim.keymap.set("n", "<C-]>", function()
        local key = vim.api.nvim_replace_termcodes("<C-]>", true, false, true)
        local ok, err = pcall(vim.cmd.normal, { args = { key }, bang = true })
        if not ok then
                local task_not_found = err:match("E426")
                if task_not_found and vim.fn.expand("<cWORD>"):match("TASK%((%d+%-%d+%.%w+)%)") then
                        return
                else
                        local msg = err:match("(E%d+:.*)") or err
                        vim.api.nvim_echo({ { msg, "ErrorMsg" } }, true, {})
                end
        end
end, { desc = "Jump to the task or the tag under the cursor" })

vim.api.nvim_create_autocmd("LspAttach", {
        desc = "Ensure LSP tagfunc fallback for Tafsk",
        group = vim.api.nvim_create_augroup("Tafsk", { clear = true }),
        callback = function(args)
                vim.schedule(function()
                        vim.bo[args.buf].tagfunc = "v:lua.tafsk_resolve"
                end)
        end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
        desc = "Toggle tafsk status",
        group = vim.api.nvim_create_augroup("Tafsk", { clear = true }),
        pattern = "markdown",
        callback = function()
                vim.keymap.set("n", "<CR>", function()
                        local row, _col = unpack(vim.api.nvim_win_get_cursor(0))
                        local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
                        -- stylua: ignore
                        if line:find("status: OPEN", 1, true) then
                                vim.api.nvim_buf_set_lines(0, row - 1, row, false, { "status: CLOSED" })
                        elseif line:find("status: CLOSED", 1, true) then
                                vim.api.nvim_buf_set_lines(0, row - 1, row, false, { "status: OPEN" })
                        else
                                local key = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
                                vim.api.nvim_feedkeys(key, "n", false)
                        end
                end)
        end,
})

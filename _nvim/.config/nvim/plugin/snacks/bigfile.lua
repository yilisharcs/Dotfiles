-- https://github.com/folke/snacks.nvim/blob/ad9ede6a9cddf16cedbd31b8932d6dcdee9b716e/lua/snacks/bigfile.lua

vim.filetype.add({
        pattern = {
                [".*"] = {
                        function(path, buf)
                                if not path or not buf or vim.bo[buf].filetype == "bigfile" then
                                        return
                                end
                                if path ~= vim.fs.normalize(vim.api.nvim_buf_get_name(buf)) then
                                        return
                                end
                                local size = vim.fn.getfsize(path)
                                if size <= 0 then
                                        return
                                end
                                -- 1.5MB
                                if size > (1.5 * 1024 * 1024) then
                                        return "bigfile"
                                end
                                local lines = vim.api.nvim_buf_line_count(buf)
                                return (size - lines) / lines > 1000 and "bigfile" or nil
                        end,
                },
        },
})

vim.api.nvim_create_autocmd({ "FileType" }, {
        group = vim.api.nvim_create_augroup("bigfile", { clear = true }),
        pattern = "bigfile",
        callback = function(ev)
                local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.buf), ":p:~:.")
                vim.notify(
                        ("Big file detected `%s`. Some features have been disabled."):format(path),
                        vim.log.levels.WARN
                )
                vim.api.nvim_buf_call(ev.buf, function()
                        if vim.fn.exists(":NoMatchParen") ~= 0 then
                                vim.cmd([[NoMatchParen]])
                        end
                        vim.wo.foldmethod = "manual"
                        vim.wo.statuscolumn = ""
                        vim.wo.conceallevel = 0
                        vim.b.completion = false
                        vim.b.minianimate_disable = true
                        vim.b.minihipatterns_disable = true
                        vim.schedule(function()
                                if vim.api.nvim_buf_is_valid(ev.buf) then
                                        vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf })
                                                or ""
                                end
                        end)
                end)
        end,
})

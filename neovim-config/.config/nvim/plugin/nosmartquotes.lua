vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        desc = 'Remove stupid "smart" quotes',
        group = vim.api.nvim_create_augroup("NoSmartQuotes", { clear = true }),
        callback = function()
                local bufname = vim.api.nvim_buf_get_name(0)
                if string.match(bufname, ".config/nvim/plugin/nosmartquotes.lua") == nil then
                        local cursor = vim.api.nvim_win_get_cursor(0)
                        vim.cmd('silent! keeppatterns %s/[“”]/"/ge')
                        vim.cmd("silent! keeppatterns %s/[‘’]/'/ge")
                        vim.api.nvim_win_set_cursor(0, cursor)
                end
        end,
})

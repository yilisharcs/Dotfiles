local function make_cmdline_abbreviations(tbl)
        for key, variants in pairs(tbl) do
                for _, lhs in ipairs(variants) do
                        vim.keymap.set("ca", lhs, function()
                                if vim.fn.getcmdtype() == ":" then
                                        local cmd = vim.fn.getcmdline()
                                        if cmd:match("^" .. lhs) then return key end
                                        return lhs
                                end
                        end, { expr = true })
                end
        end
end

return make_cmdline_abbreviations

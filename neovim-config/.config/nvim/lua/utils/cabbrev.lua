local function make_cmdline_abbreviations(tbl)
        for key, variants in pairs(tbl) do
                for _, lhs in ipairs(variants) do
                        vim.keymap.set("ca", lhs, function()
                                if vim.fn.getcmdtype() == ":" then
                                        if vim.fn.getcmdpos() == (#lhs + 1) then
                                                return key
                                        end
                                end
                                return lhs
                        end, { expr = true })
                end
        end
end

return make_cmdline_abbreviations

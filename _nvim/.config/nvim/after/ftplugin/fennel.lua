vim.bo.iskeyword = vim.o.iskeyword
        .. ","
        .. table.concat({
                -- idents
                "?",
                "!",
                "*",
                "-",
                "<",
                ">",
                "$",
                "&",
                -- macros
                "'",
                "`",
                ",",
        }, ",")

vim.bo.includeexpr = [[tr(substitute(v:fname, '^:', '', ''), '.', '/')]]

vim.bo.comments = ":;;;;,:;;;,:;;,:;"

local function kv_split(positions)
        if #positions < 3 then
                return positions
        end

        local first = positions[1]
        local bracket = vim.api.nvim_buf_get_lines(0, first.line - 1, first.line, false)[1]:sub(first.col, first.col)

        local kv_tbl = bracket == "{"
        if kv_tbl then
                local res = { positions[1] }
                for i = 2, #positions - 1 do
                        if i % 2 == 1 then
                                table.insert(res, positions[i])
                        end
                end
                table.insert(res, positions[#positions])
                return res
        end

        return positions
end

vim.b.minisplitjoin_config = {
        detect = {
                brackets = { "%b[]", "%b{}" },
                separator = "%s+",
        },
        split = {
                indent = "lisp",
                hooks_pre = { kv_split },
        },
}

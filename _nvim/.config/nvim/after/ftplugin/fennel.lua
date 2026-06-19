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

local function split_hook(positions)
        if #positions < 3 then
                return positions
        end

        local first = positions[1]
        local bracket = vim.api.nvim_buf_get_lines(0, first.line - 1, first.line, false)[1]:sub(first.col, first.col)

        local seq_tbl = bracket == "["
        local kv_tbl = bracket == "{"

        if seq_tbl then
                return positions
        elseif kv_tbl then
                local n = #positions
                local result = { positions[1] }

                for i = 2, n - 1 do
                        local prev, curr = positions[i - 1], positions[i]
                        local text = vim.api
                                .nvim_buf_get_lines(0, prev.line - 1, prev.line, false)[1]
                                :sub(prev.col + 1, curr.col - 1)
                                :match("^%s*(.-)%s*$")
                        if text ~= "" and text:sub(1, 1) ~= ":" then
                                table.insert(result, curr)
                        end
                end

                table.insert(result, positions[n])
                return result
        end

        return positions
end

vim.b.minisplitjoin_config = {
        detect = {
                brackets = { "%b[]", "%b{}" },
                separator = "%s+",
        },
        split = {
                hooks_pre = { split_hook },
        },
}

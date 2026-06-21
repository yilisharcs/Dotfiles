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

vim.bo.commentstring = ";; %s"
vim.bo.comments = ":;;;;,:;;;,:;;,:;"

-- cache the position of the opening bracket.
-- `lisp_indent` needs what `lisp_split` strips out.
local bracket_col_cache

-- any {:foo 10} or (let [bar 20]) are key-value tables
local function kv_split(positions)
        if #positions < 2 then
                return positions
        end

        local first = positions[1]
        local line = vim.api.nvim_buf_get_lines(0, first.line - 1, first.line, false)[1]
        local bracket = line:sub(first.col, first.col)
        bracket_col_cache = first.col

        local is_kv_tbl = bracket == "{"
        if bracket == "[" then
                -- doesn't check line above
                local before = line:sub(1, first.col - 1)
                is_kv_tbl = before:match("let%s*$") ~= nil
        end

        if is_kv_tbl then
                local res = { positions[1] }
                for i = 3, #positions - 1, 2 do
                        res[#res + 1] = positions[i]
                end
                res[#res + 1] = positions[#positions]
                return res
        end

        return positions
end

-- brackets stay close to the first and last elements
local function lisp_split(positions)
        if #positions < 2 then
                return positions
        end

        local res = {}
        for i = 2, #positions - 1 do
                res[i - 1] = positions[i]
        end

        return res
end

-- align all elements to the first element
local function lisp_indent(positions)
        if #positions < 2 then
                return positions
        end

        local indent = string.rep(" ", bracket_col_cache or 1)
        for l = positions[1].line + 1, positions[#positions].line do
                local cur_line = vim.api.nvim_buf_get_lines(0, l - 1, l, false)[1]
                vim.api.nvim_buf_set_text(0, l - 1, 0, l - 1, cur_line:match("^%s*"):len(), { indent })
        end

        return positions
end

-- add a space after the first and before the last element
local function lisp_pad(positions)
        if #positions < 2 then
                return positions
        end

        local first = positions[1]
        local last = positions[#positions - 1]
        local two_kv = first.line == last.line and first.col == last.col

        vim.api.nvim_buf_set_text(0, first.line - 1, first.col, first.line - 1, first.col, { " " })
        if not two_kv then
                last.col = last.col + 1
                vim.api.nvim_buf_set_text(0, last.line - 1, last.col, last.line - 1, last.col, { " " })
        end

        return positions
end

vim.b.minisplitjoin_config = {
        detect = {
                brackets = { "%b[]", "%b{}" },
                separator = "%s+",
        },
        split = {
                hooks_pre = { kv_split, lisp_split },
                hooks_post = { lisp_indent },
        },
        join = {
                hooks_post = { lisp_pad },
        },
}

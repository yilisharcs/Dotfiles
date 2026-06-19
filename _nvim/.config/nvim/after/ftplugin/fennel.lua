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

-- NOTE: vim.opt/_local/_global will be deprecated by v1.0
vim.opt_local.iskeyword:append(table.concat({
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
        "\\,",
}, ","))

vim.bo.includeexpr = [[tr(substitute(v:fname, '^:', '', ''), '.', '/')]]

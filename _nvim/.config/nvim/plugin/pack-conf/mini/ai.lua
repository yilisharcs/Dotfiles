if vim.g.shell_editor then
    return
end

require("mini.ai").setup({
    custom_textobjects = {
        a = require("mini.ai").gen_spec.treesitter({
            a = "@parameter.outer",
            i = "@parameter.inner",
        }, {}),
        c = require("mini.ai").gen_spec.treesitter({
            a = "@call.outer",
            i = "@call.inner",
        }, {}),
        f = require("mini.ai").gen_spec.treesitter({
            a = "@function.outer",
            i = "@function.inner",
        }, {}),
        g = require("mini.ai").gen_spec.treesitter({
            a = {
                "@conditional.outer",
                "@loop.outer",
            },
            i = {
                "@conditional.inner",
                "@loop.inner",
            },
        }, {}),
        -- code blocks
        G = { "```%S*\n?().-()\n?```" },
        -- em-dashed <FOO BAR>
        h = { "— ().-() —" },
        -- tagged
        ["<"] = { "<().-()>" },
    },
})

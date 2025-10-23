if vim.g.shell_editor == true then return end

require("mini.ai").setup({
        custom_textobjects = {
                -- FIXME: doesn't work
                a = require("mini.ai").gen_spec.treesitter({
                        a = "@parameter.outer",
                        i = "@parameter.inner",
                }, {}),
                f = require("mini.ai").gen_spec.treesitter({
                        a = "@function.outer",
                        i = "@function.inner",
                }, {}),
                g = require("mini.ai").gen_spec.treesitter({
                        a = { "@conditional.outer", "@loop.outer" },
                        i = { "@conditional.inner", "@loop.inner" },
                }, {}),
                h = require("mini.ai").gen_spec.pair("— ", " —", { type = "non-balanced" }),
                ["<"] = require("mini.ai").gen_spec.pair("<", ">", { type = "non-balanced" }),
        },
})

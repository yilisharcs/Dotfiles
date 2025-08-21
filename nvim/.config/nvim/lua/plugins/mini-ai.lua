return {
  "echasnovski/mini.ai", -- see `:h MiniAi.config`.
  version = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  cond = not vim.g.shell_editor == true,
  keys = {
    { "ca" },
    { "ci" },
    { "da" },
    { "di" },
    { "ya" },
    { "yi" },
    { "gca" },
    { "gci" },
  },
  config = function()
    require("mini.ai").setup({
      custom_textobjects = {
        a = require("mini.ai").gen_spec.treesitter({
          a = "@parameter.outer",
          i = "@parameter.inner"
        }, {}),
        f = require("mini.ai").gen_spec.treesitter({
          a = "@function.outer",
          i = "@function.inner"
        }, {}),
        g = require("mini.ai").gen_spec.treesitter({
          a = { "@conditional.outer", "@loop.outer" },
          i = { "@conditional.inner", "@loop.inner" },
        }, {}),
        h = require("mini.ai").gen_spec.pair("— ", " —", { type = "non-balanced" }),
        ["<"] = require("mini.ai").gen_spec.pair("<", ">", { type = "non-balanced" }),
      },
    })
  end
}

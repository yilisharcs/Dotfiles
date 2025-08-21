return {
  "echasnovski/mini.operators", -- see `:h MiniOperators.config`.
  version = false,
  keys = {
    { "g-", mode = { "n", "x" } },
    { "cx", mode = { "n", "x" } },
    { "gm", mode = { "n", "x" } },
    { "cs", mode = { "n", "x" } },
  },
  opts = {
    evaluate = {
      prefix = "g-",
      func = nil,
    },
    exchange = {
      prefix = "cx",
      reindent_linewise = true,
    },
    multiply = {
      prefix = "gm",
      func = nil,
    },
    replace = {
      prefix = "cs",
      reindent_linewise = true,
    }
  }
}

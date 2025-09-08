return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",
  keys = {
    {
      "<C-SPACE>h",
      "<CMD>" ..
      "2TermExec " ..
      "cmd='btop' " ..
      "direction=float " ..
      "name='RESOURCE MONITOR' " ..
      "<CR>",
      mode = { "n", "i", "t" },
      desc = "Toggleterm resource monitor"
    },
    {
      "<C-SPACE>g",
      "<CMD>" ..
      "3TermExec " ..
      "cmd='gh dash' " ..
      "dir=~ " ..
      "direction=float " ..
      "name='GITHUB DASHBOARD' " ..
      "<CR>",
      mode = { "n", "i", "t" },
      desc = "Toggleterm Github dashboard"
    },
  },
  opts = {
    open_mapping = "<C-g>",
    shell = vim.fn.executable("nu") == 1 and vim.fn.exepath("nu") or vim.o.shell,
    size = function(term)
      if term.direction == "horizontal" then
        return vim.o.lines * 0.4
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.5
      end
    end,
  }
}

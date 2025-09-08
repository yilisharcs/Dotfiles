return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VeryLazy",
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
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    local Terminal = require("toggleterm.terminal").Terminal

    Terminal:new({
      cmd = "gh dash",
      dir = "~",
      direction = "float",
      display_name = "GITHUB DASHBOARD",
      count = 2
    }):toggle():toggle()

    Terminal:new({
      cmd = "btop",
      direction = "float",
      display_name = "RESOURCE MONITOR",
      count = 3
    }):toggle():toggle()
  end
}

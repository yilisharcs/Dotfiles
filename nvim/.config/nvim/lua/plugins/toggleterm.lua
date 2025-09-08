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

    local btop = Terminal:new({
      cmd = "btop",
      direction = "float",
      display_name = "RESOURCE MONITOR",
      count = 3
    })
    btop:toggle():toggle()
    vim.keymap.set({ "n", "t" }, "<C-SPACE>h", function() btop:toggle() end)

    local gh_dash = Terminal:new({
      cmd = "gh dash",
      dir = "~",
      direction = "float",
      display_name = "GITHUB DASHBOARD",
      count = 2
    })
    gh_dash:toggle():toggle()
    vim.keymap.set({ "n", "t" }, "<C-SPACE>g", function() gh_dash:toggle() end)
  end
}

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      {
        "<C-g>",
        "<CMD>exe v:count1 . 'ToggleTerm'<CR>",
        mode = { "n", "i", "t" },
        desc = "Toggle terminal window"
      },
    },
    opts = {
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
}

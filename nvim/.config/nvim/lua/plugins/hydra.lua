return {
  "nvimtools/hydra.nvim",
  keys = { "<C-w>", "z" },
  config = function()
    local hydra = require("hydra")

    hydra({
      name = "SIDE SCROLL",
      mode = "n",
      body = "z",
      heads = {
        { "h", "5zh", {} },
        { "l", "5zl", { desc = "<= =>" } },
        { "H", "zH",  {} },
        { "L", "zL",  { desc = "Half screen <= =>" } },
      }
    })

    hydra({
      name = "WINCMD",
      mode = "n",
      body = "<C-w>",
      heads = {
        { "<", "<C-w>2<" },
        { ">", "<C-w>2>" },
        { "-", "<C-w>2-" },
        { "+", "<C-w>2+" },
        { "=", "<C-w>=" },
        { "H", "<C-w>H" },
        { "L", "<C-w>L" },
        { "J", "<C-w>J" },
        { "K", "<C-w>K" },
        { "c", "<C-w>c" },
      },
    })
  end
}

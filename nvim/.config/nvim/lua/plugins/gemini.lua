return {
  "marcinjahn/gemini-cli.nvim",
  dependencies = { "folke/snacks.nvim" },
  cmd = "Gemini",
  keys = {
    { "<F12>",      "<CMD>Gemini toggle<CR>",   mode = { "n", "t" },                desc = "Toggle Gemini CLI" },
    { "<leader>as", "<CMD>Gemini ask<CR>",      mode = { "n", "x" },                desc = "Ask Gemini" },
    { "<leader>af", "<CMD>Gemini add_file<CR>", desc = "Add file to Gemini context" },
  },
  opts = {
    auto_reload = true,
    args = {
      "--checkpointing",
    },
    win = {
      border = "rounded",
      position = "float",
      wo = { winbar = "" },
    },
  }
}

return {
  "MeanderingProgrammer/render-markdown.nvim",
  -- enabled = false,
  cond = vim.env.DISPLAY ~= nil,
  ft = { "markdown", "codecompanion" },
  opts = {
    render_modes = true,
    anti_conceal = {
      enabled = true,
      above = 1,
      below = 1,
    },
    pipe_table = { preset = "round" },
    html = { comment = { conceal = false } },
    sign = { enabled = false },
  }
}

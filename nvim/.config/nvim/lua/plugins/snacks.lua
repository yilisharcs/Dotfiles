return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    { "<leader>gB", function() Snacks.gitbrowse() end,             desc = "Open git repo in the browser" },
    { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<F7>",       ":= _G.dd()<LEFT>",                            desc = "Debug inspect" },
    { "<leader>s",  function() Snacks.scratch() end,               desc = "Toggle Scratch Buffer" },
    { "<leader>S",  function() Snacks.scratch.select() end,        desc = "Select Scratch Buffer" },
  },
  opts = {
    bigfile = {
      enabled = true,
      size = 1.5 * 1024 * 1024, -- 1.5MB
    },
    gitbrowse = { enabled = true },
    image = { enabled = vim.env.TERM == "xterm-kitty" },
    input = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scratch = { enable = true },
    styles = {
      notification_history = {
        width = 0.9,
        wo = { wrap = true },
      }
    }
  },
  init = function()
    -- setup some globals for debugging
    _G.dd = function(...) Snacks.debug.inspect(...) end
    _G.bt = function() Snacks.debug.backtrace() end
    vim.print = _G.dd

    -- simple lsp progress example
    vim.api.nvim_create_autocmd("LspProgress", {
      ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
      callback = function(ev)
        local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
        vim.notify(vim.lsp.status(), vim.log.levels.INFO, {
          id = "lsp_progress",
          title = "LSP Progress",
          opts = function(notif)
            notif.icon = ev.data.params.value.kind == "end" and " "
              or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
          end
        })
      end
    })
  end
}

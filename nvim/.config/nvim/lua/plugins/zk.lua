return {
  "zk-org/zk-nvim",
  keys = {
    {
      "<leader>zn",
      function()
        vim.ui.input({ prompt = "Title: " }, function(input)
          require("zk").new({ title = input })
          vim.defer_fn(function()
            vim.api.nvim_feedkeys("Gi", "n", false)
          end, 200)
        end)
      end,
      desc = "Create new note"
    },
    {
      "<leader>zc",
      function()
        vim.ui.input({ prompt = "Title: " }, function(input)
          require("zk").new({ title = input, group = "chess" })
          vim.defer_fn(function()
            vim.api.nvim_feedkeys("9GA ", "n", false)
          end, 200)
        end)
      end,
      desc = "Create chess game entry"
    },
    {
      "<leader>zl",
      function()
        require("zk").new({ dir = "journal", group = "journal" })
      end,
      desc = "Create journal entry"
    },
    {
      "<leader>zo",
      function()
        require("zk").edit({ sort = { "modified" } })
      end,
      desc = "Open notes"
    },
    { "<leader>zt", "<CMD>ZkTags<CR>", desc = "Open tagged notes" },
    {
      "<leader>zf",
      function()
        vim.ui.input({ prompt = "Query: " }, function(input)
          require("zk").edit({
            sort = { "modified" },
            match = { input },
          })
        end)
      end,
      desc = "Find matching query in notebook"
    },
    {
      "<leader>zf",
      ":'<,'>ZkMatch<CR>",
      mode = "x",
      desc = "Find matching selection in notebook"
    },
  },
  opts = { picker = "fzf_lua" },
  config = function(_, opts)
    require("zk").setup(opts)
  end
}

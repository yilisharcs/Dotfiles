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
      "<leader>zu",
      function()
        vim.ui.input({ prompt = "Source: " }, function(input)
          local title = string.match(input, "%s(.*)")
          local type_l = string.match(input, "(%a*)")
          local type = string.gsub(type_l, "^%l", string.upper)

          require("zk").new({
            title = type .. " - " .. title,
            group = "source",
            extra = { type = type },
          })
          vim.defer_fn(function()
            vim.api.nvim_feedkeys("11GA ", "n", false)
          end, 200)
        end)
      end,
      desc = "Create source note"
    },
    {
      "<leader>zc",
      function()
        vim.ui.input({ prompt = "Opponent: " }, function(input)
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
      "<leader>zy",
      function()
        -- HACK: https://github.com/zk-org/zk-nvim/issues/122
        -- The methods discussed here didn't work for me.
        vim.api.nvim_feedkeys('"zy', "x", false)
        require("zk").new({ title = vim.fn.getreg("z") })
        vim.defer_fn(function()
          vim.api.nvim_feedkeys("Gi", "n", false)
        end, 200)
      end,
      mode = "x",
      desc = "Create note from selection"
    },
    {
      "<leader>zf",
      ":ZkMatch<CR>",
      mode = "x",
      desc = "Find matching selection in notebook"
    },
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
  },
  opts = { picker = "fzf_lua" },
  config = function(_, opts)
    require("zk").setup(opts)
  end
}

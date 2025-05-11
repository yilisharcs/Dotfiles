return {
  'zk-org/zk-nvim',
  keys = {
    {
      '<leader>zn',
      function()
        vim.ui.input({ prompt = 'Title: ' }, function(input)
          require('zk').new({ title = input })
        end)
      end,
      desc = 'Create new note'
    },
    {
      '<leader>zo',
      function()
        require('zk').edit({ sort = { 'modified' } })
      end,
      desc = 'Open notes'
    },
    { '<leader>zt', '<CMD>ZkTags<CR>', desc = 'Open tagged notes' },
    {
      '<leader>zf',
      function()
        vim.ui.input({ prompt = 'Query: ' }, function(input)
          require('zk').edit({
            sort = { 'modified' },
            match = { input },
          })
        end)
      end,
      desc = 'Find matching query in notebook'
    },
    {
      '<leader>zf',
      ":'<,'>ZkMatch<CR>",
      mode = 'x',
      desc = 'Find matching selection in notebook'
    },
  },
  opts = { picker = 'fzf_lua' },
  config = function(_, opts)
    require('zk').setup(opts)
  end
}

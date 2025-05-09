return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  keys = {
    { '<F12>',      '<CMD>CodeCompanionChat Toggle<CR>', mode = { 'n', 'x', 'i' }, desc = '[CC] Toggle chat' },
    { '<leader>as', '<CMD>CodeCompanionActions<CR>',     mode = { 'n', 'x' },      desc = '[CC] Actions' },
    { '<leader>ag', '<CMD>CodeCompanionChat Add<CR>',    mode = 'x',               desc = '[CC] Chat add' },
  },
  opts = {
    opts = {
      system_prompt = function(opts)
        local file = io.open('/home/yilisharcs/notes/LLM/cc-model-of-you.md', 'r')
        ---@diagnostic disable: need-check-nil
        local content = file:read('*all')
        file:close()
        return content
      end,
    },
    display = {
      chat = {
        intro_message = 'Hi, senpai!!! (˶˃ ᵕ ˂˶)',
        window = {
          opts = {
            signcolumn = 'no',
            number = false,
            relativenumber = false,
          },
        },
      },
    },
    strategies = {
      chat = {
        adapter = 'openrouter_deepseek',
        roles = {
          llm = 'Deepseek-chan',
        },
        keymaps = {
          send = {
            modes = { n = '<C-y>', i = '<C-y>' },
          },
          close = {
            modes = { n = '<ESC>' },
          },
        },
      },
      inline = {
        adapter = 'openrouter_deepseek'
      },
    },
    adapters = {
      openrouter_deepseek = function()
        return require('codecompanion.adapters').extend('openai_compatible', {
          env = {
            url = 'https://openrouter.ai/api',
            api_key = 'cmd:pass show llm/openrouter/key',
            chat_url = '/v1/chat/completions',
          },
          schema = {
            model = {
              default = 'deepseek/deepseek-r1:free',
            },
          },
        })
      end,
    },
  }
}

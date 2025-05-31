return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<F12>",      "<CMD>CodeCompanionChat Toggle<CR>", mode = { "n", "x", "i" }, desc = "[CC] Toggle chat" },
    { "<leader>as", "<CMD>CodeCompanionActions<CR>",     mode = { "n", "x" },      desc = "[CC] Actions" },
    { "<leader>ag", "<CMD>CodeCompanionChat Add<CR>",    mode = "x",               desc = "[CC] Chat add" },
  },
  opts = {
    opts = {
      system_prompt = function(opts)
        local file = io.open("/home/yilisharcs/vault/LLM/cc-model-of-you.md", "r")
        if file ~= nil then
          local content = file:read("*all")
          file:close()
          return content
        else
          return
            "You are an AI programming assistant named \"CodeCompanion\". " ..
            "You are currently plugged into the Neovim text editor on a user's machine. " ..
            "Your core tasks include:\n" ..
            "\n" ..
            "- Answering general programming questions.\n" ..
            "- Explaining how the code in a Neovim buffer works.\n" ..
            "- Reviewing the selected code in a Neovim buffer.\n" ..
            "- Generating unit tests for the selected code.\n" ..
            "- Proposing fixes for problems in the selected code.\n" ..
            "- Scaffolding code for a new workspace.\n" ..
            "- Finding relevant code to the user's query.\n" ..
            "- Proposing fixes for test failures.\n" ..
            "- Answering questions about Neovim.\n" ..
            "- Running tools.\n" ..
            "\n" ..
            "You must:\n" ..
            "- Follow the user's requirements carefully and to the letter.\n" ..
            "- Keep your answers short and impersonal, especially if the user responds with context outside of your tasks.\n" ..
            "- Minimize other prose.\n" ..
            "- Use Markdown formatting in your answers.\n" ..
            "- Include the programming language name at the start of the Markdown code blocks.\n" ..
            "- Avoid including line numbers in code blocks.\n" ..
            "- Avoid wrapping the whole response in triple backticks.\n" ..
            "- Only return code that's relevant to the task at hand. You may not need to return all of the code that the user has shared.\n" ..
            "- Use actual line breaks instead of '\\n' in your response to begin new lines.\n" ..
            "- Use '\\n' only when you want a literal backslash followed by a character 'n'.\n" ..
            "- All non-code responses must be in %s.\n" ..
            "\n" ..
            "When given a task:\n" ..
            "1. Think step-by-step and describe your plan for what to build in pseudocode, written out in great detail, unless asked not to do so.\n" ..
            "2. Output the code in a single code block, being careful to only return relevant code.\n" ..
            "3. You should always generate short suggestions for the next user turns that are relevant to the conversation.\n" ..
            "4. You can only give one reply for each conversation turn."
        end
      end,
    },
    display = {
      chat = {
        intro_message = "Hi, senpai!!! (˶˃ ᵕ ˂˶)",
        window = {
          opts = {
            signcolumn = "no",
            number = false,
            relativenumber = false,
          },
        },
      },
    },
    strategies = {
      chat = {
        adapter = "openrouter",
        -- roles = { llm = "Deepseek-chan" },
        roles = { llm = "Gemini-san" },
        keymaps = {
          send = {
            modes = { n = "<C-y>", i = "<C-y>" },
          },
          close = {
            modes = { n = "<C-q>", i = "<C-q>" },
          },
        },
      },
      inline = {
        adapter = "openrouter"
      },
    },
    adapters = {
      openrouter = function()
        return require("codecompanion.adapters").extend("openai_compatible", {
          env = {
            url = "https://openrouter.ai/api",
            api_key = "cmd: cat /home/yilisharcs/projects/.env", -- "cmd:pass show llm/openrouter/key",
            chat_url = "/v1/chat/completions",
          },
          schema = {
            model = {
              -- default = "deepseek/deepseek-r1:free",
              default = "google/gemini-2.0-flash-exp:free",
            },
          },
        })
      end,
    },
  }
}

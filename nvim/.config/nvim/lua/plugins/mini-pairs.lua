return {
  "echasnovski/mini.pairs", -- see `:h MiniPairs.config`.
  version = false,
  event = { "InsertEnter", "CmdlineEnter", "CmdwinEnter" },
  opts = {
    modes = { insert = true, command = true, terminal = false },
    mappings = {
      ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\].", register = { bs = true, cr = true } },
      ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\].", register = { bs = true, cr = true } },
      ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\].", register = { bs = true, cr = true } },

      ["<"] = { action = "open", pair = "<>", neigh_pattern = "[^ \\].", register = { bs = true } },
      [">"] = { action = "close", pair = "<>", neigh_pattern = "[^\\]." },
      ["|"] = { action = "closeopen", pair = "||", neigh_pattern = "[\\{\\][}]", register = { bs = true } },     -- closures
      ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a&<\\][^>]", register = { cr = false } }, -- lifetimes
      ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^%a\\].", register = { cr = false } },
    }
  },
  config = function(_, opts)
    require("mini.pairs").setup(opts)

    local map_bs = function(lhs, rhs)
      vim.keymap.set("i", lhs, rhs, { expr = true, replace_keycodes = false })
    end

    map_bs("<C-h>", "v:lua.MiniPairs.bs()")
    map_bs("<C-w>", "v:lua.MiniPairs.bs('\23')")
    map_bs("<C-u>", "v:lua.MiniPairs.bs('\21')")

    vim.cmd([[
      augroup Cmdlinewin_No_Pairs
        au!
        au CmdwinEnter * lua vim.b.minipairs_disable = true
      augroup END
    ]])
  end
}

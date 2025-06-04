return {
  "saghen/blink.cmp",
  dependencies = { "rafamadriz/friendly-snippets" },
  version = "1.*",
  opts = {
    keymap = {
      preset = "none",
      ["<C-k>"] = { "show", "show_documentation", "hide_documentation", "fallback" },
      ["<C-l>"] = { "hide", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      ["<C-q>"] = { "snippet_backward", "fallback" },
      ["<C-j>"] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          else
            return cmp.select_and_accept()
          end
        end,
        "snippet_forward",
        "fallback"
      },
    },
    cmdline = { keymap = { preset = "inherit" } },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = false },
      ghost_text = {
        enabled = function()
          return not vim.tbl_contains({
            "markdown",
            "gitcommit",
          }, vim.bo.filetype)
        end
      },
      menu = {
        auto_show = false,
        draw = {
          treesitter = { "lsp" },
          components = {
            kind_icon = {
              text = function(ctx) return " " .. ctx.kind_icon .. ctx.icon_gap .. " " end
            },
            item_idx = {
              text = function(ctx)
                return tostring(ctx.idx)
              end
            },
          },
          columns = {
            {
              "item_idx",
              "label",
              "label_description",
              gap = 1,
            },
            {
              "kind_icon",
              "kind",
              "source_name",
              gap = 1
            }
          },
        }
      },
    },
    fuzzy = {
      sorts = {
        "exact",
        "score",
        "sort_text"
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        -- recipe for writers
        buffer = {
          -- keep case of first char
          transform_items = function(a, items)
            local keyword = a.get_keyword()
            local correct, case
            if keyword:match("^%l") then
              correct = "^%u%l+$"
              case = string.lower
            elseif keyword:match("^%u") then
              correct = "^%l+$"
              case = string.upper
            else
              return items
            end

            -- avoid duplicates from the corrections
            local seen = {}
            local out = {}
            for _, item in ipairs(items) do
              local raw = item.insertText
              if raw:match(correct) then
                local text = case(raw:sub(1, 1)) .. raw:sub(2)
                item.insertText = text
                item.label = text
              end
              if not seen[item.insertText] then
                seen[item.insertText] = true
                table.insert(out, item)
              end
            end
            return out
          end
        },
      },
    },
  },
  opts_extend = { "sources.default" },
  init = function()
    local capabilities = {
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true
        },
        semanticTokens = {
          multilineTokenSupport = true,
        }
      }
    }
    capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

    vim.lsp.config("*", {
      root_markers = { ".git", ".jj" },
      capabilities = capabilities,
    })
  end
}

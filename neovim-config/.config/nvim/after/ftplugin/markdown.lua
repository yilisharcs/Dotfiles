vim.bo.commentstring = "<!-- %s -->"
vim.opt_local.iskeyword:append({ "-", "'" }) -- NOTE: vim.opt/_local/_global will be deprecated by v1.0
vim.bo.suffixesadd = ".md,.lemon"
vim.wo[0][0].colorcolumn = "0"
vim.wo[0][0].list = false
vim.wo[0][0].relativenumber = false
vim.wo[0][0].wrap = true

-- Make time heading for zk
vim.keymap.set("n", "<F2>", "G{{O<CR>### <C-r>=strftime('%H:%M')<CR><CR>", { silent = true })

-- mini doesn't surround a line with newlines
vim.b.minisurround_config = {
        respect_selection_type = false,
}

-- -- Section-aware tag jumps for markdown
-- local normalize_headers = function()
--         local headings = {}
--         -- FIXME: This only works due to modifications I made to core
--         -- neovim. Should do a pull request soon to have those merged,
--         -- if not for having the code below added too.
--         for _, v in ipairs(require("vim.treesitter._headings").get_headings(0)) do
--                 local lnum, text, level = v.lnum, v.text, v.level
--                 text = text:lower()               -- Case
--                 text = text:gsub("[^%w%s%-]", "") -- Non-alphanumeric
--                 text = text:gsub("^%s+", "")      -- Leading whitespace
--                 text = text:gsub("%s+$", "")      -- Trailing whitespace
--                 text = text:gsub("[%s\t]+", "-")  -- Collapse spaces/tabs
--                 text = text:gsub("%-+", "-")      -- Collapse dashes
--                 headings[#headings + 1] = { lnum = lnum, text = text, indent = level + 1 }
--         end
--         return headings
-- end
--
-- vim.api.nvim_create_autocmd({
--         "BufEnter",
--         "TextChanged",
--         "TextChangedI",
-- }, {
--         group = vim.api.nvim_create_augroup("Markdown_Headings_Tags", { clear = true }),
--         pattern = { "*.md", "*.markdown" },
--         callback = function()
--                 vim.b.markdown_headings = normalize_headers()
--         end
-- })
--
-- -- FIXME: It'd be mighty nice if this could fallback to the
-- -- default behavior if a section link isn't under the cursor
-- vim.keymap.set("n", "<leader><C-]>", function()
--         local ts_utils = require("nvim-treesitter.ts_utils")
--
--         local node = ts_utils.get_node_at_cursor()
--         while node and node:type() ~= "inline_link" do
--                 node = node:parent()
--         end
--         if not node then
--                 vim.notify("Not a section link", vim.log.levels.ERROR)
--                 return
--         end
--
--         local link_destination = 4
--         local text = vim.treesitter.get_node_text(node:child(link_destination), 0):sub(2)
--
--         for _, v in ipairs(vim.b.markdown_headings) do
--                 if text == v.text then
--                         local lnum, col = unpack(vim.api.nvim_win_get_cursor(0))
--                         local bufnr = vim.api.nvim_get_current_buf()
--                         local winid = vim.api.nvim_get_current_win()
--
--                         local items = { {
--                                 bufnr = bufnr,
--                                 from = { bufnr, lnum, col + 1, 0 },
--                                 -- matchnr = 0,
--                                 tagname = v.text,
--                         } }
--
--                         vim.fn.settagstack(winid, { items = items }, "t")
--                         vim.api.nvim_win_set_cursor(0, { v.lnum, v.indent })
--                         return
--                 end
--         end
--         vim.notify("Section not found", vim.log.levels.WARN)
-- end, { buffer = true, silent = true, desc = "Jump to section heading under cursor" })

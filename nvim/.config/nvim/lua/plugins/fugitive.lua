return {
  "tpope/vim-fugitive",
  cmd = {
    "Git",
    "Gread",
    "Gwrite",
  },
  keys = {
    { "<leader>gb", "<CMD>Git blame<CR>",     desc = "[Git] Blame" },
    { "<leader>gd", "<CMD>Gvdiffsplit<CR>",   desc = "[Git] Diff file" },
    { "<leader>gD", "<CMD>Git difftool<CR>",  desc = "[Git] Difftool" },
    { "<leader>gm", "<CMD>Git mergetool<CR>", desc = "[Git] Mergetool" },
    { "<leader>gl", "<CMD>0Gclog<CR>",        desc = "[Git] File history" },
    { "<leader>gL", "<CMD>Gclog<CR>",         desc = "[Git] Repo history" },
  },
  init = function()
    vim.g.fugitive_summary_format = "%an | %s"

    function _G.qfxfugitive(info)
      local items
      local ret = {}
      if info.quickfix == 1 then
        items = vim.fn.getqflist({ id = info.id, items = 0 }).items
      end
      local validFmt = " %s || %s"
      for i = info.start_idx, info.end_idx do
        local e = items[i]
        local mod = e.module:sub(0, 7) -- commit hash
        local str = validFmt:format(mod, e.text)
        table.insert(ret, str)
      end
      return ret
    end

    local Qfx_Format = vim.api.nvim_create_augroup("Qfx_Format", { clear = true })
    vim.api.nvim_create_autocmd({ "QuickFixCmdPre", "QuickFixCmdPost" }, {
      desc     = "Post Fugitive quickfix format",
      group    = Qfx_Format,
      callback = function()
        local qf_title = vim.fn.getqflist({ title = 1 }).title
        if qf_title:match("Gclog") then
          vim.o.qftf = "{info -> v:lua._G.qfxfugitive(info)}"
        else
          vim.o.qftf = "{info -> v:lua._G.qfx(info)}"
        end
      end
    })
  end
}

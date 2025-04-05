return {
  {
    'tpope/vim-fugitive',
    event = 'CmdlineEnter',
    keys = {
      { '<leader>gq', '<CMD>Git<CR>' },
      { '<leader>gb', '<CMD>Git blame<CR>' },
      { '<leader>gd', '<CMD>Gvdiffsplit<CR>' },
      { '<leader>gD', '<CMD>Git difftool<CR>' },
      { '<leader>gl', '<CMD>0Gclog<CR>',      desc = '[GIT] File Log' },
      { '<leader>gL', '<CMD>Gclog<CR>',       desc = '[GIT] Repo Log' },
    },
    init = function()
      vim.g.fugitive_summary_format = '%an | %s'

      function _G.qfxfugitive(info)
        local items
        local ret = {}
        if info.quickfix == 1 then
          items = vim.fn.getqflist({ id = info.id, items = 0 }).items
        end
        local validFmt = ' %s | %s'
        for i = info.start_idx, info.end_idx do
          local e = items[i]
          local mod = e.module:sub(0, 7) -- commit hash
          local str = validFmt:format(mod, e.text)
          table.insert(ret, str)
        end
        return ret
      end

      local Qfx_Format = vim.api.nvim_create_augroup('Qfx_Format', { clear = true })
      vim.api.nvim_create_autocmd({ 'QuickFixCmdPre', 'QuickFixCmdPost' }, {
        desc     = 'Post Fugitive quickfix format',
        group    = Qfx_Format,
        callback = function()
          local qf_title = vim.fn.getqflist({ title = 1 }).title
          if qf_title:match('Gclog') then
            vim.o.qftf = '{info -> v:lua._G.qfxfugitive(info)}'
          else
            vim.o.qftf = '{info -> v:lua._G.qfx(info)}'
          end
        end,
      })

      vim.cmd([[
        augroup Fugit_Tab
          au!
          au Filetype fugitive nmap <buffer> <C-i> =
          au Filetype gitcommit startinsert
          " This ensures the vim-grepper qflist will be formatted correctly
          au User Grepper exe "lua vim.o.qftf = '{info -> v:lua._G.qfx(info)}'" | copen
        augroup END
      ]])
    end
  }
}

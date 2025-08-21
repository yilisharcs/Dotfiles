return {
  "echasnovski/mini.bufremove", -- see `:h MiniBufremove.config`.
  version = false,
  keys = {
    {
      "<M-q>",
      function()
        vim.cmd([[
          func! s:focusable_wins() abort
            return filter(nvim_tabpage_list_wins(0), {k,v-> !!nvim_win_get_config(v).focusable})
          endf

          if 1 == len(s:focusable_wins()) || &buftype == 'terminal' || &filetype == 'help'
            bdelete!
          else
            lua require('mini.bufremove').delete()
          endif
        ]])
      end,
      desc = "[MINI] Delete buffer"
    }
  }
}

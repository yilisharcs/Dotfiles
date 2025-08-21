return {
  "justinmk/vim-sneak",
  dependencies = { { "yilisharcs/vim-repeat", branch = "maparg" } },
  init = function()
    vim.g["sneak#use_ic_scs"] = 1
    vim.cmd([[
      augroup Sneak_Insert_HL
        au!
        au InsertEnter * hi Sneak NONE
        au ColorScheme,InsertLeave * hi Sneak guifg=White guibg=Magenta
        au TermOpen * hi SneakScope guibg=Black
      augroup END
    ]])
  end,
  keys = {
    { "s", "<Plug>Sneak_s", mode = { "n", "x" } },
    { "S", "<Plug>Sneak_S", mode = { "n", "x" } },
    { "z", "<Plug>Sneak_s", mode = "o" },
    { "Z", "<Plug>Sneak_S", mode = "o" },
    { "f", "<Plug>Sneak_f", mode = { "n", "x", "o" } },
    { "F", "<Plug>Sneak_F", mode = { "n", "x", "o" } },
    { "t", "<Plug>Sneak_t", mode = { "n", "x", "o" } },
    { "T", "<Plug>Sneak_T", mode = { "n", "x", "o" } },
  }
}

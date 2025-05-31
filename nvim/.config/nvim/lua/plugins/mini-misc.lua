return {
  "echasnovski/mini.misc", -- see `:h MiniMisc.config`.
  version = false,
  event = "BufReadPost [^:]*",
  config = function()
    require("mini.misc").setup_auto_root({ ".git", ".jj", "Makefile" })
    require("mini.misc").setup_restore_cursor({ center = false })
  end
}

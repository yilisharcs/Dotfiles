return {
  {
    'echasnovski/mini.misc', -- see `:h MiniMisc.config`.
    version = false,
    event = { 'BufReadPre' },
    config = function()
      require('mini.misc').setup()
      require('mini.misc').setup_auto_root({ '.git', 'Makefile', 'Cargo.toml', 'index.md', 'index.html', 'mod.json' })
      require('mini.misc').setup_restore_cursor({ center = false })
    end
  },
}

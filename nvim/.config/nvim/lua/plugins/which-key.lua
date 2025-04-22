return {
  {
    'folke/which-key.nvim',
    event = { 'CursorHold' },
    opts = {
      plugins = {
        -- Disabled due to a split-second slowdown while querying
        -- the registers with the wayland clipboard provider
        registers = false,
      }
    }
  }
}

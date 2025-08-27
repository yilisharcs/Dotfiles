return {
  "RaafatTurki/hex.nvim",
  event = "BufReadPre",
  opts = {
    dump_cmd = "xxd -g 1 -u", -- cli command used to dump hex data
    assemble_cmd = "xxd -r",  -- cli command used to assemble from hex data
  }
}

return {
  cmd = { "ra-multiplex" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml" },
  settings = {
    ["rust_analyzer"] = {
      cargo = { allFeatures = true }
    }
  }
}

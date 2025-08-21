return {
  cmd = { "ra-multiplex" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml" },
  settings = {
    ["rust_analyzer"] = {
      cargo = { allFeatures = true },
      check = {
        overrideCommand = {
          "cargo",
          "clippy",
          "--fix",
          "--allow-dirty",
          "--message-format=json-diagnostic-rendered-ansi",
        }
      }
    }
  }
}

return {
  {
    'Saecki/crates.nvim',
    event = { 'BufEnter Cargo.toml' },
    config = function()
      local crates = require('crates')

      crates.setup({
        lsp = {
          enabled = true,
          on_attach = function(client, bufnr)
            require('lsp-format').on_attach(client, bufnr)
          end,
          actions = true,
          completion = true,
          hover = true,
        },
        completion = {
          crates = {
            enabled = true,  -- disabled by default
            max_results = 8, -- The maximum number of search results to display
            min_chars = 3,   -- The minimum number of charaters to type before completions begin appearing
          },
        }
      })

      local map = function(mode, lhs, rhs, desc)
        if desc then
          desc = '[CRATES] ' .. desc
        end
        vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
      end

      -- Default keymaps
      map('n', '<leader>ct', crates.toggle, 'Toggle')
      map('n', '<leader>cr', crates.reload, 'Reload')

      map('n', '<leader>cv', crates.show_versions_popup, 'Show Versions Popup')
      map('n', '<leader>cf', crates.show_features_popup, 'Show Features Popup')
      map('n', '<leader>cd', crates.show_dependencies_popup, 'Show Dependencies Popup')

      map('n', '<leader>cu', crates.update_crate, 'Update Crate')
      map('v', '<leader>cu', crates.update_crates, 'Update Crates')
      map('n', '<leader>ca', crates.update_all_crates, 'Update All Crates')
      map('n', '<leader>cU', crates.upgrade_crate, 'Upgrade Crate')
      map('v', '<leader>cU', crates.upgrade_crates, 'Upgrade Crates')
      map('n', '<leader>cA', crates.upgrade_all_crates, 'Upgrade All Crates')

      map('n', '<leader>cx', crates.expand_plain_crate_to_inline_table, 'Expand Plain Crate to Inline Table')
      map('n', '<leader>cX', crates.extract_crate_into_table, 'Extract Crate into Table')

      map('n', '<leader>cH', crates.open_homepage, 'Open Homepage')
      map('n', '<leader>cR', crates.open_repository, 'Open Repository')
      map('n', '<leader>cD', crates.open_documentation, 'Open Documentation')
      map('n', '<leader>cC', crates.open_crates_io, 'Open *crates.io*')
      map('n', '<leader>cL', crates.open_lib_rs, 'Open *lib.rs*')
    end
  }
}

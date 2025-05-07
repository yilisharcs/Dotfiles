return {
  'stevearc/oil.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  lazy = false,
  opts = {
    default_file_explorer = false,
    columns = {
      'icon',
      'permissions',
      'size',
      'mtime',
    },
    win_options = {
      signcolumn = 'yes:1',
      number = false,
      relativenumber = false,
    },
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    prompt_save_on_select_new_entry = true,
    lsp_file_methods = { enabled = false },
    constrain_cursor = 'editable',
    watch_for_changes = true,
    keymaps = {
      ['<leader>fd'] = {
        function()
          require('fzf-lua').files({
            cwd = require('oil').get_current_dir()
          })
        end,
        mode = 'n',
        nowait = true,
        desc = 'Find files from current directory'
      },
      ['<leader>;'] = {
        'actions.open_cmdline',
        opts = {
          shorten_path = true,
          modify = ':h',
        },
        desc = 'Enter cmdline with the current directory as an argument',
      },
    },
    view_options = {
      show_hidden = true,
      is_always_hidden = function(name)
        return name == ".."
      end,
    }
  }
}

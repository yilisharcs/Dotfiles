return {
  {
    'ibhagwan/fzf-lua',
    keys = {
      { '<leader>fl', function() require('fzf-lua').files() end },
      { '<leader>fh', function() require('fzf-lua').oldfiles() end },
      { '<leader>fb', function() require('fzf-lua').buffers() end },
      { '<leader>fc', function() require('fzf-lua').git_commits() end },
      { '<leader>fk', function() require('fzf-lua').helptags() end },
      {
        '<C-x><C-f>',
        function()
          require('fzf-lua').complete_path({
            cmd = 'fd --color=never --hidden --follow --exclude .git'
          })
        end,
        mode = 'i',
        desc = '[FZF] Complete Path'
      },
    },
    opts = {
      'max-perf',
      keymap = {
        builtin = {
          ['<C-k>'] = 'preview-page-up',
          ['<C-j>'] = 'preview-page-down',
          ['<F1>'] = 'toggle-help',
          ['<F2>'] = 'toggle-fullscreen',
          ['<F4>'] = 'toggle-preview',
        },
        fzf = {
          ['ctrl-y'] = 'select-all+accept',
          ['alt-a'] = 'toggle-all',
          ['alt-g'] = 'last',
          ['alt-G'] = 'first',
        },
      },
      winopts = {
        height   = 0.80,
        width    = 0.90,
        row      = 0.50,
        col      = 0.55,
        border   = 'rounded',
        backdrop = 100,
        preview  = { border = 'border-left' },
      },
      previewers = {
        bat = { theme = 'ansi' },
      },
      files = {
        fd_opts = '--color=never --hidden --follow --type f --type l --exclude .git',
      },
      grep = {
        rg_opts = '--color=never --hidden --vimgrep --smart-case -g "!.git" --max-columns=4096 -e',
      },
      helptags = {
        winopts = { height = 0.3 },
      },
    },
  }
}

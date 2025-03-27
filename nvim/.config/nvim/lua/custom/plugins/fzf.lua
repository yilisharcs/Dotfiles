return {
  {
    'ibhagwan/fzf-lua',
    keys = {
      { '<leader>fd', function() require('fzf-lua').files({ cwd = '~/' }) end, desc = '[FZF] Find from $HOME' },
      { '<leader>fl', function() require('fzf-lua').files() end,               desc = '[FZF] Find from $CWD' },
      { '<leader>fh', function() require('fzf-lua').oldfiles() end,            desc = '[FZF] File History' },
      { '<leader>fb', function() require('fzf-lua').buffers() end,             desc = '[FZF] List Buffers' },
      { '<leader>fg', function() require('fzf-lua').git_files() end,           desc = '[FZF] Git Files' },
      { '<leader>fc', function() require('fzf-lua').git_commits() end,         desc = '[FZF] Git Commits' },
      { '<leader>fa', function() require('fzf-lua').live_grep_native() end,    desc = '[FZF] Live Grep' },
      { '<leader>ft', function() require('fzf-lua').tags_live_grep() end,      desc = '[FZF] Tags Grep' },
      { '<leader>fk', function() require('fzf-lua').helptags() end,            desc = '[FZF] Help Tags' },
      {
        '<C-x><C-f>',
        function()
          require('fzf-lua').complete_path({
            cmd = 'fd --color=never --hidden --follow --ignore-case --type \
            file --exclude={.cache,.git,.npm,.oh-my-zsh,src}',
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
        fd_opts = '--color=never --hidden --follow --no-ignore --ignore-case --type file ' ..
            '--exclude={target/*,.cache,.git,Trash-Linux,Trash-Windows,.local/share,.local/state,$HOME/.config,.oh-my-zsh}',
      },
      grep = {
        rg_opts = '--color=never --hidden --follow --vimgrep --sort path --smart-case ' ..
            "-g '!{target/*,.cache,.git,Trash-Linux,Trash-Windows,.local/share,.local/state,$HOME/.config,.oh-my-zsh}/'",
        filter = "rg --invert-match '\\.gitignore'",
        silent = true,
      },
      helptags = {
        preview_opts = 'hidden',
        winopts = { height = 0.3 },
      },
    },
  }
}

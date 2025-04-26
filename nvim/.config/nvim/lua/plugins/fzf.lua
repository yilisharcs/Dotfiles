return {
  {
    'ibhagwan/fzf-lua',
    keys = {
      { '<leader>fl', function() require('fzf-lua').files() end,                             desc = '[FZF] Files' },
      { '<leader>fh', function() require('fzf-lua').oldfiles() end,                          desc = '[FZF] History' },
      { '<leader>fb', function() require('fzf-lua').buffers() end,                           desc = '[FZF] Buffers' },
      { '<leader>fc', function() require('fzf-lua').git_commits() end,                       desc = '[FZF] Commits' },
      { '<leader>fg', function() require('fzf-lua').live_grep_native({ silent = true }) end, desc = '[FZF] Live grep' },
      { '<leader>fk', function() require('fzf-lua').helptags() end,                          desc = '[FZF] Help tags' },
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
      { '<C-Space>g', '<CMD>lua _G.fzf_dirs()<CR>', desc = '[FZF] New project tab' },
    },
    init = function()
      _G.fzf_dirs = function(opts)
        opts = opts or {}
        -- opts.prompt = '> '
        opts.actions = {
          ['default'] = function(selected)
            vim.cmd('tabnew ' .. selected[1])
            vim.cmd('tcd ' .. selected[1])
          end
        }
        local dirs = {
          '~/projects/',
          '~/projects/nvim',
          '~/opt',
          '~/.local/share/nvim/lazy',
          '~/'
        }
        require('fzf-lua').fzf_exec(
          'fd --hidden --follow --type d --exact-depth 1 . ' ..
          table.concat(dirs, ' '), opts
        )
      end
    end,
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

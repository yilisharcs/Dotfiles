return {
  {
    'mhinz/vim-grepper',
    event = 'CmdlineEnter',
    keys = {
      { 'gs', '<Plug>(GrepperOperator)', mode = { 'n', 'x' } }
    },
    init = function()
      vim.cmd([[
        let g:grepper = {}
        let g:grepper.highlight = 1
        let g:grepper.quickfix = 1
        let g:grepper.switch = 0
        let g:grepper.jump = 1
        let g:grepper.tools = ['git', 'rg']
        let g:grepper.rg = {
          \ 'grepprg':    'rg --vimgrep -uu',
          \ 'grepformat': '%f:%l:%c:%m',
          \ 'escape':     '\^$.*[]',
        \ }
        let g:grepper.operator = {
          \ 'prompt': 0,
          \ 'tools': ['rg'],
        \ }

        cnoreabbrev <expr> grep (getcmdtype() ==# ':' && getcmdline() =~# '^grep') ? 'GrepperRg' : 'grep'
        cnoreabbrev <expr> ggrep (getcmdtype() ==# ':' && getcmdline() =~# '^ggrep') ? 'GrepperGit' : 'ggrep'
      ]])
    end
  }
}

return {
  {
    'mhinz/vim-grepper',
    event = 'VeryLazy',
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

        nmap gs <plug>(GrepperOperator)
        xmap gs <plug>(GrepperOperator)
        cnoreabbrev <expr> grep (getcmdtype() ==# ':' && getcmdline() =~# '^grep') ? 'GrepperRg' : 'grep'
      ]])
    end
  }
}

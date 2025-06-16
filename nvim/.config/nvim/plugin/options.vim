" Include config dirs
set path+=.dotfiles/**1/.config/**;,.dotfiles/**1;

" " NOTE: https://github.com/pop-os/cosmic-comp/issues/1181
" " Sync clipboard between OS and Neovim.
" set clipboard+=unnamedplus
" let g:clipboard='xclip'

set ignorecase
set smartcase

" Indenting
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smartindent

set nowrap
set linebreak

" Long-running undo trees
set noswapfile
set undofile

set scrolloff=4
set sidescrolloff=4

set number
set relativenumber

" Hide search finish warning
set shortmess+=s

" Proper splits
set splitright
set splitbelow

" Indentation guide
set list
set listchars=tab:› ,nbsp:␣,space:•

" Fold opts
set foldcolumn=0
set foldmethod=indent
set foldlevel=99

" Column opts
set numberwidth=3
set signcolumn=yes:1
set statuscolumn=%l%s

set isfname+=@-@

let &pumheight=float2nr(&lines * 0.25 + 0.5)
set completeopt=noinsert,menuone,popup,fuzzy

" Ctrl-a/x doesn't recognize signed numbers
set nrformats+=unsigned

" No more ~ on empty buffer space
let &fillchars='eob: '

set guicursor=a:block,c-ci-i-r:blinkwait700-blinkoff700-blinkon700

set diffopt^=algorithm:patience

set cursorline
set cursorlineopt=number

let &grepprg='rg --vimgrep'

" Terminal scrollback
set scrollback=100000

set updatetime=1000
set termguicolors
set virtualedit=block
set winborder=rounded
set inccommand=split

" Nushell doesn't grok vi
let &shell=exepath('bash')

colorscheme lunamia

" Include config dirs
set path+=.dotfiles/**1/.config/**;,.dotfiles/**1;
set path+=.scripts/.local/**;

" Sync clipboard between OS and Neovim.
set clipboard+=unnamedplus

set ignorecase
set smartcase

" Indenting
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent

set nowrap

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
set listchars=tab:› ,nbsp:␣

" Column opts
set numberwidth=3
set foldcolumn=2
set foldmethod=indent
set signcolumn=yes:1
set statuscolumn=%C%l%s

set isfname+=@-@

let &pumheight=float2nr(&lines * 0.25 + 0.5)
set completeopt=menuone,popup,fuzzy

" Ctrl-a/x doesn't recognize signed numbers
set nrformats+=unsigned

" No more ~ on empty buffer space
let &fillchars='eob: '

set guicursor=a:block,c-ci-i-r:blinkwait700-blinkoff700-blinkon700

" Nushell doesn't grok vi
set shell=/bin/bash

set diffopt^=algorithm:patience

set updatetime=1000
set termguicolors
set lazyredraw
set winborder=rounded

" Include config dirs
set path+=.dotfiles/**1/.config/**;,.dotfiles/**1;
set path+=.scripts/.local/**;

" Sync clipboard between OS and Neovim.
set clipboard+=unnamedplus

" Case-insensitive searching unless \C or capital in search
set ignorecase
set smartcase

" Indenting
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent

" Disables line wrapping
set nowrap

" Long-running undo trees
set noswapfile
set undofile

" Scroll opts
set scrolloff=4
set sidescrolloff=4

" Number opts
set number
set relativenumber

" Hide search finish warning
set shortmess+=s

" Proper split configuration
set splitright
" set splitbelow

" Grep and quickfix opts
let &grepprg='rg --vimgrep --sort=path'

" Indentation guide
set list
set listchars=tab:› ,nbsp:␣

" Column opts
set signcolumn=yes
set foldenable

" Detects @ on file name
set isfname+=@-@

" Completion menu height based on screen space
let &pumheight=float2nr(&lines * 0.25 + 0.5)

" Ctrl-a/x doesn't recognize signed numbers
set nrformats+=unsigned

" No more ~ on empty buffer space
let &fillchars='eob: '

" Cursor animation
set guicursor=a:block,c-ci-i-r:blinkwait700-blinkoff700-blinkon700

" Nushell integration
let &shellpipe='| tee { save %s }'
let &shellredir='o> %s'

" Miscellaneous
set updatetime=1000
set termguicolors
set lazyredraw

" Defaults
set nobackup
set hlsearch
set incsearch
set ruler
set timeout
set autoread
set noequalalways

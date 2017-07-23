" color scheme
syntax on
colorscheme pablo
set bg=dark
set history=1000

" general
set backspace=indent,eol,start
set cursorline
set nocompatible
set nolist
set nowrap
set numberwidth=5
set ruler
set scrolloff=5
set showcmd
set showmatch
set showmode
set laststatus=2
set autoread

" filetype support
filetype plugin indent on

" colorcolumn
set colorcolumn=80
hi ColorColumn ctermfg=0
hi ColorColumn ctermbg=7
hi LineNr ctermfg=black ctermbg=darkgrey

" trun off annoyed swap files
set noswapfile
set nobackup
set nowritebackup

" indention
set autoindent
set smartindent
set cindent

" tabs
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4

" search
set nohlsearch
set ignorecase
set incsearch
set smartcase

" misc
set noerrorbells
set novisualbell

" encoding
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,big5,latin1,euc-jp,gbk,euc-kr,utf-bom,iso8859-1
set encoding=utf-8
set tenc=utf-8

" always treat *.md as markdown file
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" always treat Dockerfile.* as Dockerfile
autocmd BufNewFile,BufReadPost Dockerfile.* set filetype=dockerfile

" always treat Jenkinsfile as groovy file
autocmd BufNewFile,BufReadPost Jenkinsfile set filetype=groovy

" ignore files
set wildignore+=*.so,*.swp,*.zip,*.exe,*.pyc,*.pyo

" setting up vundle
let vundle_readme=expand('~/.vim/bundle/Vundle.vim/README.md')
if !filereadable(vundle_readme)
  echo "Installing Vundle.."
  echo ""
  silent !mkdir -p ~/.vim/bundle
  silent !git clone https://github.com/VundleVim/Vundle.vim ~/.vim/bundle/Vundle.vim
  !vim +BundleInstall +qall
endif
set rtp+=~/.vim/bundle/Vundle.vim

" setup plugins
call vundle#begin()
  Plugin 'VundleVim/Vundle.vim'

  Plugin 'vim-airline/vim-airline'
  Plugin 'vim-airline/vim-airline-themes'

  Plugin 'tpope/vim-fugitive'
  Plugin 'airblade/vim-gitgutter'
  Plugin 'tpope/vim-git'
  Plugin 'tpope/vim-endwise'
  Plugin 'mhinz/vim-signify'
  Plugin 'Yggdroot/indentLine'

  Plugin 'ctrlpvim/ctrlp.vim'
  Plugin 'scrooloose/nerdtree'
  Plugin 'Shougo/neocomplete.vim'
  Plugin 'tomtom/tcomment_vim'

  Plugin 'fatih/vim-go'
  Plugin 'nvie/vim-flake8'
  Plugin 'hdima/python-syntax'
  Plugin 'plasticboy/vim-markdown'
  Plugin 'vim-ruby/vim-ruby'
call vundle#end()

set pastetoggle=<F9>

" <Ctrl-N> NERDTREE Toggle
:map <silent> <C-n> :NERDTreeToggle<CR>

" <F6>: toggle on/off syntax highlighting
:map <silent> <F6> :if exists("g:syntax_on") <Bar>
     \       syntax off <Bar>
     \     else <Bar>
     \       syntax on <Bar>
     \       hi ColorColumn ctermbg=7 <Bar>
     \     endif <CR>

" manual setup required (macOS):
" 1. wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
" 2. install PowerlineSymbols
" 3. setup non-ASCII font
"
" reference:
" - https://powerline.readthedocs.io/en/latest/installation.html#fonts-installation
let g:airline_powerline_fonts = 1

let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1

let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.git|\.hg|\.svn|node_modules)$',
  \ 'file': '\v\.(exe|so|dll|pyc|DS_Store)$',
  \ }

let NERDTreeIgnore = ['\.pyc$', '\.pyo$']

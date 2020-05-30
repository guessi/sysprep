" color scheme
syntax on
colorscheme pablo
set bg=dark
set history=1000

" general
set backspace=indent,eol,start
set nocursorline
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
set viminfo=""

" filetype support
filetype plugin indent on

" colorcolumn
set colorcolumn=80

" highlight
hi ColorColumn ctermfg=150  ctermbg=236
hi LineNr      ctermfg=111  ctermbg=256
hi DiffAdd     ctermfg=NONE ctermbg=22  cterm=BOLD
hi DiffDelete  ctermfg=NONE ctermbg=52  cterm=BOLD
hi DiffChange  ctermfg=NONE ctermbg=23  cterm=BOLD
hi DiffText    ctermfg=NONE ctermbg=23  cterm=BOLD

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
set clipboard=unnamed

" encoding
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,big5,latin1,euc-jp,gbk,euc-kr,utf-bom,iso8859-1
set encoding=utf-8
set tenc=utf-8

" always treat *.md as markdown file
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" always treat Dockerfile.* as Dockerfile
autocmd BufNewFile,BufReadPost Dockerfile* set filetype=dockerfile

" always treat Jenkinsfile as groovy
autocmd BufNewFile,BufReadPost Jenkinsfile* set filetype=groovy

" always treat *.tf{vars,state} as terraform
autocmd BufNewFile,BufReadPost */playbooks/*.yml set filetype=yaml.ansible
autocmd BufNewFile,BufReadPost */playbooks/*.yaml set filetype=yaml.ansible
autocmd BufNewFile,BufReadPost */roles/*.yml set filetype=yaml.ansible
autocmd BufNewFile,BufReadPost */roles/*.yaml set filetype=yaml.ansible

" always treat *.tf{vars,state} as terraform
autocmd BufNewFile,BufReadPost *.tf set filetype=terraform
autocmd BufNewFile,BufReadPost *.tfvars set filetype=terraform
autocmd BufNewFile,BufReadPost *.tfstate set filetype=terraform

" always treat *.ts as javascript file
autocmd BufNewFile,BufReadPost *.ts set filetype=javascript

" always treat *.jsonnet as terraform
autocmd BufNewFile,BufReadPost *.jsonnet set filetype=jsonnet

" always treat Makefile* as make file
autocmd BufNewFile,BufReadPost Makefile* set filetype=make

" don't expand tab for filetype = make
autocmd FileType make set noexpandtab

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
  " basic
  Plugin 'VundleVim/Vundle.vim'

  " theme
  Plugin 'vim-airline/vim-airline'
  Plugin 'vim-airline/vim-airline-themes'

  " git
  Plugin 'airblade/vim-gitgutter'
  Plugin 'mhinz/vim-signify'
  Plugin 'tpope/vim-endwise'
  Plugin 'tpope/vim-fugitive'
  Plugin 'tpope/vim-git'

  " useful plugins
  Plugin 'Xuyuanp/nerdtree-git-plugin'
  Plugin 'ctrlpvim/ctrlp.vim'
  Plugin 'scrooloose/nerdtree'
  Plugin 'tomtom/tcomment_vim'
  Plugin 'ervandew/supertab'
  Plugin 'junegunn/vim-easy-align'

  " syntax highlighting
  Plugin 'fatih/vim-go'
  Plugin 'hashivim/vim-terraform'
  Plugin 'hashivim/vim-packer'
  Plugin 'hdima/python-syntax'
  Plugin 'nvie/vim-flake8'
  Plugin 'pearofducks/ansible-vim'
  Plugin 'plasticboy/vim-markdown'
  Plugin 'vim-ruby/vim-ruby'
  Plugin 'google/vim-jsonnet'
call vundle#end()

set pastetoggle=<F9>

" <Ctrl-N> NERDTREE Toggle
" <Ctrl-w-w> to switch between panels
" - https://stackoverflow.com/a/25254470
:map <silent> <C-n> :NERDTreeToggle<CR>

" <F6>: toggle on/off syntax highlighting
:map <silent> <F6> :if exists("g:syntax_on") <Bar>
     \       syntax off <Bar>
     \     else <Bar>
     \       syntax on <Bar>
     \       hi ColorColumn ctermbg=7 <Bar>
     \     endif <CR>

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

nmap <silent> gb :Gblame<CR>

" manual setup required (macOS):
" 1. open https://github.com/powerline/fonts
" 2. download and install 'DejaVu Sans Mono for Powerline'
" 3. setup non-ASCII font
"
" reference:
" - https://powerline.readthedocs.io/en/latest/installation.html#fonts-installation
let g:airline_powerline_fonts = 0

" Ctrl-P
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.git|\.hg|\.svn|node_modules|\.terraform)$',
  \ 'file': '\v\.(exe|so|dll|pyc|DS_Store)$',
  \ }

" NertTree
let NERDTreeIgnore = ['\.pyc$', '\.pyo$']
let NERDTreeShowHidden = 1

" vim-go
let g:go_def_mode='godef'
let g:go_fmt_command = "goimports"
let g:go_info_mode='gocode'
let g:go_metalinter_command='golangci-lint'

" ansible
let g:ansible_name_highlight = 'b'
let g:ansible_attribute_highlight = "ob"
let g:ansible_unindent_after_newline = 1
let g:ansible_extra_keywords_highlight = 1

" Terraform
let g:terraform_align=1
let g:terraform_completion_keys = 1
let g:terraform_fmt_on_save=1

" Needed on some linux distros.
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required! 
Plugin 'VundleVim/Vundle.vim'

" Plugins
Plugin 'othree/html5.vim'
Plugin 'vim-scripts/Colour-Sampler-Pack'
Plugin 'vim-scripts/ScrollColors'
Plugin 'https://github.com/kien/ctrlp.vim.git'
Plugin 'https://github.com/ddollar/nerdcommenter.git'
Plugin 'https://github.com/majutsushi/tagbar.git'
Plugin 'https://github.com/vim-scripts/ZoomWin.git'
Plugin 'https://github.com/jeetsukumaran/vim-buffergator.git'
" Plugin 'https://github.com/scrooloose/syntastic.git'
Plugin 'https://github.com/msanders/snipmate.vim.git'
Plugin 'https://github.com/hail2u/vim-css3-syntax.git'
Plugin 'https://github.com/cakebaker/scss-syntax.vim.git'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'mustache/vim-mustache-handlebars'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'johnallen3d/made-of-code.vim'
Plugin 'comment.vim'
" Plugin 'scrooloose/nerdtree'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'mileszs/ack.vim'
" Plugin 'Valloric/YouCompleteMe'
Plugin 'briancollins/vim-jst'
Plugin 'kchmck/vim-coffee-script'
Plugin 'tpope/vim-surround'
Plugin 'digitaltoad/vim-jade'
Plugin 'mxw/vim-jsx'
Plugin 'isRuslan/vim-es6'
Plugin 'vim-scripts/Miranda-syntax-highlighting'
Plugin 'guns/vim-clojure-static'
Plugin 'tpope/vim-fireplace'
Plugin 'bhurlow/vim-parinfer'
" Plugin 'kien/rainbow_parentheses.vim'
" Plugin 'ervandew/screen'
call vundle#end()

filetype plugin indent on

set t_Co=256
syntax on

" In many terminal emulators the mouse works just fine, thus enable it.
"if has('mouse')
    "set mouse=a
"endif

" Only do this part when compiled with support for autocommands.
" if has("autocmd")
    "filetype plugin indent on
" endif

" Jay's Edits
scriptencoding utf-8

" SETTINGS
" GUI Options
set ruler   " show the cursor position all the time
set relativenumber
set guioptions-=T
set showcmd   " display incomplete commands
set showmode
" set lazyredraw
set gdefault
let loaded_matchparen = 1
set hidden
set laststatus=2

" Grep settings
set grepprg=ack\ -k

" Spacing
set linespace=2
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smarttab
set autoindent
" set autoindent
" set copyindent

" Fold Settings
set foldenable

" Cursor Settings
set guicursor=n-v-c:block-Cursor-blinkon0,ve:ver35-Cursor,o:hor50-Cursor,i-ci:ver25-Cursor,r-cr:hor20-Cursor,sm:block-Cursor-blinkwait175-blinkoff150-blinkon175
set backspace=indent,eol,start
set virtualedit=all

set history=50    " keep 50 lines of command line history
set shortmess+=filmnrxoOtT

" Search Settings
set ignorecase
set infercase
set incsearch   
set wildmenu
set showfulltag
set noshowmatch

" No backups or swapfiles
set noswapfile
set nobackup
set nowb

" Change command settings
set cpoptions+=$
set ch=2            
set pastetoggle=<F2>

" Make vim faster in terminal
set lazyredraw
set ttyfast
set shell=/bin/zsh\ -l
set colorcolumn=80,120

let g:clojure_align_multiline_strings=1

" Mac settings
" set clipboard=unnamed

" KEY MAPS
iabbrev </ </<C-X><C-O>
inoremap <C-U> <C-G>u<C-U>
inoremap <Leader>v <F2><C-r>+<F2>
imap <D-V> ^O"+p

nmap <Up> <Nop>
nmap <Down> <Nop>
nmap <Left> <Nop>
nmap <Right> <Nop>
nmap <C-c><C-c> :ScreenShell<cr>

map ,cd :cd %:p:h<CR>
map <C-k>b :NERDTreeToggle<CR>

nnoremap <silent> <Esc><Esc> :nohls<CR><CR>
nnoremap j gj
nnoremap k gk
nnoremap <Up> <C-W>- nnoremap <Down> <C-W>+
nnoremap <Left> <C-W><
nnoremap <Right> <C-W>>
nnoremap <silent> <C-t> :Tex<CR>
nnoremap <silent> <C-j><S-l> :Vexplore!<CR>
nnoremap <silent> <C-j><S-h> :Vexplore<CR>
nnoremap <silent> <C-j><S-j> :Hexplore<CR>
nnoremap <silent> <C-j><S-k> :Hexplore!<CR>

noremap <Leader>c "+y
noremap <silent> ,s :syntax sync fromstart<CR>

" DISABLE NORMAL MODE H,J,K,L binding to train better habits

" Makes parts of an_underscored_word a seperate word.
" set isk-=_

if has('statusline')
    set stl=%f\ %m\ Line:%l/%L[%p%%]\ Col:%v\ Buf:#%n\ [%b][0x%B]
endif

" Auto Commands
" autocmd BufRead,BufEnter * silent! %foldopen!

" PLUGIN SETTINGS

cd %:p:h

" Themes
" colo freya
" colo wombat
" colo earendel 
" colo kellys
" colo mustang
" colo lucius
" colo slate2
" colo tir_black
" colo summerfruit256
" colo dusk
" color darkbone
" color denim
" color fu
" color rdark
" color railscasts
" color made-of-code
" color blacksea
" color leo
color mizore

hi ColorColumn ctermbg=5

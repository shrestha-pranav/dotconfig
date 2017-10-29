set nocompatible

if has("vms")
  set nobackup  " do not keep a backup file, use versions instead"
else
  set backup    " keep a backup file (restore to previous version)"
  set undofile  "keep an undo file (undo changes after closing)"
endif
set history=50  " keep 50 lines of command line history"

if has('mouse') | set mouse=a | endif

if &t_Co > 2 || has("gui_running")
  syntax on     "Syntax highlighting on, when the terminal has colors"
endif

if has("autocmd")
  filetype plugin indent on
  augroup vimrcEx
  au!
  autocmd FileType text setlocal textwidth=78

  augroup END
endif

if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langnoremap')
  set langnoremap
endif

packadd matchit

set backupdir^=~/.backup/.backups//
set dir^=~/.backup/.swapfiles//
set undodir^=~/.backup/.undofiles//
set ignorecase

"------------------------------------------------------------
" Styling

syntax enable
# set background=dark
let g:airline_theme='Atelier_CaveDark'
set term=screen-256color
" colorscheme Atelier_CaveDark"

"------------------------------------------------------------
" Settings 

set hidden
set path+=**
set wildmenu
set showcmd
set hlsearch
set nomodeline
set backspace=indent,eol,start
set autoindent
set nostartofline
set ruler
set laststatus=2
set t_vb=
set cmdheight=2
set notimeout ttimeout ttimeoutlen=200
set confirm
set incsearch     " do incremental searching"

set number
set shiftwidth=4
set softtabstop=2
set shiftround
set expandtab
set foldmethod=marker
set foldlevelstart=1
set splitbelow
set splitright
set visualbell
set ttyfast
set listchars=tab:▸\ ,eol:¬

autocmd FileType make setlocal noexpandtab
autocmd FileType text setlocal autoindent expandtab softtabstop=2 textwidth=76 spell spelllang=en_us
autocmd FileType help setlocal nospell

"------------------------------------------------------------
" Mappings 

let mapleader=' '

nnoremap tn :tabnew<Space>
nnoremap tk :tabnext<CR>
nnoremap tj :tabprev<CR>
nnoremap th :tabfirst<CR>
nnoremap tl :tablast<CR>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

:nnoremap <D-Right> :bnext<CR>
:nnoremap <M-Right> :bnext<CR>
:nnoremap <D-Left> :bprevious<CR>
:nnoremap <M-Left> :bprevious<CR>

nnoremap <Tab> za

nnoremap <leader>h :%s/\v
nnoremap <leader>q :q<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>wq :wq<CR>
nnoremap <leader><leader> :e#<CR>

nnoremap <leader>g :UndotreeToggle<CR>
nnoremap g= g+
nnoremap Y y$

"------------------------------------------------------------
" Mintty Compatibility 


let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"
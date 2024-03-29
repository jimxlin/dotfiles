augroup vimrc
  autocmd!
augroup END

nnoremap <SPACE> <Nop>
let mapleader      = ' '
let maplocalleader = ' '

" ============================================================================
" VIM-PLUG BLOCK {{{
" ============================================================================

" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
   \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

silent! if plug#begin('~/.vim/plugged')

" Colors
Plug 'gruvbox-community/gruvbox'
  let g:gruvbox_contrast_dark = 'medium'
Plug 'bluz71/vim-moonfly-colors'

" Read
Plug 'Yggdroot/indentLine', { 'on': 'IndentLinesToggle' }
  let g:indentLine_enabled = 1
  let g:indentLine_color_term = 0
  let g:indentLine_char = '▏'
  nnoremap <leader>i :IndentLinesToggle<cr>

Plug 'romainl/vim-cool'

Plug 'itchyny/lightline.vim'
  let g:lightline = {
  \   'colorscheme': 'moonfly',
  \   'active': {
  \     'left':[
  \       [ 'mode', 'paste' ],
  \       [ 'gitbranch', 'readonly', 'filename', 'modified' ]
  \     ]
  \   },
  \   'component_function': {
  \     'gitbranch': 'fugitive#head'
  \   }
  \}

Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
  nnoremap <leader>m :Goyo<cr> \| :Limelight!!<cr>

" Write
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-surround'
Plug 'wellle/targets.vim'

" Git
Plug 'tpope/vim-fugitive'
  nnoremap <silent> <Leader>G :Git<CR>>
  nnoremap <silent> <Leader>D :Gdiff<CR>
  nnoremap <silent> <Leader>B :Gblame<CR>
  nnoremap <silent> <Leader>L :Gllog<CR>
Plug 'mhinz/vim-signify'

call plug#end()
endif

" }}}
" ============================================================================
" BASIC SETTINGS {{{
" ============================================================================

" True color support
set termguicolors
" Swap write interval, refresh some UI plugins
set updatetime=600
" Use dark colorschemes
set background=dark
" Enable syntax highlighting
syntax on
" Limit syntax highlighting on long lines
set synmaxcol=512
" Default colorscheme
silent! colorscheme moonfly
" Make Vim more useful
set nocompatible
" Use the OS clipboard by default (on versions compiled with `+clipboard`)
set clipboard^=unnamed,unnamedplus
" Enhance command-line completion
set wildmenu
set wildmode=full
" Autocomplete behavior
set completeopt=menuone,preview,noselect
" Do not scan included files for autocomplete suggestions
set complete-=i
" Allow backspace in insert mode
set backspace=indent,eol,start
" Optimize for fast terminal connections
set ttyfast
" Improve scrolling speed
set lazyredraw
" Add the g flag to search/replace by default
set gdefault
" Use UTF-8 without BOM
set encoding=utf-8 nobomb
" Key combinations
set timeoutlen=500
set ttimeoutlen=10
" Centralize backups and swapfiles
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
" Don’t create backups when editing files in certain directories
set backupskip=/tmp/*,/private/tmp/*
" Save undo history to disk
if has('persistent_undo')
  set undodir=~/.vim/undo
  set undofile
endif
" Respect modeline in files
set modeline
set modelines=4
" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure
" Enable line numbers
set number
" Indentation
set autoindent
set smartindent
" Always use 2 spaces for indentation, don't use hard tabs
set tabstop=2
set expandtab
set softtabstop=2
set shiftwidth=2
" No extra spaces when joining multiple lines to single line
set nojoinspaces
" Do not highlight current line
set nocursorline
" Move cursor to next/previous line
set whichwrap=b,s,<,>,[,]
" Better cursor nav in visual block mode
set virtualedit=block
" 80 chars/line
set textwidth=0
if exists('&colorcolumn')
  set colorcolumn=80
endif
" Show “invisible” characters
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list
" Highlight searches
set hlsearch
" Ignore case of searches, unless search has caps
set ignorecase smartcase
" Highlight dynamically as pattern is typed
set incsearch
" View options for diffs
set diffopt=filler,vertical
" Always show status line
set laststatus=2
" Flashes instead of beeps
set visualbell
" Don’t reset cursor to start of line when moving around.
set nostartofline
" Show the cursor position
set ruler
" Don’t show the intro message when starting Vim
set shortmess=atTI
" Show the current mode
set showmode
" Show the filename in the window titlebar
set title
" Show the (partial) command as it’s being typed
set showcmd
" Use relative line numbers
if exists("&relativenumber")
  set relativenumber
  au BufReadPost * set relativenumber
endif
" Start scrolling three lines before the horizontal window border
set scrolloff=3
" Hide buffers instead of closing them
set hidden
" No folding when switching buffers
set foldlevelstart=99
" Periodically check if buffer was changed outside of Vim
au CursorHold,CursorHoldI * silent! checktime
" Use ripgrep when grepping
if executable('rg')
  set grepprg=rg\ --no-heading\ --vimgrep\ --smart-case
  set grepformat^=%f:%l:%c:%m,%f:%l:%m   " file:line:column:message
endif
" Set encryption method
silent! set cryptmethod=blowfish2
" Ignore some chars when using gf
set isfname-==
" Custom statusline, gets overwritten by plugin
function! s:statusline_expr()
  let mod = "%{&modified ? '[+] ' : !&modifiable ? '[x] ' : ''}"
  let ro  = "%{&readonly ? '[RO] ' : ''}"
  let ft  = "%{len(&filetype) ? '['.&filetype.'] ' : ''}"
  let fug = "%{exists('g:loaded_fugitive') ? fugitive#statusline() : ''}"
  let sep = ' %= '
  let pos = ' %-12(%l : %c%V%) '
  let pct = ' %P'
  return '[%n] %F %<'.mod.ro.ft.fug.sep.pos.'%*'.pct
endfunction
let &statusline = s:statusline_expr()

" }}}
" ============================================================================
" MAPPINGS {{{
" ============================================================================

" Save
nnoremap <leader>w :update<cr>

" Disable CTRL-A on tmux or on screen
if $TERM =~ 'screen'
  nnoremap <C-a> <nop>
  nnoremap <Leader><C-a> <C-a>
endif

" grep
nnoremap <Leader>g :silent lgrep<Space>

" Nav Quickfix
nnoremap ]q :cnext<cr>zz
nnoremap [q :cprev<cr>zz
nnoremap ]l :lnext<cr>zz
nnoremap [l :lprev<cr>zz

" Nav Buffers
nnoremap ]b :bnext<cr>
nnoremap [b :bprev<cr>

" Nav Tabs
nnoremap ]t :tabn<cr>
nnoremap [t :tabp<cr>

" }}}
" ============================================================================
" FUNCTIONS & COMMANDS {{{
" ============================================================================

" <F8> | Color scheme selector
function! s:colors(...)
  return filter(map(filter(split(globpath(&rtp, 'colors/*.vim'), "\n"),
        \                  'v:val !~ "^/usr/"'),
        \           'fnamemodify(v:val, ":t:r")'),
        \       '!a:0 || stridx(v:val, a:1) >= 0')
endfunction

function! s:rotate_colors()
  if !exists('s:colors')
    let s:colors = s:colors()
  endif
  let name = remove(s:colors, 0)
  call add(s:colors, name)
  execute 'colorscheme' name
  redraw
  echo name
endfunction
nnoremap <silent> <F8> :call <SID>rotate_colors()<cr>

" }}

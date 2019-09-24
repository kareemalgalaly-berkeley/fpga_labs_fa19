" Reference
" https://dougblack.io/words/a-good-vimrc.html

" map <- recursive (v - visual+select, n-normal, o-operator)
" noremap <- nonrecursive
" __map! (insert, command-line (ic))

" cmd prompt : prompt /? for info
" setx PROMPT $g$s       for set default

"security
:set modelines=0
:set nomodeline

"colorscheme deus
"let g:airline_theme='twofirewatch'
"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#left_sep=' '
"let g:airline#extensions#tabline#left_alt_sep='>'
"let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
"let g:airline_symbols_ascii = 1
"if !exists('g:airline_symbols')
"    let g:airline_symbols = {}
"endif
"let g:airline_left_sep='▶'
"set encoding=utf-8

set noshowmode      " hide Vim's default -- Mode --
"set guifont=Ubuntu_Mono:h8
set number          " show line numbers
set showmatch       " highlight corresp [{()}]
set cursorline      " highlight current line
hi CursorLine term=bold cterm=bold guibg=Grey40
filetype indent on  " load filetype-specific indent data
syntax on
"set guioptions -=m  " hide File Edit Tools ... menu
"set guioptions -=T  " hide open, save, undo, redo, ... toolbar

" Spacing
set tabstop=4       " visual spaces per tab
set softtabstop=4   " spaces inserted per tab
set shiftwidth=4    " shift with tab = 4
set expandtab       " tabs are spaces

" Searching
set hlsearch        " highlight matches
set incsearch       " search as query entered
nnoremap <esc> :noh<CR>

" Folding (collapse code blocks)
set foldenable      " enable folding
set foldmethod=indent "fold by indent
set foldlevelstart=10 "open most folds by default
set foldnestmax=10    "10 nested fold maximum
nnoremap <space> za

" Persistent Undo
set undofile   " Maintain undo history between sessions
"if has("persistent_undo") " save in local undodir if exists or Vim/undodir
"    set undodir=undodir/
"    set undofile
"endif
if has("persistent_undo")
    set undodir=~/.undodir/
    set undofile
endif
let mapleader="\\"  "set leader to be the comma (not backslash)
" toggle gundo (display undo tree)
nnoremap <leader>u :UndotreeToggle<CR>
" set U to redo
nnoremap U <C-R>


" Behavior
set backspace=indent,eol,start " allow backspacing over these special characters
set whichwrap+=<,>,h,l,[,]     " allow wrapping to previous lines <> arrows in norm, [] arrows in insert
" Cut-Copy-Paste
noremap <C-X> "+x
noremap <C-C> "+y
noremap <C-Q> "+gP
inoremap <C-Q> <C-R>*
" Let Ctr+Q do what Ctrl+V did (visual block)
" noremap <C-Q> <C-V>
" vnoremap <C-Z> u "ctrl+z is suspend
" move by visual line (instead of physical)
"nnoremap j gj
"nnoremap k gk
nnoremap gV `[v`]

" + / - grow and shrink view
function! FontSizePlus ()
    let l:gf_size_whole = matchstr(&guifont, '\(:h\)\@<=\d\+$')
    let l:gf_size_whole = l:gf_size_whole + 1
    let l:new_font_size = ':h'.l:gf_size_whole
    let &guifont = substitute(&guifont, ':h\d\+$', l:new_font_size, '')
endfunction
function! FontSizeMinus ()
    let l:gf_size_whole = matchstr(&guifont, '\(:h\)\@<=\d\+$')
    let l:gf_size_whole = l:gf_size_whole - 1
    let l:new_font_size = ':h'.l:gf_size_whole
    let &guifont = substitute(&guifont, ':h\d\+$', l:new_font_size, '')
endfunction

if has("gui_running")
    nnoremap _ :call FontSizeMinus()<CR>
    nnoremap + :call FontSizePlus()<CR>
endif

" trim whitespace function
fun! TrimWhitespace()
    let l:save = winsaveview()
    %s/\s\+$//e
    call winrestview(l:save)
endfun

"netrw
let g:netrw_liststyle = 3 " tree style
let g:netrw_browse_split = 3 " 1 open in horiz, 2 open in vert
"                              3 open in tab, 4 open in previous
let g:netrw_winsize = 25  " 25% of screen when :Vexplore or :Hexplore

" Control Space to enter or leave insert
" inoremap <S-Tab> <Esc>
inoremap <C-Space> <Esc>
"vnoremap <S-Space> <Esc>
"nnoremap <S-Space> i

set belloff=all

" -------------------------------------
" Terminal fixes
"
" These originate from some linux distribution's system vimrc. I can't say
" that I understand the details what's going on here, but without these
" settings, I've had problems like vim starting in REPLACE mode for
" TERM=xterm-256color (neovim is fine)

if &term =~? 'xterm'
    let s:myterm = 'xterm'
else
    let s:myterm =  &term
endif
let s:myterm = substitute(s:myterm, 'cons[0-9][0-9].*$',  'linux', '')
let s:myterm = substitute(s:myterm, 'vt1[0-9][0-9].*$',   'vt100', '')
let s:myterm = substitute(s:myterm, 'vt2[0-9][0-9].*$',   'vt220', '')
let s:myterm = substitute(s:myterm, '\\([^-]*\\)[_-].*$', '\\1',   '')

" Here we define the keys of the NumLock in keyboard transmit mode of xterm
" which misses or hasn't activated Alt/NumLock Modifiers.  Often not defined
" within termcap/terminfo and we should map the character printed on the keys.
if s:myterm ==? 'xterm' || s:myterm ==? 'kvt' || s:myterm ==? 'gnome'
    " keys in insert/command mode.
    map! <ESC>Oo  :
    map! <ESC>Oj  *
    map! <ESC>Om  -
    map! <ESC>Ok  +
    map! <ESC>Ol  ,
    map! <ESC>OM  
    map! <ESC>Ow  7
    map! <ESC>Ox  8
    map! <ESC>Oy  9
    map! <ESC>Ot  4
    map! <ESC>Ou  5
    map! <ESC>Ov  6
    map! <ESC>Oq  1
    map! <ESC>Or  2
    map! <ESC>Os  3
    map! <ESC>Op  0
    map! <ESC>On  .
    " keys in normal mode
    map <ESC>Oo  :
    map <ESC>Oj  *
    map <ESC>Om  -
    map <ESC>Ok  +
    map <ESC>Ol  ,
    map <ESC>OM  
    map <ESC>Ow  7
    map <ESC>Ox  8
    map <ESC>Oy  9
    map <ESC>Ot  4
    map <ESC>Ou  5
    map <ESC>Ov  6
    map <ESC>Oq  1
    map <ESC>Or  2
    map <ESC>Os  3
    map <ESC>Op  0
    map <ESC>On  .
endif

" xterm but without activated keyboard transmit mode
" and therefore not defined in termcap/terminfo.
if s:myterm ==? 'xterm' || s:myterm ==? 'kvt' || s:myterm ==? 'gnome'
    " keys in insert/command mode.
    map! <Esc>[H  <Home>
    map! <Esc>[F  <End>
    " Home/End: older xterms do not fit termcap/terminfo.
    map! <Esc>[1~ <Home>
    map! <Esc>[4~ <End>
    " Up/Down/Right/Left
    map! <Esc>[A  <Up>
    map! <Esc>[B  <Down>
    map! <Esc>[C  <Right>
    map! <Esc>[D  <Left>
    " KP_5 (NumLock off)
    map! <Esc>[E  <Insert>
    " PageUp/PageDown
    map <ESC>[5~ <PageUp>
    map <ESC>[6~ <PageDown>
    map <ESC>[5;2~ <PageUp>
    map <ESC>[6;2~ <PageDown>
    map <ESC>[5;5~ <PageUp>
    map <ESC>[6;5~ <PageDown>
    " keys in normal mode
    map <ESC>[H  0
    map <ESC>[F  $
    " Home/End: older xterms do not fit termcap/terminfo.
    map <ESC>[1~ 0
    map <ESC>[4~ $
    " Up/Down/Right/Left
    map <ESC>[A  k
    map <ESC>[B  j
    map <ESC>[C  l
    map <ESC>[D  h
    " KP_5 (NumLock off)
    map <ESC>[E  i
    " PageUp/PageDown
    map <ESC>[5~ 
    map <ESC>[6~ 
    map <ESC>[5;2~ 
    map <ESC>[6;2~ 
    map <ESC>[5;5~ 
    map <ESC>[6;5~ 
endif

" xterm/kvt but with activated keyboard transmit mode.
" Sometimes not or wrong defined within termcap/terminfo.
if s:myterm ==? 'xterm' || s:myterm ==? 'kvt' || s:myterm ==? 'gnome'
    " keys in insert/command mode.
    map! <Esc>OH <Home>
    map! <Esc>OF <End>
    map! <ESC>O2H <Home>
    map! <ESC>O2F <End>
    map! <ESC>O5H <Home>
    map! <ESC>O5F <End>
    " Cursor keys which works mostly
    " map! <Esc>OA <Up>
    " map! <Esc>OB <Down>
    " map! <Esc>OC <Right>
    " map! <Esc>OD <Left>
    map! <Esc>[2;2~ <Insert>
    map! <Esc>[3;2~ <Delete>
    map! <Esc>[2;5~ <Insert>
    map! <Esc>[3;5~ <Delete>
    map! <Esc>O2A <PageUp>
    map! <Esc>O2B <PageDown>
    map! <Esc>O2C <S-Right>
    map! <Esc>O2D <S-Left>
    map! <Esc>O5A <PageUp>
    map! <Esc>O5B <PageDown>
    map! <Esc>O5C <S-Right>
    map! <Esc>O5D <S-Left>
    " KP_5 (NumLock off)
    map! <Esc>OE <Insert>
    " keys in normal mode
    map <ESC>OH  0
    map <ESC>OF  $
    map <ESC>O2H  0
    map <ESC>O2F  $
    map <ESC>O5H  0
    map <ESC>O5F  $
    " Cursor keys which works mostly
    " map <ESC>OA  k
    " map <ESC>OB  j
    " map <ESC>OD  h
    " map <ESC>OC  l
    map <Esc>[2;2~ i
    map <Esc>[3;2~ x
    map <Esc>[2;5~ i
    map <Esc>[3;5~ x
    map <ESC>O2A  ^B
    map <ESC>O2B  ^F
    map <ESC>O2D  b
    map <ESC>O2C  w
    map <ESC>O5A  ^B
    map <ESC>O5B  ^F
    map <ESC>O5D  b
    map <ESC>O5C  w
    " KP_5 (NumLock off)
    map <ESC>OE  i
endif

if s:myterm ==? 'linux'
    " keys in insert/command mode.
    map! <Esc>[G  <Insert>
    " KP_5 (NumLock off)
    " keys in normal mode
    " KP_5 (NumLock off)
    map <ESC>[G  i
endif

" This escape sequence is the well known ANSI sequence for
" Remove Character Under The Cursor (RCUTC[tm])
map! <Esc>[3~ <Delete>
map <ESC>[3~ x

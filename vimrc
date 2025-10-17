set number relativenumber " Show line numbers in relative position. The current line will be in absolute number.

syntax on                 " Enable sytax highlighting.

set mouse=a               " Enable mouse support in all modes.

" This comand modify the normal mode mapping of the y key.
"set clipboard=unnamedplus " Use the system clipboard for copy and paste operations.

set relativenumber        " how relative line numbers. The current line will be in absolute number.

set undofile              " Enable persitent undo to allow undo history even after closing Vim

set undodir=$HOME/.vim/undodir 

set termguicolors         " Enable true colors.

set wrapscan              " Make search wrap around file.

set shortmess-=S          " Show the number of matches. 
 
filetype plugin on        " load additional settings or plugins specific to that filetype.  

set autoindent            " Respect indentation when starting a new line. 

set expandtab             " Expand tabs to spaces. Essential in Python. 

set tabstop=4             " Number of spaces tab is counted for. 

set shiftwidth=4          " Number of spaces to use for autoindent.

set cursorline            " Highlight cursor line underneath the cursor horizontally. 

set backspace=2           " Fix backspace behavior on most terminals 

packloadall               " Load all plugins .

silent! helptags ALL      " Load help files for all plugins 

set foldmethod=indent     " Fold based on indentation

set wrap                  "  Wrap lines.Dont allow long lines to extend as far as the line goes 

set incsearch             " While searching through a file incrementally highlight matching characters as you type. 

set ignorecase            " Ignore capital letters during search 

set smartcase             " Override the ignorecases option if searching specifically for capital letters. This will allow you to search specifically for capital letters. 

set showcmd               " Show partial command you type in the last line of the screen. 

set showmode              " Show the mode you are on the last line. 

set showmatch             " Show matching words during a search.

set hlsearch              " Use highlighting when doing a search. 

set history=100           " Set the commands to save in history default number is 20. 

set wildmenu              " Enable auto completion menu after pressing TAB. 

set wildmode=list:longest " Make wildmenu behave similar to a Bash completion. 

set updatetime=300      

" Wildmenu will ignore files with these extensions. 
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx,*.mod

" Variable for fortran install:
let fortran_dep_install=3

" PLUGINS ---------------------------------------------------------------------------------- 
" Installing plugins will require plugin managers. I used vim-plug which I
" installed using the command in bash: 
" $ curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
call plug#begin('~/.vim/plugged')
    " Plug 'ycm-core/YouCompleteMe'
    Plug 'dense-analysis/ale'
    Plug 'preservim/nerdtree'
    " Plug 'SirVer/ultisnips'       " vim easycomplete needs this for snippet support. 
    Plug 'morhetz/gruvbox'
    Plug 'dracula/vim'
    Plug 'prabirshrestha/vim-lsp' " lsp stands for Language Server Protocol. vim-lsp is a plugin for LSP support. 
                                  " We also need to install LSP servers
                                  " separately. For python: 
                                  " $ sudo npm install -g pyright 
                                  " $ sudo npm install -g \
                                  " typescript-language-server
                                  " for C++: 
                                  " $ sudo apt install clangd
                                  " for Fortran: 
                                  " pip install fortls
                                  " for Bash:
                                  " $ sudo apt install nodejs npm 
                                  " $ sudo npm install -g bash-language-server
    " Plug 'jayli/vim-easycomplete'
    
    " Only load vim-instant-markdown on your local machine
    " Solo cargar vim-instant-markdown en tu máquina local
    " This aboid login0i on galileo and login0i.leonardo.local
    if hostname() !~# '^login\d\+\(\.leonardo\.local\)\?$'
     Plug 'suan/vim-instant-markdown' " This will require vim-instant-markdown:
    endif
                                     " $ sudo npm install -g instant-markdown-d

                                     "
    Plug 'tpope/vim-commentary'      " Easy code commenting. Heres how to use :
                                     " gcc ----> comment/uncomment a line 
                                     " gc3 ----> comment/uncomment 3 lines
                                     " below and so on. 
    Plug 'airblade/vim-gitgutter'    " Git diff in gutter. Indicators include + for  added a lines, ~ for modified lines, - for removed lines.    
    " Plug 'codota/tabnine-vim'        " AI completion support. 
    Plug 'rudrab/vimf90'            " to make coding in fortran easier and faster 
    Plug 'github/copilot.vim'
    Plug 'vim-airline/vim-airline'  " Status line plugin   
    Plug 'vim-airline/vim-airline-themes'
call plug#end()

" MAPPINGS --------------------------------------------------------------------------------- 
" Markdown preview in terminal using glow
" Mappings code goes here.

" Set the backslash as the leader key. Notice its the double \\. A single \
" will escape the closing quote so vim wont know where the string ends. 
let mapleader = "\\"   

" Use gruvbox for airline theme
let g:airline_theme='gruvbox'
  
" Enable airline to show the current file type in the status line.
let g:airline#extensions#filetype#enabled = 1

" Enable airline tabline
let g:airline#extensions#tabline#enabled = 1

" Enable Powerline fonts for airline
let g:airline_powerline_fonts = 1

" Change the dark contrast of the gruvbox colorscheme.
let g:gruvbox_contrast_dark = 'hard'

" Bind jj to esc   
inoremap jj <esc>

" -------------
" Bind to copy to the clipboard a line or visual selection.
vnoremap <leader>y "+y

" copy a line to the clipboard in normal mode.
nnoremap <leader>y "+yy

" copy the entire file to the clipboard in normal mode.
nnoremap <leader>ya gg"+yG

" paste from the clipboard in normal mode.
nnoremap <leader>p "+p
" -------------
  
" bind <leader>w to :NERDTreeRefreshRoot<CR>
nnoremap <leader>w :NERDTreeRefreshRoot<CR>

" bind <leader>t to :terminal<CR>
nnoremap <leader>t :terminal<CR>

" bind <leader>s to :source ~/.vimrc<CR>
nnoremap <leader>s :source ~/.vimrc<CR>

" bind <leader>q to :tabnew<CR>
nnoremap <leader>q :tabnew<CR>

" Comment fortran selected lines in visual mode.
"xnoremap <leader>c :s/^\s*/&! /<CR>

" Uncomment fortran  selected lines in visual mode.
"xnoremap <leader>u :s/^\(\s*\)! *//<CR>

" === Copilot key bindings ===
nnoremap <leader>ce :Copilot enable<CR>
nnoremap <leader>cd :Copilot disable<CR>
nnoremap <leader>cs :Copilot status<CR>


" Bind gr to :bnext<CR>
nnoremap gr :bnext<CR>

" bind gR to :bprevious<CR>
nnoremap gR :bprevious<CR>

" mappings to toggle ALE on/off
nnoremap <leader>d :ALEDisable<CR>
nnoremap <leader>e :ALEEnable<CR>

" Instant Markdown settings

" Map \o to open the Instant Markdown Preview 
nnoremap <Leader>o :InstantMarkdownPreview<CR> 

" Map <Leader>m to close Instant Markdown Preview (kill the server). before
" was <Leader>c
nnoremap <Leader>m :InstantMarkdownStop<CR>

"For rendering equation in markdown using MathJax.                
let g:instant_markdown_mathjax = 1
" For rendering diagrams and flowcharts using mermaind.js 
let g:instant_markdown_mermaid = 1
" Enables Python for certain rendering features
"let g:instant_markdown_python = 1
let g:instant_markdown_autoscroll = 1  " Enable autoscroll
" set the preview theme in vim-Instant-markdown to dark 
let g:instant_markdown_theme = 'dark'

let g:gruvbox_improved_diff = 1 " Enable improved diff highlighting in gruvbox

" Press `` to jump back to the last cursor position.
nnoremap <leader>\ ``

" map <Leader>h to :browse oldfiles
nnoremap <leader>h :browse oldfiles<CR>

" Press the space bar to type the : character in comand mode. 
nnoremap ; :

" Press the letter o(O) will open a new line below(above) the current one and
" will be in insert mode. This mapping will exit the insert mode. 
" nnoremap o o<esc>
" noremap O O<esc>

" Center the cursor vertically when moving to the next word during a search.
nnoremap n nzz
nnoremap N Nzz

"  Yank from cursor to the end of line. 
nnoremap Y y$

" Map the F5 key to run a Python script inside Vim. 
" I map the F5 to a chain of commands here. 
" :w saves the file. 
" <CR> (carriage return) is like pressing the enter key. 
" !clear runs the external clear the screen command.
" !python3 % executes the current file in Python. 
"
" nnoremap <f5> :w <CR>:!python3 % <CR> " external terminal
nnoremap <F5> :w<CR>:terminal python3 %<CR>


" Turn off highlighting by pressing \\
nnoremap <leader>\ :nohlsearch<CR> 

" You can split the window in Vim by typing :split or vsplit.
" Navigate the split view easier by pressing CTRL+j, CTRL+k, CTRL+h, CTRL+l.
" This does not seem to work with terminals. 
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

"Resize split windows using arrow keys by pressing:
" CTRL+SHIFT+UP, CTRL+SHIFT+DOWN, CTRL+SHIFT+LEFT, or CTRL+SHIFT+RIGHT.
" ---  This combinations is for macOS.
nnoremap <C-S-UP> <C-w>+
nnoremap <C-S-Down> <C-w>-
nnoremap <C-S-Left> <C-w><
nnoremap <C-S-Right> <C-w>>
" ---  This combinations is for Linux.
" CTRL+UP, CTRL+DOWN, CTRL+LEFT, or CTRL+RIGHT.
"nnoremap <C-Up> <C-w>+
"nnoremap <C-Down> <C-w>-
"nnoremap <C-Left> <C-w><
"nnoremap <C-Right> <C-w>>


" Change the split windows position  using the arrow keys.
nnoremap <leader>H :silent wincmd H<CR>
nnoremap <leader>L :silent wincmd L<CR>
nnoremap <leader>K :silent wincmd K<CR>
nnoremap <leader>J :silent wincmd J<CR>


" NERDTree specific mappings 
" Map the F2 key to toggle NERDTree open and close.
nnoremap <F2> :NERDTreeRefreshRoot<CR>:NERDTreeToggle<cr>:set relativenumber<CR>
" Have NERDTree ignore certain files and directories. 
let NERDTreeIgnore=['\.git$', '\.jpg$', '\.mp4$', '\.ogg$', '\.iso$', '\.pdf$', '\.pyc$', '\.odt$', '\.png$', '\.gif$', '\.db$']
"  

" VIMSCRIPT--------------------------------------------------------------------------------- 
" This will enable code folding. 
" Use the marker method of folding.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" More Vimscripts code goes here. 

" automatic install of fortran dependencies for vimf90 
"let fortran_dep_install=3 

" linting for fortan in vimf90
" let fortran_linter =2

" Configuration for easycomplete

" Highlight the symbol when holding the cursor
" let g:easycomplete_cursor_word_hl = 1
" Using nerdfont is highly recommended
"let g:easycomplete_nerd_font = 1

"let g:easycomplete_enable_lsp = 1

"let g:easycomplete#sources = ['omnifunc', 'path', 'buffer']
"

" set omnifunc=Tabnine#complete

" " For EasyComplete diagnostic navigation
" " let g:easycomplete_diagnostic_jump_next = '<leader>dn'
" let g:easycomplete_diagnostic_jump_prev = '<leader>dp'

" Mapping for next diagnostic (if you want to use <leader>dn)
" nnoremap <leader>dn :lua vim.diagnostic.goto_next()<CR>
" Mapping for previous diagnostic (if you want to use <leader>dp)
" nnoremap <leader>dp :lua vim.diagnostic.goto_prev()<CR>


" GoTo code navigation
"noremap gr :EasyCompleteReference<CR>
"noremap gd :EasyCompleteGotoDefinition<CR>
"noremap rn :EasyCompleteRename<CR>
"noremap gb :BackToOriginalBuffer<CR>

" Configuration for using vim-lsp to use pyright 
if executable('pyright')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'pyright',
        \ 'cmd': {server_info->['pyright-langserver', '--stdio']},
        \ 'allowlist': ['python'],
        \ })
endif
" Configuration for vim-lsp to use clangd
if executable('clangd')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd', '--background-index']},
        \ 'allowlist': ['cpp', 'c', 'cc', 'c++'],
        \ })
endif
" Configuration for vim-lsp to use fortls 
if executable('fortls')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'fortls',
        \ 'cmd': {server_info->['fortls']},
        \ 'allowlist': ['fortran'],
        \ })
endif
" Configuration for vim-lsp to use bash-language-server 
if executable('bash-language-server')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'bash-language-server',
        \ 'cmd': {server_info->['bash-language-server', 'start']},
        \ 'allowlist': ['sh', 'bash'],
        \ })
endif

" Tone down lsp error annotations. If you still want to see error indicators (like a sign in the gutter), but not inline text. 
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_diagnostics_signs_enabled = 0
let g:lsp_diagnostics_highlights_enabled = 0


" STATUS LINE------------------------------------------------------------------------------- 
" Status bar code goes here. 
" Clear status line when vimrc is reloaded.
set statusline=

" Status line left side.
set statusline+=\ %F\ %M\ %Y\ %R

" Use a divider to separate the left side from the right side.
set statusline+=%=

" Status line right side.
set statusline+=\ %b\ row:\ %l\ col:\ %c\ percent:\ %p%%

" Show the status on the second to last line.
set laststatus=2

" map .cuf files to use the fortran syntax Highlighting only but not for
" linting/LSP.
augroup myfiletypes
  autocmd!
  autocmd BufRead,BufNewFile *.cuf set filetype=fortran
  autocmd BufRead,BufNewFile *.cuf let b:ale_enabled = 0
augroup END

colorscheme gruvbox       " Change a colorscheme. I need to place after the installation of Gruvbox. 
set background=dark       " Set background to dark

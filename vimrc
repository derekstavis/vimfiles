" .vimrc
" Forked from: Jonathan Lima <greenboxal@gmail.com>
" Adapted by: Derek Stavis  <derekstavis@me.com>
" Source  http://github.com/derekstavis/vimfiles

 " ##### Fix vim with fish  {{{
set shell=sh

" "}}}

" ##### Fix Terminal enter/exit {{{
tnoremap <silent> <C-up> <C-\><C-n><C-w><up>
tnoremap <silent> <C-down> <C-\><C-n><C-w><down>
tnoremap <silent> <C-left> <C-\><C-n><C-w><left>
tnoremap <silent> <C-right> <C-\><C-n><C-w><right>
" autocmd BufWinEnter,WinEnter term://* startinsert
autocmd BufLeave term://* stopinsert
" "}}}

" ##### Plug setup  {{{
call plug#begin('~/.vim/plugged')
" "}}}
" ##### Plugs  {{{
" Base
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'teranex/jk-jumps.vim'
Plug 'mg979/vim-visual-multi'
Plug 'ryanoasis/vim-devicons'
Plug 'milkypostman/vim-togglelist'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'ckarnell/history-traverse'
Plug 'bit101/bufkill'
Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'HiPhish/rainbow-delimiters.nvim'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'machakann/vim-highlightedyank'
Plug 'troydm/zoomwintab.vim'
Plug 'talek/obvious-resize'
Plug 'wesQ3/vim-windowswap'
Plug 'wfxr/minimap.vim'
Plug 'm4xshen/smartcolumn.nvim'

" Support
Plug 'embear/vim-localvimrc'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-surround'
Plug 'tomtom/tcomment_vim'
Plug 'bfredl/nvim-miniyank'
Plug 'skanehira/vsession'
Plug 'wakatime/vim-wakatime'
Plug 'ruanyl/vim-gh-line'
Plug 'ap/vim-css-color'

" Colorschemes
Plug 'morhetz/gruvbox'

" Languages
Plug 'b4winckler/vim-objc'
Plug 'rodjek/vim-puppet'
Plug 'fatih/vim-go'
Plug 'dag/vim-fish'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'othree/yajs'
Plug 'jparise/vim-graphql'
Plug 'gkz/vim-ls'
Plug 'chemzqm/vim-jsx-improve'
Plug 'kchmck/vim-coffee-script'
Plug 'hashivim/vim-terraform'
Plug 'hashivim/vim-packer'
Plug 'hashivim/vim-consul'
Plug 'hashivim/vim-vaultproject'
Plug 'juliosueiras/vim-terraform-completion'
Plug 'mustache/vim-mustache-handlebars'
Plug 'ekalinin/Dockerfile.vim'
Plug 'digitaltoad/vim-pug'
Plug 'uarun/vim-protobuf'
Plug 'tpope/vim-markdown'
Plug 'jtratner/vim-flavored-markdown'
Plug 'elixir-editors/vim-elixir'
Plug 'Matt-Deacalion/vim-systemd-syntax'
Plug 'RaafatTurki/hex.nvim'
Plug 'OmniSharp/omnisharp-vim'
Plug 'mfussenegger/nvim-dap'
Plug 'zbirenbaum/copilot.lua'

" Search
Plug 'haya14busa/incsearch.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'liuchengxu/vista.vim'

" Git
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'olimorris/codecompanion.nvim'
" }}}
" ##### Plug post-setup {{{
call plug#end()
" }}}
" ##### Basic options  {{{
" Faster redraws
set lazyredraw
" Use colors on GUI like VimR
set termguicolors
" Don't resize splits on change
set eadirection=hor
" Display incomplete commands.
set noshowcmd
" Display the mode you're in.
set showmode
" Persist only visible buffers.
set sessionoptions-=buffers

" Intuitive backspacing.
set backspace=indent,eol,start
" Dont keep buffers forever.
set nohidden

" Enhanced command line completion.
set wildmenu

" Case-insensitive searching.
set ignorecase
" But case-sensitive if expression contains a capital letter.
set smartcase

" Show line numbers.
set number
" Show cursor position.
set ruler
" Highlight ruler at colum 72.
set colorcolumn=72
" Highlight current line
set cursorline

" Highlight matches as you type.
set incsearch
" Don't highlight matches.
set nohlsearch

" Turn off line wrapping.
set nowrap
" Show 3 lines of context around the cursor.
set scrolloff=3

" Set the terminal's title
set title
" Set the terminal's title to filename.
set titlestring=%t
" Don't blink screen on stuff
set novb
" Limit terminal's scrollback.
set scrollback=65535

" Don't make a backup before overwriting a file.
set nobackup
" And again.
set nowritebackup
" Keep swap files in one location
set directory=$HOME/.vim/tmp//

" Global tab width.
set tabstop=2
" And again, related.
set shiftwidth=2
" And also expand tabs.
set expandtab

" Files open expanded
set foldlevelstart=50
" Use decent folding
set foldmethod=indent

" Show the status line all the time
set laststatus=2

" Always diff using vertical mode
set diffopt+=vertical

" Automatically reads changed files
set autoread

" Enable syntax highlighting
syntax on

" Use a better separator for splits
set fillchars+=eob:\ ,vert:│

" Sets the colorscheme for terminal sessions too.
set background=dark
let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox

" Leader = ,
let mapleader = ","
let maplocalleader = "'"

" Fix split opening direction
set splitbelow
set splitright

" Remove 'press any key to continue'
set cmdheight=2

" Disable fucked-up SQL completion
let g:omni_sql_no_default_maps = 1

" Completion
set completeopt=menu,noselect

" Live replacement
if exists("&inccommand")
  set inccommand=split
endif

" }}}
" ##### General mappings  {{{
" ##### IDE Like {{{
nmap <silent> <leader>1 <Cmd>CocCommand explorer --toggle --focus<CR><CR>
nmap <silent> <leader>2 :Vista!!<CR>

let g:minimap_auto_start = 1

" }}}
" ##### Line movement {{{
" Go to start of line with H and to the end with $
noremap H ^
noremap L $

" Emacs bindings in command-line mode
cnoremap <C-A> <home>
cnoremap <C-E> <end>
" }}}
" ##### Tabs {{{
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>th :tabprev<CR>
nnoremap <leader>tl :tabnext<CR>
" }}}
" ##### Focus {{{
nnoremap <leader>fs :ZoomWinTabToggle<CR>
" }}}
" ##### Folding {{{
" Toggles folding with space
nnoremap <Space> za
" Open all folds
nnoremap zO zR
" Close all folds
nnoremap <c-Space> zM
" Close current fold
nnoremap zc zc
" Close all folds except the current one
nnoremap zf mzzMzvzz
" }}}
" ##### Search {{{
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
" }}}
" ##### Spell {{{
set spelllang=en_us

nnoremap ,sc :set spell!<cr>
" }}}
" ##### Misc {{{
" Edit and load vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" Terminal shortcuts
let termshell = systemlist('echo term://`which fish`')[0]

execute 'noremap <leader>tsh :tabnew ' . termshell . '<CR>'
execute 'noremap <leader>vsh :vsplit ' . termshell . '<CR>'
execute 'noremap <leader>sh :10split ' . termshell . '<CR>'
autocmd FileType gitcommit set bufhidden=delete
command BD bp|bd#

" Toggles hlsearch
nnoremap <leader>hs :set hlsearch!<cr>

" Maps <C-C> to <esc>
noremap <C-C> <esc>

" Set current file executable
nnoremap <leader>xx :!chmod +x %<cr>

" Close Quickfix and Preview
nnoremap <leader>q :pclose<cr>:cclose<cr>

let g:obvious_resize_default = 8
nnoremap <silent> <s-left> :<C-U>ObviousResizeLeft<CR>
nnoremap <silent> <s-down> :<C-U>ObviousResizeDown<CR>
nnoremap <silent> <s-up> :<C-U>ObviousResizeUp<CR>
nnoremap <silent> <s-right> :<C-U>ObviousResizeRight<CR>

" OS Clipboard
if has('clipboard')
  set clipboard=unnamedplus
endif

" Navigate splits
nnoremap <c-left> <c-w>h
nnoremap <c-right> <c-w>l
nnoremap <c-up> <c-w>k
nnoremap <c-down> <c-w>j

" Navigate buffer history
noremap <leader><Left> :HisTravBack<CR>
noremap <leader><Right> :HisTravForward<CR>
" }}}
" }}}
" ##### Plugin settings  {{{
" ##### NERDTree {{{
let NERDTreeMinimalUI=1
let NERDTreeNaturalSort=1

" }}}
" ##### NERDTree Git {{{
let g:NERDTreeGitStatusWithFlags = 0
let g:NERDTreeGitStatusNodeColorization = 1
let g:NERDTreeColorMapCustom = {
    \ "Modified"  : "#528AB3",
    \ "Staged"    : "#538B54",
    \ "Untracked" : "#BE5849",
    \ "Dirty"     : "#299999",
    \ "Clean"     : "#87939A",
    \ "Ignored"   : "#808080"
    \ }
" }}}
" ##### Devicons {{{
let g:webdevicons_enable = 1
let g:webdevicons_enable_nerdtree = 1
let g:WebDevIconsUnicodeGlyphDoubleWidth = 0

if exists('g:loaded_webdevicons')
  call webdevicons#refresh()
endif

autocmd FileType nerdtree setlocal nolist
" }}}
" ##### Airline  {{{
let g:airline_theme = 'gruvbox'
let g:airline_inactive_collapse = 0
let g:airline_powerline_fonts = 1

function! ModeChar ()
  return toupper(mode())
endfunction

call airline#parts#define_function('mode', 'ModeChar')
call airline#parts#define_minwidth('mode', 1)

function! ReadonlyIndicator ()
  if &readonly
    return ''
  endif

  return ''
endfunction

call airline#parts#define_function('readonly', 'ReadonlyIndicator')
call airline#parts#define_minwidth('readonly', 1)

function! ModifiedIndicator ()
  if &mod
    return '●'
  endif

  return ''
endfunction

call airline#parts#define_function('modified', 'ModifiedIndicator')
call airline#parts#define_minwidth('modified', 1)

call airline#parts#define_function('icon', 'WebDevIconsGetFileTypeSymbol')
call airline#parts#define_minwidth('icon', 1)

let g:airline_section_a = airline#section#create(['mode'])
let g:airline_section_b = airline#section#create(['branch'])
let g:airline_section_c = airline#section#create([
  \ '%<', 'readonly', 'icon',
  \ ' %{get(b:, "term_title", expand("%:t"))} ',
  \ 'modified'
  \ ])

let g:airline_section_x = airline#section#create_right([
  \ '%{get(b:, "coc_current_function", "")}'
  \ ])
let g:airline_section_y = airline#section#create_right([])
let g:airline_section_z = airline#section#create_right([
  \ '%l:%c %L'
  \ ])

let g:airline#extensions#default#section_truncate_width = {
  \ 'a': 60,
  \ 'b': 80,
  \ 'x': 100,
  \ 'y': 30,
  \ 'z': 60,
\ }

let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'
" }}}
" ##### VISTA {{{
let g:vista_default_executive = 'coc'
let g:vista_echo_cursor_strategy = 'both'
" }}}
" ##### FZF  {{{
let $FZF_DEFAULT_OPTS = '--layout=reverse'

function! NewFloat()
  let opts = {
        \  'relative': 'editor',
        \  'anchor': 'NW',
        \  'col': float2nr((&columns - (&columns * 0.8))/2),
        \  'row': 1,
        \  'width': float2nr(&columns * 0.8),
        \  'height': float2nr(&lines * 0.6)
        \}

  let b = nvim_create_buf(v:false, v:true)
  let w = nvim_open_win(b, v:true, opts)
  startinsert

  call setwinvar(w, '&winhl', 'Normal:Pmenu')

  setlocal
        \ buftype=nofile
        \ nobuflisted
        \ bufhidden=hide
        \ nonumber
        \ norelativenumber
        \ signcolumn=no

endfunction

let g:fzf_layout = { 'window': 'call NewFloat()' }

" Likewise, Files command with preview window
command! -bang -nargs=? -complete=dir GFiles
  \ call fzf#vim#gitfiles(
  \   getcwd(),
  \   fzf#vim#with_preview()
  \ )
" Similarly, we can apply it to fzf#vim#grep. To use ripgrep instead of ag:
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(),
  \   <bang>0)
nnoremap <C-P> :GFiles<cr>
nnoremap <C-F> :Rg<cr>
nnoremap <C-B> :Buffers<cr>
" }}}
" ##### Yankstack  {{{
" Don't use default mappings
nmap p <Plug>(miniyank-autoput)
nmap P <Plug>(miniyank-autoPut)

nmap <CR> <Plug>(miniyank-cycle)
nmap <BS> <Plug>(miniyank-cycleback)
" }}}
" ##### Closetag  {{{
let g:closetag_filenames = '*.xhtml,*.js,*.jsx'
" }}}
" ##### Number toggle  {{{
let g:NumberToggleTrigger="<leader>ll"
"}}}
" ##### Javascript JSX {{{
let g:jsx_ext_required = 0 " Allow JSX in normal JS files
"}}}
" ##### Terraform {{{
let g:terraform_fmt_on_save = 1
" }}}
" ##### indent guides {{{
let g:indentguides_spacechar = '┆'
let g:indentguides_tabchar = '|'
let g:indentguides_ignorelist = ['help', 'text', 'nerdtree']

" }}}
" ##### togglelist {{{
let g:toggle_list_copen_command="Copen"
" }}}
" ##### localvimrc {{{
let g:localvimrc_whitelist=$HOME.'/Documents'
let g:localvimrc_persistent=1
" }}}
" ##### editorconfig {{{
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*', 'term://.*']
" }}}
" ##### echodoc {{{
let g:echodoc_enable_at_startup = 1
" }}}
" ##### display images {{{
"autocmd BufEnter *.png,*.jpg,*.gif exec "! kitty +kitten icat --transfer-mode=stream ".expand("%") | :bw
" }}}
" ##### language client {{{

" Required for operations modifying multiple buffers like rename.
set hidden
" Better visibility of messages
set cmdheight=2
" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300
" don't give |ins-completion-menu| messages.
set shortmess+=c
" always show signcolumns
set signcolumn=yes
" ##### Language Client

" Give more memory to Node
let g:coc_node_args = ['--max-old-space-size=16384']

" Use `[c` and `]c` for navigate diagnostics
nmap <silent> <leader>[ <Plug>(coc-diagnostic-prev)
nmap <silent> <leader>] <Plug>(coc-diagnostic-next)
nmap <silent> <leader>wtf <Plug>(coc-diagnostic-info)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Remap Prettier
nmap <silent> <leader>pp :CocCommand prettier.formatFile<CR>

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
hi CocHighlightText cterm=underline
hi link CocHighlightRead CocHighlightText
hi link CocHighlightWrite CocHighlightText

autocmd CursorHold * silent call CocActionAsync('highlight')

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region
vmap <leader>vca  <Plug>(coc-codeaction-selected)
nmap <leader>vca <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ca  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Use `:Format` for format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` for fold current buffer
command! -nargs=? Fold :call   CocAction('fold', <f-args>)

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent> <leader>d  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <leader>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <leader>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <leader>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <leader>s  :<C-u>CocList -I symbols<cr>
" Resume latest coc list.
nnoremap <silent> <leader>p  :<C-u>CocListResume<CR>
" Open coc marketplace.
nnoremap <silent> <leader>m  :<C-u>CocList marketplace<CR>

""" Multiple cursors
let g:VM_maps = {}
let g:VM_maps["Add Cursor Down"] = '<A-Down>'
let g:VM_maps["Add Cursor Up"]   = '<A-Up>'
let g:VM_maps["Undo"]            = 'u'
let g:VM_maps["Redo"]            = '<C-r>'
let g:VM_maps["Select l"]        = ''
let g:VM_maps["Select h"]        = ''

" }}}
" ##### Copilot {{{
lua << EOF

require('copilot').setup({
  suggestion = {
    auto_trigger = true,
    keymap = {
      accept = "<C-Return>"
    }
  }
})

EOF

" ##### Code Companion {{{
lua << EOF
require("codecompanion").setup({
  opts = {
    log_level = "DEBUG", -- or "TRACE"
  }
})
EOF
" }}}
" ##### Filetype-specific  {{{
" ##### Ruby  {{{
" Specific shiftwidth for ruby files
autocmd FileType ruby set shiftwidth=2
autocmd FileType ruby set tabstop=2
" Convert tabs to spaces in Ruby files
autocmd FileType ruby set expandtab

" But not for erb files...
autocmd FileType eruby set shiftwidth=4
autocmd FileType eruby set tabstop=4
"
" Remaps textobj-rubyblock's bindings to vim's defaults
autocmd FileType ruby map aB ar
autocmd FileType ruby map iB ir
" }}}
" ##### CoffeeScript  {{{
" CJSX is also Coffee, with JSX
autocmd BufRead,BufNewFile *.cjsx set filetype=coffee
" Convert tabs to spaces in Coffee files
autocmd FileType coffee set expandtab
" }}}
" ##### Puppet  {{{
" Specific shiftwidth for puppet files
autocmd BufRead,BufNewFile *.pp set filetype=puppet
autocmd BufRead,BufNewFile Puppetfile set filetype=ruby

" And custom tab sizes too
autocmd FileType puppet set shiftwidth=2
autocmd FileType puppet set tabstop=2
" }}}
" ##### Markdown  {{{
" Sets markdown syntax for *.md files.
autocmd BufRead,BufNewFile *.md,*.markdown set filetype=ghmarkdown

" Wrap markdown files.
autocmd BufRead,BufNewFile *.md set wrap
" }}}
" ##### JavaScript  {{{

autocmd BufRead,BufNewFile *.js set shiftwidth=2
autocmd BufRead,BufNewFile *.js set expandtab

" Sets html syntax for *.ejs files.
autocmd BufRead,BufNewFile *.ejs set filetype=html

" Sets JSX syntax for all .js files
let g:jsx_ext_required = 0
" }}}
" ##### Vim {{{
" Make vimrcs open folded
autocmd FileType vim set foldlevel=0
autocmd FileType vim set foldmethod=marker
" }}}
" ##### XML {{{
" Automatically format XML files
nnoremap <leader>xb :%s,>[ <tab>]*<,>\r<,g<cr> gg=G
" }}}
" ##### LiveScript {{{
autocmd BufRead,BufNewFile *.ls set filetype=ls
autocmd FileType ls set shiftwidth=2
autocmd FileType ls set tabstop=2
" }}}
" ##### YAML {{{
autocmd FileType yaml set shiftwidth=2
autocmd FileType yaml set tabstop=2
" }}}
" ##### LookML {{{
" Sets YAML syntax for *.lookml files.
autocmd BufRead,BufNewFile *.lookml set filetype=yaml
" }}}
" ##### Erlang {{{
autocmd BufRead,BufNewFile *.erl set filetype=erlang
autocmd FileType erlang set shiftwidth=2
autocmd FileType erlang set tabstop=2
" }}}
" ##### Elixir {{{
autocmd BufRead,BufNewFile *.ex set filetype=elixir
autocmd BufRead,BufNewFile *.exs set filetype=elixir
autocmd FileType elixir set shiftwidth=2
autocmd FileType elixir set tabstop=2
" }}}
" ##### Go {{{
autocmd FileType go set foldmethod=syntax

autocmd FileType go let g:go_highlight_functions = 1
autocmd FileType go let g:go_highlight_methods = 1
autocmd FileType go let g:go_highlight_fields = 1
autocmd FileType go let g:go_highlight_types = 1
autocmd FileType go let g:go_highlight_operators = 1
autocmd FileType go let g:go_highlight_build_constraints = 1

autocmd BufWritePost *.go :GoImports
" }}}
" ##### Rocker {{{
autocmd BufRead,BufNewFile Rockerfile* set filetype=dockerfile
" }}}
" ##### Fish {{{
autocmd FileType fish compiler fish
autocmd FileType fish setlocal textwidth=79
autocmd FileType fish setlocal foldmethod=expr
" }}}
" }}}
" }}}

autocmd BufEnter * if &buftype ==# 'terminal' | set signcolumn=no | endif
function! Clear()
    :execute "set scrollback=1"
    :execute "set scrollback=-1"
endfunction
:command! -nargs=0 Clear :call Clear()

" ##### Configure workspace {{{
" Open terminal if no terminal is open
if len(filter(getbufinfo(), 'v:val.name =~ "term:"')) == 0
  execute 'bot 14new ' . termshell . ' | wincmd p'
endif
" }}}

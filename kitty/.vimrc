set nocompatible

syntax enable
filetype plugin on

" by default; too long lines will be hidden 
" file line numbers displayed to the left
" underline line of current cursor position
set nowrap
" set relativenumber
set cursorline

" insert 2 spaces for each tab
set tabstop=4
set expandtab

" don't save backup files
set nobackup

" set minimum number of lines to keep cursor in view
set scrolloff=5

" FINDING FILES:

" search down into subfolders
" search reccursively through all subdir add to path
set path+=**

" TAG JUMPING
command! MakeTags !ctags -R

" PLUGINS
" {{{

" Plugin code goes here

" }}}

" MAPPINGS
" {{{

" Key Mappings go here
inoremap jk <esc>
" set space button as leader key
let mapleader = " "
" space \ to go to previous cursor position
nnoremap <leader>\ ``
" space ; to enter command mode
nnoremap <leader>; :
" clear search highlight on escape
nnoremap <esc> :nohlsearch<CR>
" window navigation
nnoremap <leader>j <c-w>j
nnoremap <leader>k <c-w>k
nnoremap <leader>h <c-w>h
nnoremap <leader>l <c-w>l
nnoremap <leader>ws <c-w>s
nnoremap <leader>wv <c-w>v
nnoremap <leader>q :q<CR>
" buffer navigation
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
" tab navigation
nnoremap <leader>to :tabnew<CR>
nnoremap <leader>tn :tabnext<CR>
nnoremap <leader>tp :tabprevious<CR>
nnoremap <leader>tc :tabclose<CR>
" toggle code fold on current section
nnoremap <tab> zi

" }}}}}}

" VIMSCRIPT 
" {{{

" enable code folding with marker method
augroup filetype_vim
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup END

" only display cursor line on active window
augroup cursor_off
  autocmd!
  autocmd WinLeave * set nocursorline
  autocmd WinEnter * set cursorline
augroup END

" }}}

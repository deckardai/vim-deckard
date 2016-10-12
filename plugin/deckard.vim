" ============================================================================
" File:        deckard.vim
" Description: Deckard connector for Vim.
" Maintainer:  deckard <support@deckard.com>
" License:     MIT, see LICENSE.txt for more details.
" Website:     https://deckard.com/
" ============================================================================

let s:VERSION = '0.2.7'


" Init "

    " Check Vim version "
    if v:version < 700
        echoerr "The Deckard plugin requires vim >= 7."
        finish
    endif

    " Only load plugin once "
    if exists("g:DdLoaded")
        finish
    endif
   let g:DdLoaded = 1
    
    " Detect python support "
    if has('python')
        command! -nargs=1 DdPython2or3 python <args>
    elseif has('python3')
        command! -nargs=1 DdPython2or3 python3 <args>
    else
        echoerr "The Deckard plugin requires python support, either 2 or 3."
        finish
    endif

    " Backup & Override cpoptions "
    let s:old_cpo = &cpo
    set cpo&vim


" Switch to a slightly less insane language "
DdPython2or3 << EOF

import json
import vim

def DdGetPath():
    #path = vim.eval('expand("%:p")')
    path = vim.current.buffer.name
    if (
        not path or
        "-MiniBufExplorer-" in path or
        "--NO NAME--" in path or
        "term:" in path
    ):
        return None
    return path

def DdBufEnter():
    print('New file!', vim.current)

def DdBufWritePost():
    print('Write!')

def DdCursorHold():
    path = DdGetPath()
    if not path:
        return
    (lineno, charno) = vim.current.window.cursor

    event = {
        "path": path,
        "lineno": lineno - 1,
        "charno": charno,
        "editor": "vim",
    }
    print('Refreshing…', json.dumps(event))
    return

EOF


" Capture Events "

    augroup deckard
        autocmd!
        autocmd BufEnter * DdPython2or3 DdBufEnter()
        autocmd BufWritePost * DdPython2or3 DdBufWritePost()
        autocmd CursorHold * DdPython2or3 DdCursorHold()
    augroup END

    " For CursorHold
    set updatetime=300


" Restore cpoptions "
let &cpo = s:old_cpo

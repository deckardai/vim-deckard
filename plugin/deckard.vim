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

import sys
import json
import vim

if sys.version_info[0] >= 3:
    import http.client as httplib
else:
    import httplib

DdHost = "localhost:3325"


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

def DdBufWritePost():
    path = DdGetPath()
    if not path:
        return
    try:
        DdPost("change", {
            "fullPath": path,
        })
    except Exception as e:
        # Normal if Deckard is not running
        pass

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
    try:
        DdPost("event", event)
    except Exception as e:
        # Normal if Deckard is not running
        pass
    return

def DdPost(eventName, event):
    " Fire and forget an event "
    conn = httplib.HTTPConnection(DdHost, timeout=1)
    conn.request(
        "POST", "/" + eventName,
        body=json.dumps(event),
        headers={
            "Content-Type": "application/json",
        },
    )
    conn.close()

EOF


" Capture Events "

    augroup deckard
        autocmd!
        autocmd BufWritePost * DdPython2or3 DdBufWritePost()
        autocmd CursorHold * DdPython2or3 DdCursorHold()
    augroup END

    " For CursorHold "
    set updatetime=200


" Restore cpoptions "
let &cpo = s:old_cpo

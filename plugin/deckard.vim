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

DdHost = "localhost:3325"

import sys
import os
import json
from time import time
import vim

try:
    if sys.version_info[0] >= 3:
        import http.client as httplib
    else:
        import httplib

    # Detect vim flavor
    DdEditor = "vim"
    if vim.eval("has('gui_running')") == "1":
        DdEditor = "gvim"
    elif vim.eval("has('nvim')") == "1":
        DdEditor = "nvim"
    # Get a unique name
    DdEditor += ":" + str(int(time()))
    # Or ":" + vim.eval("v:servername")

    DdOk = True
except Exception as e:
    # httplib can fail mysteriously in unusual environments, ex. git commit
    DdOk = False

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
    try:
        path = DdGetPath()
        if not path:
            return
        DdPost("change", {
            "fullPath": path,
        })
    except Exception as e:
        # Normal if Deckard is not running
        pass

def DdCursorHold():
    try:
        path = DdGetPath()
        if not path:
            return
        (lineno, charno) = vim.current.window.cursor

        event = {
            "path": path,
            "lineno": lineno - 1,
            "charno": charno,
            # Detect current instance server name
            "editor": DdEditor,
        }
        DdPost("event", event)
    except Exception as e:
        # Normal if Deckard is not running
        pass

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

if DdOk:
    # Import the module shipping with the plugin
    thisFile = vim.eval("expand('<sfile>:p')")
    sys.path.insert(0, os.path.dirname(thisFile))
    import ddEditorLib

    def DdOpenPath(path, line=0, column=0):
        path = path.replace("\\", "\\\\").replace(" ", "\ ").replace("|", "\|")
        cmd = "edit %s | call cursor(%i,%i) | redraw!" % (path, line, column)
        print(cmd)
        vim.command(cmd)

    ddEditorLib.listen(
        name=DdEditor,
        functions={
            "openPath": DdOpenPath,
        }
    )

EOF


" Capture Events "

    augroup deckard
        autocmd!
        autocmd BufWritePost * DdPython2or3 DdOk and DdBufWritePost()
        autocmd CursorHold * DdPython2or3 DdOk and DdCursorHold()
    augroup END

    " For CursorHold "
    set updatetime=200


" Restore cpoptions "
let &cpo = s:old_cpo

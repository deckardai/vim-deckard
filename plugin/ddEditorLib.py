# -*- coding: utf-8 -*-

# Test with:
#     echo '{"method":"openPath","params":["/SOME PATH", 13, 5]}' | socat - GOPEN:$HOME/.dcode/vim\:TIMESTAMP.sock


import os
from os.path import exists, expanduser
import socket
import threading
import json


DCODE_DIR = expanduser("~/.dcode")


def hardcoreJsonRpc(socketPath, functions):
    " A minimal dependency-free JsonRpc implementation "

    if exists(socketPath):
        os.remove(socketPath)
    server = socket.socket( socket.AF_UNIX, socket.SOCK_DGRAM )
    server.bind(socketPath)

    print("Listening...", socketPath)
    while True:
        datagram = server.recv(1024)
        if not datagram:
            break

        try:
            j = json.loads(datagram)
            # Handle method
            funcName = j.get("method")
            if funcName == "exit":
                break
            func = functions.get(funcName)
            if func:
                params = j.get("params") or []
                func(*params)

        except Exception as err:
            print(err)

    server.close()
    if exists(socketPath):
        os.remove(socketPath)


def listen(name, functions):

    if not exists(DCODE_DIR):
        os.makedirs(DCODE_DIR)

    socketPath = "%s/%s.sock" % (DCODE_DIR, name)

    thread = threading.Thread(
        target=hardcoreJsonRpc,
        args=(socketPath, functions),
    )
    thread.setDaemon(True)
    thread.start()
    return thread


if __name__ == "__main__":
    listen("vim", {})

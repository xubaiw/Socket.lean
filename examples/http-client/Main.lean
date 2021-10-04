/-
  Copyright (c) 2021 Xubai Wang. All rights reserved.
  Released under Apache 2.0 license as described in the file LICENSE.
  Authors: Xubai Wang
-/

import Socket

def main : IO Unit := do
  -- configure remote SockAddr
  let remoteAddr ← SockAddr.mk {
    host := "www.example.com"
    port := "80"
    family := inet
    type := stream
  }
  IO.println s!"Remote Addr: {remoteAddr}"

  -- connect to remote
  let socket ← Socket.mk inet stream
  socket.connect remoteAddr
  IO.println "Connected!"

  -- send HTTP request
  let strSend := 
    "GET / HTTP/1.1\r\n" ++
    "Host: www.example.com\r\n" ++
    "\r\n\r\n"
  let bytesSend ← socket.send strSend.toUTF8
  IO.println s!"Send {bytesSend} bytes!\n"

  -- get HTTP response and print it out
  let bytesRecv ← socket.recv 5000
  IO.println "-- Responses --\n"
  IO.println <| String.fromUTF8Unchecked bytesRecv
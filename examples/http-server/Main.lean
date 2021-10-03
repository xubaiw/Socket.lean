/-
  Copyright (c) 2021 Xubai Wang. All rights reserved.
  Released under Apache 2.0 license as described in the file LICENSE.
  Authors: Xubai Wang
-/

import Socket

/--
  Send back hello on accept.
-/
partial def serve (socket : @& Socket) : IO Unit := do
  let (remoteAddr, socket') ← socket.accept
  let t ← IO.asTask do
    let strSend := 
      "HTTP/1.1 200 OK" ++
      "Content-Length:5" ++
      "\r\n\r\n" ++
      "Hello" ++
      "\r\n\r\n"
    let bytesSend ← socket'.send strSend.toUTF8
    socket'.close
  IO.println "Incoming..."
  serve socket

/--
  Entry
-/
def main : IO Unit := do
  -- configure local SockAddr
  let localAddr ← SockAddr.mk {
    host := "localhost"
    port := "8080"
    family := AddressFamily.inet
    type := SockType.stream
  }
  IO.println s!"Local Addr: {localAddr}"

  -- bind a socket to local address
  let socket ← Socket.mk AddressFamily.inet SockType.stream
  socket.bind localAddr
  IO.println "Socket Bound."

  -- listen to HTTP requests
  socket.listen 5
  IO.println s!"Listening at http://localhost:8080."

  -- serving
  serve socket
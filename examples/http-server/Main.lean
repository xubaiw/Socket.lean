import Socket

open Socket

/--
  Entry
-/
def main : IO Unit := do
  -- configure local SockAddr
  let localAddr ← SockAddr.mk "localhost" "8080" AddressFamily.inet SockType.stream
  IO.println s!"Local Addr: {localAddr}"

  -- bind a socket to local address
  let socket ← Socket.mk AddressFamily.inet SockType.stream
  socket.bind localAddr
  IO.println "Socket Bound."

  -- listen to HTTP requests
  socket.listen 5
  IO.println s!"Listening at http://localhost:8080."

  -- serving
  repeat do
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
    IO.println s!"Incoming: {remoteAddr}"
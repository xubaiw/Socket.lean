import Socket

open Socket

def main : IO Unit := do
  -- configure remote SockAddr
  let remoteAddr ← SockAddr.mk "www.example.com" "80" AddressFamily.inet SockType.stream
  IO.println s!"Remote Addr: {remoteAddr}"

  -- connect to remote
  let socket ← Socket.mk AddressFamily.inet SockType.stream
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
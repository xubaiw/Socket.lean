import Socket

open Socket

def main : IO Unit := do
  -- Local Address
  IO.println "\n-- Local address --\n"
  let addr ← SockAddr.mk "localhost" "8080"
  IO.print "addr.toString: "
  IO.println addr
  IO.print "addr.family: "
  IO.println addr.family
  IO.print "addr.host: "
  IO.println addr.host
  IO.print "addr.port: "
  IO.println addr.port

  -- Remote Address
  IO.println "\n-- Remote address --\n"
  let addr ← SockAddr.mk "www.example.com" "80" AddressFamily.inet6
  IO.print "addr.toString: "
  IO.println addr
  IO.print "addr.family: "
  IO.println addr.family
  IO.print "addr.host: "
  IO.println addr.host
  IO.print "addr.port: "
  IO.println addr.port
  IO.println ""


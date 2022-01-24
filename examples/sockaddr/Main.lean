import Socket

def main : IO Unit := do
  -- Local Address
  IO.println "\n-- Local address --\n"
  let addr ← SockAddr.mk {
    host := "localhost"
    port := "8080"
  }
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
  let addr ← SockAddr.mk {
    host := "www.example.com"
    port := "80"
    family := AddressFamily.inet6
  }
  IO.print "addr.toString: "
  IO.println addr
  IO.print "addr.family: "
  IO.println addr.family
  IO.print "addr.host: "
  IO.println addr.host
  IO.print "addr.port: "
  IO.println addr.port
  IO.println ""


/-
  Copyright (c) 2021 Xubai Wang. All rights reserved.
  Released under Apache 2.0 license as described in the file LICENSE.
  Authors: Xubai Wang
-/

import Socket

def main : IO Unit := do
  -- dns
  let remote ← SockAddr.mk {
    host := "www.example.com"
    port := "80"
    family := AddressFamily.inet
    type := SockType.stream
  }
  IO.println s!"Remote: {remote}"

  -- -- accept
  -- let addrLocal ← SockAddr.mk {
  --   host := "localhost"
  --   port := "8080"
  --   family := AddressFamily.inet
  --   type := SockType.stream
  -- }
  -- IO.println addrLocal
  -- let socket ← Socket.mk AddressFamily.inet SockType.stream
  -- socket.bind addrLocal
  -- socket.listen 5
  -- let (a, s) ← socket.accept
  -- IO.println a

  let s ← Socket.mk AddressFamily.inet SockType.stream
  s.connect remote

  IO.println "success"
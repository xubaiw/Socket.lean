/-
  Copyright (c) 2021 Xubai Wang. All rights reserved.
  Released under Apache 2.0 license as described in the file LICENSE.
  Authors: Xubai Wang
-/

import Socket

def main : IO Unit := do
  -- Local Address
  IO.println "\n-- Local address --\n"
  let addr₀ ← SockAddr.mk {
    host := "localhost"
    port := "8080"
  }
  IO.print "addr₀.toString: "
  IO.println addr₀
  IO.print "addr₀.family: "
  IO.println addr₀.family
  IO.print "addr₀.host: "
  IO.println addr₀.host
  IO.print "addr₀.port: "
  IO.println addr₀.port

  -- Remote Address
  IO.println "\n-- Remote address --\n"
  let addr₁ ← SockAddr.mk {
    host := "www.example.com"
    port := "80"
    family := AddressFamily.inet6
  }
  IO.print "addr₁.toString: "
  IO.println addr₁
  IO.print "addr₁.family: "
  IO.println addr₁.family
  IO.print "addr₁.host: "
  IO.println addr₁.host
  IO.print "addr₁.port: "
  IO.println addr₁.port
  IO.println ""


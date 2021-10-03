/-
  Copyright (c) 2021 Xubai Wang. All rights reserved.
  Released under Apache 2.0 license as described in the file LICENSE.
  Authors: Xubai Wang
-/

import Socket

def main : IO Unit := do

  IO.println "This example listens for localhost:8080.
              Try curl http://localhost:8080 to see the result from command line."

  let addr₀ ← SockAddr.mk {
    host := "localhost"
    port := "8080"
    family := AddressFamily.inet
    type := SockType.stream
  }
  IO.println "The addr local is:"
  IO.println addr₀

  let s₀ ← Socket.mk AddressFamily.inet SockType.stream
  s₀.bind addr₀
  s₀.listen 5
  let (addr₁, s₁) ← s₀.accept
  IO.println "The addr connected is:"
  IO.println addr₁

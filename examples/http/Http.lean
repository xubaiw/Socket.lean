/-
  Copyright (c) 2021 Xubai Wang. All rights reserved.
  Released under Apache 2.0 license as described in the file LICENSE.
  Authors: Xubai Wang
-/

import Socket

def main : IO Unit := do
  let s ← SockAddr.mk {
    host := "www.example.com"
    port := "80"
    family := AddressFamily.inet
    type := SockType.stream
  }
  IO.println "Remote Info:"
  
  IO.println s!"host: {s.host} port: {s.port} family: {s.family}"
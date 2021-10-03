/-
  Copyright (c) 2021 Xubai Wang. All rights reserved.
  Released under Apache 2.0 license as described in the file LICENSE.
  Authors: Xubai Wang
-/

import Socket

def main : IO Unit := do
  let addr ← SockAddr.mk {
    host := "localhost"
    port := "8080"
  }
  IO.println addr.family
  IO.println addr.host
  IO.println addr.port
  IO.println addr.length


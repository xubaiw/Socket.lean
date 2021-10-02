/-
  Copyright (c) 2021 Xubai Wang. All rights reserved.
  Released under Apache 2.0 license as described in the file LICENSE.
  Authors: Xubai Wang
-/

import Socket

def main : IO Unit := do
  let s ← Socket.mk SockDomain.inet SockType.stream
  s.close
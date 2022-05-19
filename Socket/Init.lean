namespace Socket

/-!
  # Socket Initialization

  This module automatically initializes the socket environment, and users need not care about it.
  To initialization the environment, two steps are required:

  1. Register external classes like `Socket` and `SockAddr`
  2. Call platform specific startup code.
  3. Register platform specific cleanup code.

 -/

/-- The initialization function. Users shouldn't call this. -/
@[extern "lean_socket_initialize"]
constant initSocket : IO Unit

builtin_initialize initSocket

end Socket

namespace Socket

/--
  Initialize the socket environment.

  This function does the following things:
  1. register `Socket` and `SockAddr` type from external class
  2. call `WSAStartup` on windows
  3. register `WSACleanup` on windows

  This function should always and only be called with `initialize initSocket`.
 -/
@[extern "lean_socket_initialize"]
constant initSocket : IO Unit

builtin_initialize initSocket

end Socket
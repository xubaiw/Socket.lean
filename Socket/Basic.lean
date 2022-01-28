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
private constant initSocket : IO Unit

builtin_initialize initSocket

/--
  The low-level networking primitives for lean.

  To create a `Socket`, refer to `Socket.mk`, and then you can manipulate
  the `Socket` using common socket functions like `Socket.bind`, `Socket.connect`, etc.

  ### Note

  The `Socket` type is made opaque since implementation of socket may
  be different across platforms (`int` on *nix and `SOCKET` on Windows).
-/
constant Socket : Type

/--
  This structure holds both the length and the content for the C `sockaddr`.
-/
constant SockAddr : Type

/-- Wrapper for AF_*** constants like AF_INET6, see `Socket.mk` for usage. -/
inductive AddressFamily where
  | unspecified
  | inet
  | inet6
  deriving Inhabited

export AddressFamily (inet inet6)

instance : ToString AddressFamily where
  toString : AddressFamily → String
    | AddressFamily.unspecified => "AF_UNSPEC"
    | AddressFamily.inet => "AF_INET"
    | AddressFamily.inet6 => "AF_INET6"

/-- Wrapper for SOCK_*** constants like SOCK_STREAM, see `Socket.mk` for usage. -/
inductive SockType where
  | unspecified
  | stream
  | dgram
  deriving Inhabited

export SockType (stream dgram)

instance : ToString SockType where
  toString : SockType → String
    | SockType.unspecified => "SOCK_UNSPEC"
    | SockType.stream => "SOCK_STREAM"
    | SockType.dgram => "SOCK_DGRAM"

/-- Wrapper for SHUT_*** constants like SHUT_RD, see `Socket.shutdown` for usage. -/
inductive ShutdownHow where
  | read
  | write
  | readwrite
  deriving Inhabited

@[extern "lean_gethostname"] constant hostname : IO String

end Socket
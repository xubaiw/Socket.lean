/-
  Copyright (c) 2021 Xubai Wang. All rights reserved.
  Released under Apache 2.0 license as described in the file LICENSE.
  Authors: Xubai Wang
-/

import Init.System.IOError

--------------------------------------------------------------------------------
-- # Initialization
--------------------------------------------------------------------------------

/--
  Initialize the socket environment.

  This function does the following things:
  1. register `Socket` type from external class
  2. call `WSAStartup` on windows
  3. register `WSACleanup` on windows

  This function should always and only be called with `initialize initSocket`.
 -/
@[extern "lean_socket_initialize"] constant initSocket : IO Unit

builtin_initialize initSocket

--------------------------------------------------------------------------------
-- # Types
--------------------------------------------------------------------------------

/--
  The low-level networking primitives for lean.

  To create a `Socket`, refer to `Socket.mk`, and then you can manipulate
  the `Socket` using common socket functions like `Socket.bind`, `Socket.connect`, etc.

  ### Note

  The `Socket` type is made opaque since implementation of socket may
  be different across platforms (`int` on *nix and `SOCKET` on Windows).
-/
constant Socket : Type := Unit

/--
  This structure holds both the length and the content for the C `sockaddr`.
-/
constant SockAddr : Type := Unit

/-- Wrapper for PF_*** constants like PF_INET6, see `Socket.mk` for usage. -/
inductive AddressFamily where
  | unspecified
  | inet
  | inet6
  deriving Inhabited

/-- Wrapper for SOCK_*** constants like SOCK_STREAM, see `Socket.mk` for usage. -/
inductive SockType where
  | zero
  | stream
  | dgram
  deriving Inhabited

/-- Wrapper for SHUT_*** constants like SHUT_RD, see `Socket.shutdown` for usage. -/
inductive ShutdownHow where
  | read
  | write
  | readwrite
  deriving Inhabited

--------------------------------------------------------------------------------
-- # Behaviors
--------------------------------------------------------------------------------

-- ## Socket

namespace Socket

/--
  Create a new `Socket` using the specified domain and type.
-/
@[extern "lean_socket_mk"] constant mk (d : AddressFamily) (t : SockType) : IO Socket

/--
  Close the `Socket`.

  ### Note

  Although Socket is designed to be automatically closed when garbage collected,
  it's a good practice to manually close it beforehand.
-/
@[extern "lean_socket_close"] constant close (s : @& Socket) : IO Unit

/--
  Initiate a connection on a socket.
-/
@[extern "lean_socket_connect"] constant connect (s : @& Socket) (a : @& SockAddr) : IO Unit

/--
  Bind a name to a socket.
-/
@[extern "lean_socket_bind"] constant bind (s : @& Socket) (a : @& SockAddr) : IO Unit

/--
  Listen for connections on a socket.
-/
@[extern "lean_socket_listen"] constant listen (s : @& Socket) (n : @& UInt8) : IO Unit

/--
  Accept a connection on a socket.
-/
@[extern "lean_socket_accept"] constant accept (s : @& Socket) : IO (SockAddr × Socket)

/--
  Send a message from a socket.
-/
@[extern "lean_socket_send"] constant send (s : @& Socket) (b : @& ByteArray) : IO USize

/--
  Receive a message from a socket.
-/
@[extern "lean_socket_send"] constant recv (s : @& Socket) (n : @& USize) : IO ByteArray

/--
  Send a message from a socket.
-/
@[extern "lean_socket_sendto"] constant sendto (s : @& Socket) (b : @& ByteArray) (a : @& SockAddr) : IO USize

/--
  Receive a message from a socket.
-/
@[extern "lean_socket_recvfrom"] constant recvfrom (s : @& Socket) (n : @& USize) : IO (SockAddr × ByteArray)

/--
  Shut down part of a full-duplex connection.
-/
@[extern "lean_socket_shutdown"] constant shutdown (s : @& Socket) (h : ShutdownHow) : IO Unit 

end Socket

-- ## AddressFamily

instance : ToString AddressFamily where
  toString : AddressFamily → String
    | AddressFamily.unspecified => "AF_UNSPEC"
    | AddressFamily.inet => "AF_INET"
    | AddressFamily.inet6 => "AF_INET6"

-- ## SockType

instance : ToString SockType where
  toString : SockType → String
    | SockType.zero => "0"
    | SockType.stream => "SOCK_STREAM"
    | SockType.dgram => "SOCK_DGRAM"

-- ## SockAddr

namespace SockAddr

structure SockAddrArgs where
  host : String
  port : String
  family : AddressFamily := AddressFamily.unspecified
  type : SockType := SockType.zero
  deriving Inhabited

/--
  This function internally calls getaddrinfo.
-/
@[extern "lean_sockaddr_mk"] constant mk (a : @& SockAddrArgs) : IO SockAddr

@[extern "lean_sockaddr_length"] constant length (a : @&SockAddr) : UInt32

@[extern "lean_sockaddr_family"] constant family (a : @&SockAddr) : AddressFamily

@[extern "lean_sockaddr_port"] constant port (a : @&SockAddr) : Option UInt16

@[extern "lean_sockaddr_host"] constant host (a : @&SockAddr) : Option String

end SockAddr

instance : ToString SockAddr where
  toString a := s!"{a.host}:{a.port}({a.family})"
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

/-- Wrapper for SOCK_*** constants like SOCK_STREAM, see `Socket.mk` for usage. -/
inductive SockType where
  | unspecified
  | stream
  | dgram
  deriving Inhabited

export SockType (stream dgram)

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
@[extern "lean_socket_mk"] constant mk (d : @& AddressFamily) (t : @& SockType) : IO Socket

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
@[extern "lean_socket_recv"] constant recv (s : @& Socket) (n : @& USize) : IO ByteArray

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

/--
  Get address of connected peer.
-/
@[extern "lean_socket_peer"] constant peer (s : @& Socket) : IO SockAddr

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
    | SockType.unspecified => "SOCK_UNSPEC"
    | SockType.stream => "SOCK_STREAM"
    | SockType.dgram => "SOCK_DGRAM"

-- ## SockAddr

namespace SockAddr

structure SockAddrArgs where
  host : String
  port : String
  family : AddressFamily := AddressFamily.unspecified
  type : SockType := SockType.unspecified
  deriving Inhabited

/--
  This function internally calls getaddrinfo.
-/
@[extern "lean_sockaddr_mk"] constant mk (a : @& SockAddrArgs) : IO SockAddr

@[extern "lean_sockaddr_family"] constant family (a : @& SockAddr) : Option AddressFamily

@[extern "lean_sockaddr_port"] constant port (a : @& SockAddr) : Option UInt16

@[extern "lean_sockaddr_host"] constant host (a : @& SockAddr) : Option String

end SockAddr

instance : ToString SockAddr where
  toString a := 
    let host := a.host.getD "none"
    let port := a.port.map (s!"{·}") |>.getD "none"
    let family := a.family.map (s!"{·}") |>.getD "none"
    s!"({host}, {port}, {family})"

-- ## Other Functions

@[extern "lean_gethostname"] constant hostName : IO String
import Socket.Basic

namespace Socket
namespace Socket

/--
  Create a new `Socket` using the specified domain and type.
-/
@[extern "lean_socket_mk"] opaque mk (d : @& AddressFamily) (t : @& SockType) : IO Socket

/--
  Close the `Socket`.

  *NOTE:* Although Socket is designed to be automatically closed when garbage collected,
  it's a good practice to manually close it beforehand.
-/
@[extern "lean_socket_close"] opaque close (s : @& Socket) : IO Unit

/--
  Initiate a connection on a socket.
-/
@[extern "lean_socket_connect"] opaque connect (s : @& Socket) (a : @& SockAddr) : IO Unit

/--
  Bind a name to a socket.
-/
@[extern "lean_socket_bind"] opaque bind (s : @& Socket) (a : @& SockAddr) : IO Unit

/--
  Listen for connections on a socket.
-/
@[extern "lean_socket_listen"] opaque listen (s : @& Socket) (n : @& UInt8) : IO Unit

/--
  Accept a connection on a socket.
-/
@[extern "lean_socket_accept"] opaque accept (s : @& Socket) : IO (SockAddr × Socket)

/--
  Send a message from a socket.
-/
@[extern "lean_socket_send"] opaque send (s : @& Socket) (b : @& ByteArray) : IO USize

/--
  Receive a message from a socket.
-/
@[extern "lean_socket_recv"] opaque recv (s : @& Socket) (n : @& USize) : IO ByteArray

/--
  Send a message from a socket.
-/
@[extern "lean_socket_sendto"] opaque sendto (s : @& Socket) (b : @& ByteArray) (a : @& SockAddr) : IO USize

/--
  Receive a message from a socket.
-/
@[extern "lean_socket_recvfrom"] opaque recvfrom (s : @& Socket) (n : @& USize) : IO (SockAddr × ByteArray)

/--
  Shut down part of a full-duplex connection.
-/
@[extern "lean_socket_shutdown"] opaque shutdown (s : @& Socket) (h : ShutdownHow) : IO Unit 

/--
  Get address of connected peer.
-/
@[extern "lean_socket_peer"] opaque peer (s : @& Socket) : IO SockAddr

end Socket
end Socket

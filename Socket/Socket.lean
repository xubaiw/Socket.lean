import Socket.Basic

namespace Socket
namespace Socket

/--
  Create a new `Socket` using the specified domain and type.
-/
@[extern "lean_socket_mk"] constant mk (d : @& AddressFamily) (t : @& SockType) : IO Socket

/--
  Close the `Socket`.

  *NOTE:* Although Socket is designed to be automatically closed when garbage collected,
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
end Socket

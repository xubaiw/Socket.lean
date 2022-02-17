import Socket.Basic

namespace Socket
namespace SockAddr

/-- Argument for [`SockAddr.mk`](##Socket.SockAddr.mk). -/
structure SockAddrArgs where
  host : String
  port : String
  family : AddressFamily := AddressFamily.unspecified
  type : SockType := SockType.unspecified
  deriving Inhabited

/-- Create a [`SockAddr`](##Socket.SockAddr). -/
@[extern "lean_sockaddr_mk"] constant mk (a : @& SockAddrArgs) : IO SockAddr

/-- Get family of the [`SockAddr`](##Socket.SockAddr). -/
@[extern "lean_sockaddr_family"] constant family (a : @& SockAddr) : Option AddressFamily

/-- Get family of the [`SockAddr`](##Socket.SockAddr). -/
@[extern "lean_sockaddr_port"] constant port (a : @& SockAddr) : Option UInt16

/-- Get family of the [`SockAddr`](##Socket.SockAddr). -/
@[extern "lean_sockaddr_host"] constant host (a : @& SockAddr) : Option String

end SockAddr

/-- Convert [`SockAddr`](##Socket.SockAddr) to `String`. -/
instance : ToString SockAddr where
  toString a := 
    let host := a.host.getD "none"
    let port := a.port.map (s!"{·}") |>.getD "none"
    let family := a.family.map (s!"{·}") |>.getD "none"
    s!"({host}, {port}, {family})"

end Socket

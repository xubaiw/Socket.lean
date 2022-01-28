import Socket.Basic

namespace Socket
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

end Socket

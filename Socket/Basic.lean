
/-!
  # Socket Type Definitions

  This module defines some basic types to be used across whole pacage:

  - [`Socket`](#Socket.Socket): Opaque reference to underlying socket
  - [`SockAddr`](#Socket.SockAddr): Opaque reference to underlying socket address
  - [`AddressFamily`](#Socket.AddressFamily): Enumeration of supported address families
-/

namespace Socket

/-!
  ## Socket
-/

/--
  Use `NonemptyType` to implement `Inhabited` for [`Socket`](#Socket.Socket).
  [detailed explanation](#explanation-usage-of-nonemptytype)
-/
constant Socket.Nonempty : NonemptyType

/--
  Opaque reference to underlying socket.

  To create a `Socket`, refer to [`Socket.mk`](/find/Socket.Socket.mk).
  Then you can manipulate the `Socket` using common socket functions like
  [`bind`](/find/Socket.Socket.bind),
  [`connect`](/find/Socket.Socket.connect), etc. For all functions
  available, refer to the [`Socket`](/Socket.Socket) module.

  *NOTE*: The `Socket` type is made opaque since implementation of socket may
  be different across platforms (`int` on *nix and `SOCKET` on Windows).
-/
def Socket : Type := Socket.Nonempty.type

/--
  Use `NonemptyType` to implement `Inhabited` for [`Socket`](#Socket.Socket).
  [detailed explanation](#explanation-usage-of-nonemptytype)
-/
instance : Nonempty Socket := Socket.Nonempty.property

/--
  Use `NonemptyType` to implement `Inhabited` for [`SockAddr`](#Socket.SockAddr).
  [detailed explanation](#explanation-usage-of-nonemptytype)
-/
constant SockAddr.Nonempty : NonemptyType

/--
  Opaque reference to underlying socket address.

  *NOTE*: Different from the C `sockaddr`, `SockAddr` also includes length.
-/
def SockAddr : Type := SockAddr.Nonempty.type

/--
  Use `NonemptyType` to implement `Inhabited` for [`SockAddr`](#Socket.SockAddr)
  [detailed explanation](#explanation-usage-of-nonemptytype)
-/
instance : Nonempty SockAddr := SockAddr.Nonempty.property

/--
  Enumeration of supported address families,
  which is used in [`Socket.mk`](/find/Socket.Socket.mk).
-/
inductive AddressFamily where
  | unspecified
  | inet
  | inet6
  deriving Inhabited

/-- Convert `AddressFamily` to `String`. -/
instance : ToString AddressFamily where
  toString : AddressFamily → String
    | AddressFamily.unspecified => "AF_UNSPEC"
    | AddressFamily.inet => "AF_INET"
    | AddressFamily.inet6 => "AF_INET6"

/--
  Enumeration of supported socket types,
  which is used in [`Socket.mk`](/find/Socket.Socket.mk).
-/
inductive SockType where
  | unspecified
  | stream
  | dgram
  deriving Inhabited

/-- Convert `SockType` to `String`. -/
instance : ToString SockType where
  toString : SockType → String
    | SockType.unspecified => "SOCK_UNSPEC"
    | SockType.stream => "SOCK_STREAM"
    | SockType.dgram => "SOCK_DGRAM"

/--
  Enumeration of supported socket types,
  which is used in [`Socket.shutdown`](/find/Socket.Socket.shutdown).
-/
inductive ShutdownHow where
  | read
  | write
  | readwrite
  deriving Inhabited

/-- Get hostname of current machine. -/
@[extern "lean_gethostname"] constant hostname : IO String

end Socket

/-!
  ## Explanation: Usage of `NonemptyType`

  As [`Socket`](#Socket.Socket) and [`SockAddr`](#Socket.SockAddr)
  are implemented using `lean_external_class`. `NonemptyType` is used
  to implement `Inhabited` for these types.

  A simple example of this trick can be found
  [here](https://github.com/xubaiw/lean4/blob/c1fccf19cb8f15daba2329e5c82c6feca825c02b/tests/compiler/foreign)
  in Lean core.
-/
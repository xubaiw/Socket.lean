
/-!
  # Socket Type Definitions

  This module defines some basic types to be used across whole pacage:

  - `Socket`: Opaque reference to underlying socket
  - `SockAddr`: Opaque reference to underlying socket address
  - `AddressFamily`: Enumeration of supported address families
-/

namespace Socket

/-!
  ## Socket
-/

/--
  Use `NonemptyType` to implement `Inhabited` for `Socket`.
  [detailed explanation](#explanation-usage-of-nonemptytype)
-/
opaque Socket.Nonempty : NonemptyType

/--
  Opaque reference to underlying platform specific socket.

  To create a `Socket`, refer to [`Socket.mk`](##Socket.Socket.mk). Then you
  can manipulate the `Socket` using common socket functions like
  [`Socket.bind`](##Socket.Socket.bind),[`Socket.connect`](##Socket.Socket.connect),
  etc. For all functions available, refer to the [`Socket` module](Socket/Socket.html).

  *NOTE*: `NonemptyType` is used to implement `Inhabited` for `Socket`. [detailed explanation](#explanation-usage-of-nonemptytype)

  ```lean
  import Socket
  open Socket

  def main : IO Unit := do
    let s ← Socket.mk
    -- some socket operations
    s.close
  ```
-/
def Socket : Type := Socket.Nonempty.type

/--
  Use `NonemptyType` to implement `Inhabited` for `Socket`.
  [detailed explanation](#explanation-usage-of-nonemptytype)
-/
instance : Nonempty Socket := Socket.Nonempty.property

/--
  Use `NonemptyType` to implement `Inhabited` for `SockAddr`.
  [detailed explanation](#explanation-usage-of-nonemptytype)
-/
opaque SockAddr.Nonempty : NonemptyType

/--
  Opaque reference to underlying socket address.

  *NOTE*: Different from the C `sockaddr`, `SockAddr` also includes length.
-/
def SockAddr : Type := SockAddr.Nonempty.type

/--
  Use `NonemptyType` to implement `Inhabited` for `SockAddr`
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
  Enumeration of how is socket shutdown,
  which is used in [`Socket.shutdown`](##Socket.Socket.shutdown).
-/
inductive ShutdownHow where
  | read
  | write
  | readwrite
  deriving Inhabited

/-- Get hostname of current machine. -/
@[extern "lean_gethostname"] opaque hostname : IO String

end Socket

/-!
  ## Explanation: Usage of `NonemptyType`

  As `Socket` and `SockAddr` are implemented using`lean_external_class`.
  `NonemptyType` is used to implement `Inhabited` for these types.

  A simple example of this trick can be found
  [here](https://github.com/xubaiw/lean4/blob/c1fccf19cb8f15daba2329e5c82c6feca825c02b/tests/compiler/foreign)
  in Lean core.
-/
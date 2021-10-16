# Lean4-Socket

A toy implementation of socket programming for Lean 4.

## Installation

### Lake

```lean
import Lake
open System Lake DSL

package foo where
  dependencies := #[{
    name := `socket
    src := Source.git "https://github.com/xubaiw/lean4-socket.git" "main"
    dir := "lake"
  }]
```

## Usage

This prints out yout local address.

```lean 
import Socket

def main : IO Unit := do
  IO.println "\n-- Local address --\n"
  let addr ← SockAddr.mk {
    host := "localhost"
    port := "8080"
  }
  IO.println addr
```

You can also refer to the [http-client](./examples/http-client) and [http-server](./examples/http-server) examples to find the basic usage.

There are bunch of comments in the source code. However, documentation like Hackage or docs.rs is not available since there is no doc genreator for lean4 yet.

To grasp the essence, you should be careful about the `Socket` and `SockAddr` type. 

## Limitations

A lot of things cannot be achieved from this package, e.g.

- Many flags are unavailable now.
- Only blocking sockets are supported (`IO.asTask` as workaround). 
- There should be dependent type constraints like `constant Socket.connect (s : @& Socket) → (a : @& SockAddr) → (h : s.type = SockType.stream) → IO Unit`, which means that only stream sockets can be connected.
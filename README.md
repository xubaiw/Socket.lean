# Lean4-Socket

The socket programming package for Lean 4.

## Installation

### Lake

*NOTE: As `lake` is undergoing breaking changes, the recommended revision to use is [`111a47f`](https://github.com/leanprover/lake/commit/111a47f8964088aa452aa0fcdd0c1d88562cca68), otherwise you may see errors and have to modify the `lakefile.lean` file yourself.*

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

If you are using VSCode, the recommended `lean4.serverEnv` setting is

```json
{
  "lean4.serverEnv": {
    "LEAN_PATH": "${HOME}/lake/build/${pathSeparator}${workspaceFolder}/build/"
  },
}
```

assuming that your lake is installed at ${HOME}/lake/build/

## Usage

This prints out yout local address.

```lean 
import Socket

def main : IO Unit := do
  IO.println "\n-- Local address --\n"
  let addr₀ ← SockAddr.mk {
    host := "localhost"
    port := "8080"
  }
  IO.println addr₀
```

You can also refer to the [http-client](./examples/http-client) and [http-server](./examples/http-server) examples to find the basic usage.

There are bunch of comments in the source code. However, documentation like Hackage or docs.rs is not available since there is no doc genreator for lean4 yet.

To grasp the essence, you should be careful about the `Socket` and `SockAddr` type. 

## Limitations

There is still a long way to go for this package. For example, 

- Many flags are unavailable now.
- Only blocking sockets are supported (`IO.asTask` as workaround). 
- There should be dependent type constraints like `constant Socket.connect (s : @& Socket) → (a : @& SockAddr) → (h : s.type = SockType.stream) → IO Unit`, which means that only stream sockets can be connected.
- More testing and verification.
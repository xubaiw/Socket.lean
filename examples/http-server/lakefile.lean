import Lake
open Lake DSL

package {
  name := "http-server"
  dependencies := #[
    {
      name := "socket"
      src := Source.path "../../lake"
    }
  ]
}

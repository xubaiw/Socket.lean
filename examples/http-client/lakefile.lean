import Lake
open Lake DSL

package {
  name := "http-client"
  dependencies := #[
    {
      name := "socket"
      src := Source.path "../../lake"
    }
  ]
}

import Lake
open Lake DSL

package {
  name := "example"
  binRoot := `Main
  dependencies := [
    {
      name := "socket"
      src := Source.path "../../lake"
    }
  ]
}

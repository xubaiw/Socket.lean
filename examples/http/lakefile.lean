import Lake
open Lake DSL

package {
  name := "http"
  binRoot := `Main
  dependencies := [
    {
      name := "socket"
      src := Source.path "../.."
    }
  ]
}

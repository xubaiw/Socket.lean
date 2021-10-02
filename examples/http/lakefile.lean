import Lake
open Lake DSL

package {
  name := "http"
  dependencies := [
    {
      name := "socket"
      src := Source.path "../.."
    }
  ]
}

import Lake
open System Platform Lake DSL

package http_server where
  dependencies := #[{
    name := `socket
    src := Source.path "../.."
  }]
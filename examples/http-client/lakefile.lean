import Lake
open System Platform Lake DSL

package http_client where
  dependencies := #[{
    name := `socket
    src := Source.path "../.."
  }]
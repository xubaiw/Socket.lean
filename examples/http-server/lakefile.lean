import Lake
open Lake DSL

package http_server where
  dependencies := #[{
    name := `socket
    src := Source.path "../../lake"
  }]
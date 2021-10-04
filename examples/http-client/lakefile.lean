import Lake
open Lake DSL

package http_client where
  dependencies := #[{
    name := `socket
    src := Source.path "../../lake"
  }]
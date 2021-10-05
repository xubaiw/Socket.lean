import Lake
open Lake DSL

package gethostname where
  dependencies := #[{
    name := `socket
    src := Source.path "../../lake"
  }]
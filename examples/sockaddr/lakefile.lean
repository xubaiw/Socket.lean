import Lake
open Lake DSL

package sockaddr where
  dependencies := #[{
    name := `socket
    src := Source.path "../../lake"
  }]
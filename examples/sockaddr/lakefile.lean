import Lake
open System Platform Lake DSL

package sockaddr where
  dependencies := #[{
    name := `socket
    src := Source.path "../.."
  }]
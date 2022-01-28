import Lake
open System Platform Lake DSL

package gethostname where
  dependencies := #[{
    name := `socket
    src := Source.path "../.."
  }]
import Lake
open System Platform Lake DSL

def linkArgs := if isWindows then #["-lWs2_32"] else #[]

package gethostname where
  dependencies := #[{
    name := `socket
    src := Source.path "../../lake"
  }]
  moreLinkArgs := linkArgs
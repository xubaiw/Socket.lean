import Lake
import Lean.Elab.Command
import Lake.Util.EvalTerm
open System Lake DSL Lean Elab Command

package socket {
  precompileModules := true
}

@[defaultTarget]
lean_lib Socket

def cDir : FilePath := "native"
def ffiSrc := "native.c"
def ffiSrcPath := cDir / ffiSrc
def ffiO := "ffi.o"
def ffiLib := "libffi.a"

target ffi.o (pkg : Package) : FilePath := do
  let oFile := pkg.buildDir / ffiO
  let srcJob ← inputFile <| pkg.dir / ffiSrcPath
  buildFileAfterDep oFile srcJob fun srcFile => do
    let flags := #["-I", (← getLeanIncludeDir).toString]
    compileO ffiSrc oFile srcFile flags

extern_lib ffi (pkg : Package) := do
  let name := nameToStaticLib ffiLib
  let ffiO ← fetch <| pkg.target ``ffi.o
  buildStaticLib (pkg.buildDir / "lib" / name) #[ffiO]

script examples do
  let examplesDir ← ("examples" : FilePath).readDir
  for ex in examplesDir do
    IO.println ex.path
    let o ← IO.Process.output {
      cmd := "lake"
      args := #["build"]
      cwd := ex.path
    }
    IO.println o.stderr
  return 0

script clean do
  let examplesDir ← ("examples" : FilePath).readDir
  let _ ← IO.Process.output {
      cmd := "lake"
      args := #["clean"]
  }
  for ex in examplesDir do
    let _ ← IO.Process.output {
      cmd := "lake"
      args := #["clean"]
      cwd := ex.path
    }
  return 0
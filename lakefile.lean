import Lake
import Lean.Elab.Command
import Lake.Util.EvalTerm
open System Lake DSL Lean Elab Command

package socket

def leanSoureDir := "."
def cppCompiler := "gcc"
def cDir : FilePath := "native"
def ffiSrc := cDir / "native.c"
def ffiO := "ffi.o"
def ffiLib := "libffi.a"

def ffiOTarget : FileTarget :=
  let oFile := __dir__ / defaultBuildDir / cDir / ffiO
  let srcTarget := inputFileTarget <| __dir__ / ffiSrc
  fileTargetWithDep oFile srcTarget fun srcFile => do
    compileO oFile srcFile
      #["-I", (← getLeanIncludeDir).toString] cppCompiler

def cLibTarget : FileTarget :=
  let libFile := __dir__ / defaultBuildDir / cDir / ffiLib
  staticLibTarget libFile #[ffiOTarget]

extern_lib clib := cLibTarget

-- HACK
elab "meta " "if " x:term " then " cmd:command : command => do
  if (← runTermElabM none <| fun _ => evalTerm Bool x) then elabCommand cmd

meta if System.Platform.isWindows then
extern_lib ws2 := inputFileTarget "C:\\Windows\\System32\\ws2_32.dll"

@[defaultTarget]
lean_lib Socket

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
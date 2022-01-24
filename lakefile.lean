import Lake
open System Lake DSL

def leanSoureDir := "."
def cppCompiler := "gcc"
def cDir : FilePath := "native"
def ffiSrc := cDir / "native.c"
def ffiO := "ffi.o"
def ffiLib := "libffi.a"

def ffiOTarget (pkgDir : FilePath) : FileTarget :=
  let oFile := pkgDir / defaultBuildDir / cDir / ffiO
  let srcTarget := inputFileTarget <| pkgDir / ffiSrc
  fileTargetWithDep oFile srcTarget fun srcFile => do
    compileO oFile srcFile
      #["-I", (← getLeanIncludeDir).toString] cppCompiler

def cLibTarget (pkgDir : FilePath) : FileTarget :=
  let libFile := pkgDir / defaultBuildDir / cDir / ffiLib
  staticLibTarget libFile #[ffiOTarget pkgDir]

package socket (pkgDir) (args) {
  moreLibTargets := if Platform.isWindows then #[cLibTarget pkgDir, inputFileTarget "C:\\Windows\\System32\\ws2_32.dll"] else #[cLibTarget pkgDir]
  defaultFacet := PackageFacet.staticLib
}

script examples (args) do
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

script clean (args) do
  let examplesDir ← ("examples" : FilePath).readDir
  let o ← IO.Process.output {
      cmd := "lake"
      args := #["clean"]
  }
  for ex in examplesDir do
    let o ← IO.Process.output {
      cmd := "lake"
      args := #["clean"]
      cwd := ex.path
    }
  return 0
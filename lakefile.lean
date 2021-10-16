import Lake
open System Lake DSL

def nativeOTarget (pkgDir : FilePath) : FileTarget :=
  oFileTarget (pkgDir / "./build/native/native.o") (pkgDir / "./native/native.c" : FilePath) #[] "leanc"

def cLibTarget (pkgDir : FilePath) : FileTarget :=
  staticLibTarget (pkgDir / "./build/native/native.a") #[nativeOTarget pkgDir]

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
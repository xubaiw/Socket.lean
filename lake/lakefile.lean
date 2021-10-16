import Lake
open System Platform Lake DSL

def nativeOTarget (pkgDir : FilePath) : FileTarget :=
  oFileTarget (pkgDir / "../build/native/native.o") (pkgDir / "../native/native.c" : FilePath) #[] "leanc"

def cLibTarget (pkgDir : FilePath) : FileTarget :=
  staticLibTarget (pkgDir / "../build/native/native.a") #[nativeOTarget pkgDir]

package socket (pkgDir) (args) {
  srcDir := "../"
  buildDir := "../build"
  libRoots := #[`Socket]
  moreLibTargets := #[cLibTarget pkgDir]
}
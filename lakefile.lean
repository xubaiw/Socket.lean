import Lake
open System Lake DSL

def nativeDir : FilePath := "native"
def nativeSrc := nativeDir / "native.cpp"

def buildDir := defaultBuildDir
def nativeO := buildDir / nativeDir / "native.o"
def cLib := buildDir / nativeDir / "native.a"

def nativeOTarget (pkgDir : FilePath) : FileTarget :=
  oFileTarget (pkgDir / nativeO) (pkgDir / nativeSrc : FilePath) #[] "gcc"

def cLibTarget (pkgDir : FilePath) : FileTarget :=
  staticLibTarget (pkgDir / cLib) #[nativeOTarget pkgDir]

package (pkgDir) (args) {
  name := "socket"
  libRoots := #[`Socket]
  moreLibTargets := #[cLibTarget pkgDir]
}

import Lake
open System Lake DSL

def cDir : FilePath := "c"
def addSrc := cDir / "native.cpp"

def buildDir := defaultBuildDir
def nativeO := buildDir / cDir / "native.o"
def cLib := buildDir / cDir / "native.a"

def nativeOTarget (pkgDir : FilePath) : FileTarget :=
  oFileTarget (pkgDir / nativeO) (pkgDir / addSrc : FilePath)

def cLibTarget (pkgDir : FilePath) : FileTarget :=
  staticLibTarget (pkgDir / cLib) #[nativeOTarget pkgDir]

package (pkgDir) (args) {
  name := "socket"
  libRoots := #[`Socket]
  moreLibTargets := #[cLibTarget pkgDir]
}

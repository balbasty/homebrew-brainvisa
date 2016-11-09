class NoExpatFramework < Requirement
  def expat_framework
    "/Library/Frameworks/expat.framework"
  end

  satisfy :build_env => false do
    !File.exist? expat_framework
  end

  def message; <<-EOS.undent
    Detected #{expat_framework}
    This will be picked up by CMake's build system and likely cause the
    build to fail, trying to link to a 32-bit version of expat.
    You may need to move this file out of the way to compile CMake.
    EOS
  end
end

class Cmake < Formula
  desc "Cross-platform make"
  homepage "http://www.cmake.org/"
  url "http://www.cmake.org/files/v2.8/cmake-2.8.12.tar.gz"
  sha256 "d885ba10b2406ede59aa31a928df33c9d67fc01433202f7dd586999cfd0e0287"

  depends_on "qt" => :optional

  conflicts_with "cmake", :because => "both install a cmake binary"
  conflicts_with "homebrew/versions/cmake31", :because => "both install a cmake binary"
  conflicts_with "homebrew/versions/cmake30", :because => "both install a cmake binary"

  depends_on NoExpatFramework

  def install
    args = %W[
      --prefix=#{prefix}
      --system-libs
      --no-system-libarchive
      --datadir=/share/cmake
      --docdir=/share/doc/cmake
      --mandir=/share/man
    ]

    args << "--qt-gui" if build.with? "qt"

    system "./bootstrap", *args
    system "make"
    system "make", "install"
    bin.install_symlink Dir["#{prefix}/CMake.app/Contents/bin/*"] if build.with? "qt"
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system "#{bin}/cmake", "."
  end
end

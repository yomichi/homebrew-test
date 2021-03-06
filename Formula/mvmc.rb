class Mvmc < Formula
  desc "Solver for quantum lattice models based on many-variable VMC method"
  homepage "https://github.com/issp-center-dev/mVMC/releases"
  url "https://github.com/issp-center-dev/mVMC/releases/download/v1.0.0/mVMC-1.0.0.tar.gz"
  sha256 "f9a8098733d12a6e35fd5d1f308cb3d0e0946aa688487d63d93516e166794dc8"

  option "with-scalapack", "Build with ScaLAPACK support"

  needs :openmp

  depends_on "cmake" => :build
  depends_on :mpi
  depends_on :fortran

  depends_on "homebrew/science/scalapack" => :optional

  def install
    args = std_cmake_args
    args.delete "-DCMAKE_BUILD_TYPE=None"
    args << "-DCMAKE_BUILD_TYPE=Release"
    args << "-DCONFIG=gcc"
    if build.with? "scalapack"
      args << "-DUSE_SCALAPACK=ON"
      args << "-DSCALAPACK_LIBRARIES=-lscalapack"
    end

    system "cmake", ".", *args
    system "make"
    bin.install "src/mVMC/vmc.out", "src/mVMC/vmcdry.out", "src/ComplexUHF/UHF"
    bin.install "tool/fourier" => "fourier_mvmc", "tool/corplot" => "corplot_mvmc"
    doc.install "doc/jp/userguide_jp.pdf", "doc/en/userguide_en.pdf"
    pkgshare.install "sample"
  end

  test do
    (testpath/"stdface.def").write <<-EOF.undent
      model="hubbard"
      lattice="chain"
      2Sz=0
      L=4
      nelec=4
      t=1
      U=4
      NSROptItrStep=100
      NStore=1
    EOF
    system "vmc.out", "-s", "stdface.def"
  end
end
